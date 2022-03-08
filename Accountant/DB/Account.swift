//
//  Account.swift
//  Accountant
//
//  Created by Roman Topchii on 08.03.2022.
//

import Foundation
import CoreData

extension Account {
    
    convenience init(parent: Account?, name : String, type : Int16?, currency : Currency?, keeper: Keeper?, holder: Holder?, subType : Int16? = nil, createdByUser : Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) {
        
        self.init(context: context)
        self.id = UUID()
        self.createDate = createDate
        self.createdByUser = createdByUser
        self.modifyDate = createDate
        self.modifiedByUser = createdByUser
        self.name = name
        
        self.currency = currency
        self.keeper = keeper
        self.holder = holder
        
        if let subType = subType {
            self.subType = subType
        }
        
        if let parent = parent {
            self.parent = parent
            self.isHidden = parent.isHidden
            self.addToAncestors(parent)
            if let parentAncestors = parent.ancestors {
                self.addToAncestors(parentAncestors)
            }
            self.level = parent.level + 1
            self.path = parent.path!+":"+name
            self.type = parent.type
        }
        else {
            self.level = 0
            self.path = name
            self.type = type!
        }
    }
    
    var rootAccount: Account {
        for item in ancestors?.allObjects as! [Account] {
            if item.level == 0 {
                return item
            }
        }
        return self
    }
    
    var directChildrenList: [Account] {
        return directChildren?.allObjects as! [Account]
    }
    
    var childrenList: [Account] {
        return children?.allObjects as! [Account]
    }
    
    var ancestorList: [Account] {
        return ancestors?.allObjects as! [Account]
    }
    
    var transactionItemsList: [TransactionItem] {
        return transactionItems?.allObjects as! [TransactionItem]
    }
    
    var appliedTransactionItemsList: [TransactionItem] {
        return transactionItemsList.filter{$0.transaction!.applied == true}
    }
    
    var isFreeFromTransactionItems: Bool {
        return transactionItemsList.isEmpty
    }
    
    func getSubAccountWith(name: String) -> Account? {
        for child in childrenList {
            if child.name == name {
                return child
            }
        }
        return nil
    }
    
    func changeIsHiddenStatus(modifiedByUser : Bool = true, modifyDate: Date = Date()) throws {
        let oldIsHidden = self.isHidden
        if oldIsHidden {  //activation
            for anc in self.ancestorList.filter({$0.isHidden == true}) {
                anc.isHidden = false
                anc.modifyDate = modifyDate
                anc.modifiedByUser = modifiedByUser
            }
        }
        else {  //deactivation
            for item in self.childrenList.filter({$0.isHidden == false}){
                item.isHidden = true
                item.modifyDate = modifyDate
                item.modifiedByUser = modifiedByUser
            }
        }
        if parent?.parent == nil &&
            parent?.currency == nil &&
            self.balance != 0 &&
            self.isHidden == false {
            throw AccountError.accumulativeAccountCannotBeHiddenWithNonZeroAmount(name: self.path!)
        }
        self.isHidden = !oldIsHidden
        self.modifyDate = modifyDate
        self.modifiedByUser = modifiedByUser
    }
    
    func accountListUsingInTransactions() -> [Account] {
        var accounts = childrenList
        accounts.append(self)
        return accounts.filter({$0.isFreeFromTransactionItems == false})
    }
    
    // MARK: - BALANCE
    
    var balance : Double {
        var debitTotal : Double = 0
        var creditTotal : Double = 0
        
        for account in childrenList + [self] {
            for item in account.appliedTransactionItemsList {
                if item.type == AccountingMethod.debit.rawValue{
                    debitTotal += item.amount
                }
                else if item.type == AccountingMethod.credit.rawValue{
                    creditTotal += item.amount
                }
            }
        }
        
        if type == AccountType.assets.rawValue {
            return debitTotal - creditTotal
        }
        else {
            return creditTotal - debitTotal
        }
    }
    
    func balanceForDateLessThenSelected(_ date : Date) -> Double{
        var debit : Double = 0
        var credit : Double = 0
        
        for account in childrenList + [self]  {
            
            let transactionItems = (account.appliedTransactionItemsList).filter{$0.transaction!.date! < date}
            
            for item in transactionItems {
                if item.type == AccountingMethod.debit.rawValue {
                    debit += item.amount
                }
                else if item.type == AccountingMethod.credit.rawValue {
                    credit += item.amount
                }
            }
        }
        
        if type == AccountType.assets.rawValue {
            return debit - credit
        }
        else {
            return credit - debit
        }
    }
    
    private static func createDateIntervalArray(dateInterval : DateInterval , dateComponent : Calendar.Component) -> [DateInterval] {
        let calendar = Calendar.current
        
        var intervalArray : [DateInterval] = []
        var interval = calendar.dateInterval(of: dateComponent ,for: dateInterval.start)
        while let tmpInterval = interval, tmpInterval.end <= dateInterval.end{
            intervalArray.append(tmpInterval)
            interval = calendar.dateInterval(of: dateComponent ,for: tmpInterval.end)
        }
        
        if let tmpInterval = interval, tmpInterval.start < dateInterval.end && tmpInterval.end > dateInterval.end{
            intervalArray.append(DateInterval(start: tmpInterval.start, end: dateInterval.end))
        }
        //        print("date interval [",dateInterval.start,dateInterval.end,"]")
        //        intervalArray.forEach({print($0)})
        return intervalArray
    }
    
    func getBalancesForDateIntervals(dateInterval : DateInterval , dateComponent : Calendar.Component, calcIncludedAccountsBalances: Bool = true) -> [(date : Date, value : Double)] {
        
        //creates date interval
        let intervalArray : [DateInterval] = Account.createDateIntervalArray(dateInterval: dateInterval, dateComponent: dateComponent)
        
        //calculate accountSaldoToLeftBorderDate
        var accountSaldoToLeftBorderDate : Double = 0
        var result : [(date : Date, value : Double)] = [(date : dateInterval.start, value : accountSaldoToLeftBorderDate)]
        
        var accounts: [Account] = []
        accounts.append(self)
        
        if calcIncludedAccountsBalances {
            accounts += childrenList
        }
        
        if accounts.isEmpty == false {
            if  accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) ||
                    accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) ||
                    accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors) {
                
                accounts.forEach({
                    accountSaldoToLeftBorderDate += $0.balanceForDateLessThenSelected(dateInterval.start)
                })
            }
            
            for (index,timeInterval) in intervalArray.enumerated() {
                var debitTotal : Double = 0
                var creditTotal : Double = 0
                
                for account in accounts {
                    let transactionItems = (account.transactionItems?.allObjects as! [TransactionItem]).filter{$0.transaction!.applied == true}
                    
                    for item in transactionItems {
                        if timeInterval.contains(item.transaction!.date!) {
                            if item.type == AccountingMethod.debit.rawValue{
                                debitTotal += item.amount
                            }
                            else if item.type == AccountingMethod.credit.rawValue{
                                creditTotal += item.amount
                            }
                        }
                    }
                }
                // FIXME: - remove condition below if its unused
                if true ||
                    accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) ||
                    accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) ||
                    accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors) {
                    if  accounts[0].type == AccountType.assets.rawValue {
                        result.append((date: timeInterval.end, value: round((result[index].value + debitTotal - creditTotal)*100)/100))
                    }
                    else {
                        result.append((date: timeInterval.end, value: round((result[index].value + creditTotal - debitTotal)*100)/100))
                    }
                }
                else {
                    if accounts[0].type == AccountType.assets.rawValue {
                        result.append((date: timeInterval.end, value: round((debitTotal - creditTotal)*100)/100))
                    }
                    else {
                        result.append((date: timeInterval.end, value: round((creditTotal - debitTotal)*100)/100))
                    }
                }
            }
        }
        else {
            result = []
        }
        return result
    }
}
