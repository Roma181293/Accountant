//
//  AccountManager.swift
//  Accounting
//
//  Created by Roman Topchii on 03.01.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import Foundation
import CoreData
import Charts

class AccountManager {
    static func isReservedAccountName(_ name: String) -> Bool {
        let reservedAccountNames = [
            //EN
            "Income"
            ,"Expense"
            ,"Capital"
            ,"Money"
            ,"Debtors"
            ,"Creditors"
            ,"Before accounting period"
            ,"<Other>"
            ,"Other"
            //UA
            ,"Доходи"
            ,"Витрати"
            ,"Гроші"
            ,"Кредити"
            ,"Боржники"
            ,"Капітал"
            ,"До обліковий період"
            ,"<Інше>"
            ,"Інше"]
       for item in reservedAccountNames {
            if item == name {
                return true
            }
        }
        return false
    }
    
    
    static func isFreeAccountName(parent: Account?, name : String, context: NSManagedObjectContext) -> Bool {
        if let parent = parent {
            let children = parent.children?.allObjects as! [Account]
            for child in children{
                if child.name == name{
                    return  false
                }
            }
            return true
        }
        else {
            let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: "Account")
            accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "path", ascending: false)]
            accountFetchRequest.predicate = NSPredicate(format: "parent = nil and name = %@", name)
            do{
                let accounts = try context.fetch(accountFetchRequest)
                if accounts.isEmpty {
                    return true
                }
                else {
                    return false
                }
            }
            catch let error {
                print("ERROR", error)
                return false
            }
        }
    }
    
    
    static func isFreeFromTransactionItems(account: Account) -> Bool {
        if (account.transactionItems?.allObjects as! [TransactionItem]).isEmpty {
            return true
        }
        return false
    }
    
    
    static func fillAccountAttributes(parent: Account?, name : String, type : Int16?, currency : Currency?, subType : Int16? = nil, createdByUser : Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) -> Account {
        let account = Account(context: context)
        account.createDate = createDate
        account.createdByUser = createdByUser
        account.modifyDate = createDate
        account.modifiedByUser = createdByUser
        account.name = name
        
        account.currency = currency
        
        if let subType = subType {
            account.subType = subType
        }
        
        if let parent = parent {
            account.parent = parent
            account.isHidden = parent.isHidden
            account.addToAncestors(parent)
            if let parentAncestors = parent.ancestors {
                account.addToAncestors(parentAncestors)
            }
            account.level = parent.level + 1
            account.path = parent.path!+":"+name
            account.type = parent.type
        }
        else {
            account.level = 0
            account.path = name
            account.type = type!
        }
        return account
    }
    
    
    static func createAndGetAccount(parent: Account?, name : String, type : Int16?, currency : Currency?, subType : Int16? = nil, createdByUser : Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) throws -> Account {
        
        if parent == nil && type == nil {throw AccountError.attributeTypeShouldBeInitializeForRootAccount}
//        guard parent != nil && type != nil && parent?.type != type else {throw AccountError.accountContainAttribureTypeDifferentFromParent}
        
        // accounts with reserved names can create only app
        guard createdByUser == false || isReservedAccountName(name) == false else {throw AccountError.reservedAccountName}
        guard isFreeAccountName(parent: parent, name : name, context: context) == true else {throw AccountError.accontAlreadyExists(name: name)}
        
        if let parent = parent, !AccountManager.isFreeFromTransactionItems(account: parent) {
           let new = fillAccountAttributes(parent: parent, name: AccountsNameLocalisationManager.getLocalizedAccountName(.other1) , type : type, currency : currency, subType : subType, createdByUser : createdByUser, createDate: createDate, context: context)
            TransactionItemManager.moveTransactionItemsFrom(oldAccount: parent, newAccount: new, modifiedByUser: createdByUser, modifyDate: createDate)
        }
        
        return fillAccountAttributes(parent: parent, name : name, type : type, currency : currency, subType : subType, createdByUser : createdByUser, createDate: createDate, context: context)
    }
    
    
    static func createAccount(parent: Account?, name : String, type : Int16?, currency : Currency?, moneyAccountType : Int16? = nil, createdByUser : Bool = true, context: NSManagedObjectContext) throws {
        try createAndGetAccount(parent: parent, name : name, type : type, currency : currency, subType : moneyAccountType, createdByUser : createdByUser, context: context)
    }
    
    static func changeCurrencyForBaseAccounts(to currency : Currency, modifyDate: Date = Date(), modifiedByUser: Bool = true, context : NSManagedObjectContext) throws {
        var baseAccounts : [Account] = try getRootAccountList(context: context)
        var acc : [Account] = []
        for item in baseAccounts{
            if let currency = item.currency, currency.isAccounting == true {
                acc.append(contentsOf: getAllChildrenForAcctount(item))
                acc.append(item)
            }
        }
        for account in acc {
            account.currency = currency
            account.modifiedByUser = modifiedByUser
            account.modifyDate = modifyDate
        }
    }
    
    static func getRootAccountFor(_ account: Account) -> Account{
        for item in account.ancestors?.allObjects as! [Account] {
            if item.level == 0 {
                return item
            }
        }
        return account
    }
    
    
    static func getAllChildrenForAcctount(_ account : Account) -> [Account] {
        return account.children?.allObjects as! [Account]
    }
    
    static func getAllAncestorsForAcctount(_ account : Account) -> [Account] {
        return account.ancestors?.allObjects as! [Account]
    }
    
    
    static func canBeRenamed(account:Account) -> Bool {
        if isReservedAccountName(account.name!){
            return false
        }
        else {
            return true
        }
    }
    
    
    static func renameAccount(_ account : Account, to newName : String, context : NSManagedObjectContext) throws {
        guard isFreeAccountName(parent: account.parent, name: newName, context: context)
        else {throw AccountError.accontAlreadyExists(name: newName)}
        
        if let parent = account.parent {
            account.path = parent.path! + ":" + newName
            account.name = newName
            
            let allChildren = getAllChildrenForAcctount(account)
            for child in allChildren{
                if let childParent = child.parent{
                    child.path = childParent.path! + ":" + child.name!
                }
            }
        }
        else {
            account.path = newName
            account.name = newName
        }
    }
    
    static func getRootAccountList(context : NSManagedObjectContext) throws -> [Account] {
        let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        accountFetchRequest.predicate = NSPredicate(format: "parent = nil")
        return try context.fetch(accountFetchRequest)
    }
    
    static func getSubAccountWith(name: String, in account : Account) -> Account? {
        let children = getAllChildrenForAcctount(account)
        for child in children {
            if child.name == name {
                return child
            }
        }
        return nil
    }
    
    static func getAccountWithPath(_ path: String, context: NSManagedObjectContext) -> Account? {
        let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "path", ascending: true)]
        accountFetchRequest.predicate = NSPredicate(format: "path = %@", path)
        do{
            let accounts = try context.fetch(accountFetchRequest)
            if accounts.isEmpty {
                return nil
            }
            else {
                return accounts[0]
            }
        }
        catch let error {
            print("ERROR", error)
            return nil
        }
    }
    
  
    static func changeAccountIsHiddenStatus(_ account : Account, modifiedByUser : Bool = true, modifyDate: Date = Date()) throws {
        let oldIsHidden = account.isHidden
        if oldIsHidden {  //activation
            for anc in getAllAncestorsForAcctount(account).filter({$0.isHidden == true}) {
                anc.isHidden = false
                anc.modifyDate = modifyDate
                anc.modifiedByUser = modifiedByUser
            }
        }
        else {  //deactivation
            for item in getAllChildrenForAcctount(account).filter({$0.isHidden == false}){
                item.isHidden = true
                item.modifyDate = modifyDate
                item.modifiedByUser = modifiedByUser
            }
        }
        if let parent = account.parent, parent.parent == nil && AccountManager.balance(of : [account]) != 0 && parent.currency == nil && account.isHidden == false{
            throw AccountError.accumulativeAccountCannotBeHiddenWithNonZeroAmount(name: parent.name!)
        }
        account.isHidden = !oldIsHidden
        account.modifyDate = modifyDate
        account.modifiedByUser = modifiedByUser
    }
    
    static func removeAccount(_ account: Account, eligibilityChacked: Bool, context: NSManagedObjectContext) throws {
        var accounts = getAllChildrenForAcctount(account)
        accounts.append(account)
        if eligibilityChacked == false {
            if try canBeRemove(account: account) {
                accounts.forEach({
                    context.delete($0)
                })
            }
        }
        else {
            accounts.forEach({
                context.delete($0)
            })
        }
    }
    
    
    
    static func canBeRemove(account: Account) throws -> Bool {
        var accounts = getAllChildrenForAcctount(account)
        accounts.append(account)
        
        var accountUsedInTransactionItem : [Account] = []
        for acc in accounts{
            if !isFreeFromTransactionItems(account: acc) {
                accountUsedInTransactionItem.append(acc)
            }
        }
        
        if !accountUsedInTransactionItem.isEmpty {
            var accountListString : String = ""
            accountUsedInTransactionItem.forEach({
                accountListString += "\n" + $0.path!
            })
            throw AccountError.cantRemoveAccountThatUsedInTransactionItem(accountListString)
        }
        return true
    }
    
    static func accountListUsingInTransactions(account: Account) -> [Account] {
        var accounts = getAllChildrenForAcctount(account)
        accounts.append(account)
        
        var results : [Account] = []
        for acc in accounts{
            if !isFreeFromTransactionItems(account: acc) {
                results.append(acc)
            }
        }
        return results
    }
    
    static func exportAccountsToString(context: NSManagedObjectContext) -> String {
        
        let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "parent.path", ascending: true),NSSortDescriptor(key: "path", ascending: true)]
        do{
            let storedAccounts = try context.fetch(accountFetchRequest)
            var export : String = "ParentAccount_path,Account_name,isHidden,Account_type,Account_currency,Account_SubType,LinkedAccount_path\n"
            for account in storedAccounts {
                
                var accountType = ""
                switch account.type {
                case AccountType.assets.rawValue:
                    accountType = "Assets"
                case AccountType.liabilities.rawValue:
                    accountType = "Liabilities"
                default:
                    accountType = "Out of enumeration"
                }
                
                var accountSubType = ""
                switch account.subType {
                case AccountSubType.none.rawValue:
                    accountSubType = ""
                case AccountSubType.cash.rawValue:
                    accountSubType = "Cash"
                case AccountSubType.debitCard.rawValue:
                    accountSubType = "DebitCard"
                case AccountSubType.creditCard.rawValue:
                    accountSubType = "CreditCard"
                case AccountSubType.deposit.rawValue:
                    accountSubType = "Deposit"
                default:
                    accountSubType = "Out of enumeration"
                }
                
                export +=  "\(account.parent != nil ? account.parent!.path! : "" ),"
                export +=  "\(account.name!),"
                export +=  "\(account.isHidden),"
                export +=  "\(accountType),"
                export +=  "\(account.currency?.code ?? "MULTICURRENCY"),"
                export +=  "\(accountSubType),"
                export +=  "\(account.linkedAccount != nil ? account.linkedAccount!.path! : "" )\n"
            }
            return export
        }
        catch let error {
            print("ERROR", error)
            return ""
        }
    }
    
    static func getAccountList(context: NSManagedObjectContext) throws -> [Account] {
        let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "path", ascending: true)]
        return try context.fetch(accountFetchRequest)
    }
    
    static func importAccounts(_ data : String, context: NSManagedObjectContext) throws {
        
        var accountToBeAdded : [Account] = []
        var inputMatrix: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            inputMatrix.append(columns)
        }
        inputMatrix.remove(at: 0)
     
        
        
        for row in inputMatrix {
            
            guard row.count > 1 else {break}
            
            let parent = AccountManager.getAccountWithPath(row[0], context: context)
            
            let name = String(row[1])
            
            var isHidden = false
            switch row[2] {
            case "false":
                isHidden = false
            case "true":
                isHidden = true
            default:
                break//throw ImportAccountError.invalidIsHiddenValue
            }
            
            var accountType: Int16 = 0
            switch row[3] {
            case "Assets":
                accountType = AccountType.assets.rawValue
            case "Liabilities":
                accountType = AccountType.liabilities.rawValue
            default:
                break//throw ImportAccountError.invalidAccountTypeValue
            }
            
            let curency = try? CurrencyManager.getCurrencyForCode(row[4], context: context)
            
            var accountSubType: Int16 = 0
            switch row[5] {
            case "":
                break
            case "Cash":
                accountSubType = 1
            case "DebitCard":
                accountSubType = 2
            case "CreditCard":
                accountSubType = 3
            case "Deposit":
                accountSubType = 4
            default:
                break//throw ImportAccountError.invalidAccountSubTypeValue
            }
            
            let linkedAccount = AccountManager.getAccountWithPath(row[6], context: context)
            
            
            let account = try? AccountManager.createAndGetAccount(parent: parent, name: name, type: accountType, currency: curency, context: context)
            account?.linkedAccount = linkedAccount
            account?.subType = accountSubType
            account?.isHidden = isHidden
            
            
            //CHECKING
            if let account = account {
                
                accountToBeAdded.append(account)
            var accountTypes = ""
            switch account.type {
            case AccountType.assets.rawValue:
                accountTypes = "Assets"
            case AccountType.liabilities.rawValue:
                accountTypes = "Liabilities"
            default:
                accountTypes = "Out of enumeration"
            }
            
            var accountSubTypes = ""
            switch account.subType {
            case AccountSubType.none.rawValue:
                accountSubTypes = ""
            case AccountSubType.cash.rawValue:
                accountSubTypes = "Cash"
            case AccountSubType.debitCard.rawValue:
                accountSubTypes = "DebitCard"
            case AccountSubType.creditCard.rawValue:
                accountSubTypes = "CreditCard"
            case AccountSubType.deposit.rawValue:
                accountSubTypes = "Deposit"
            default:
                accountSubTypes = "Out of enumeration"
            }
            var export = ""
            export +=  "\(account.parent != nil ? account.parent!.path! : "" ),"
            export +=  "\(account.name!),"
            export +=  "\(account.isHidden),"
            export +=  "\(accountTypes),"
            export +=  "\(account.currency?.code ?? "MULTICURRENCY"),"
            export +=  "\(accountSubTypes),"
            export +=  "\(account.linkedAccount != nil ? account.linkedAccount!.path! : "" )\n"
//            print(export)
            }
            else {
                print("There is no account")
            }
        }
    }
        
       
    
    
 
    // MARK: - BALANCE
    
    static func balance(of accounts: [Account]) -> Double {
        var debitTotal : Double = 0
        var creditTotal : Double = 0
        
        if accounts.isEmpty == false {
            for account in accounts {
                
                let transactionItems = account.transactionItems?.allObjects as! [TransactionItem]
                
                for item in transactionItems {
                    if item.type == AccounttingMethod.debit.rawValue{
                        debitTotal += item.amount
                    }
                    else if item.type == AccounttingMethod.credit.rawValue{
                        creditTotal += item.amount
                    }
                }
            }
            if accounts[0].type == AccountType.assets.rawValue {
                return debitTotal - creditTotal
            }
            else {
                return creditTotal - debitTotal
            }
        }
        else {
            return 0
        }
    }
    
    
    static func balanceForDateInterval(dateInterval: DateInterval ,accounts: [Account], context: NSManagedObjectContext) -> Double {
        var debitTotal : Double = 0
        var creditTotal : Double = 0
        
        if accounts.isEmpty == false {
            if AccountManager.getRootAccountFor(accounts[0]).name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) || AccountManager.getRootAccountFor(accounts[0]).name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) ||
                AccountManager.getRootAccountFor(accounts[0]).name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors)
            {
                for account in accounts {
                    
                    let transactionItems = account.transactionItems?.allObjects as! [TransactionItem]
                    
                    for item in transactionItems {
                        if item.type == AccounttingMethod.debit.rawValue{
                            debitTotal += item.amount
                        }
                        else if item.type == AccounttingMethod.credit.rawValue{
                            creditTotal += item.amount
                        }
                    }
                }
            }
            else if accounts[0].name == AccountsNameLocalisationManager.getLocalizedAccountName(.capital) {
                if let expense = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.expense),context: context),
                   let income = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.income), context: context) {
                    
                    let capital = accounts[0]
                    let capitalBalance = balanceForDateLessThenSelected(date: dateInterval.end, accounts: AccountManager.getAllChildrenForAcctount(capital))
                    let incomeBalance = balanceForDateLessThenSelected(date: dateInterval.end, accounts: AccountManager.getAllChildrenForAcctount(income))
                    let expenseBalance = balanceForDateLessThenSelected(date: dateInterval.end, accounts: AccountManager.getAllChildrenForAcctount(expense))
                    
                    if capitalBalance + incomeBalance - expenseBalance > 0 {
                        return capitalBalance + incomeBalance - expenseBalance
                    }
                }
            }
            else {
                for account in accounts {
                    let transactionItems = account.transactionItems?.allObjects as! [TransactionItem]
                    
                    for item in transactionItems {
                        if dateInterval.contains(item.transaction!.date!) {
                            if item.type == AccounttingMethod.debit.rawValue{
                                debitTotal += item.amount
                            }
                            else if item.type == AccounttingMethod.credit.rawValue{
                                creditTotal += item.amount
                            }
                        }
                    }
                }
            }
            if accounts[0].type == AccountType.assets.rawValue {
                return  round((debitTotal - creditTotal)*100)/100
            }
            else {
                return round((creditTotal - debitTotal)*100)/100
            }
        }
        else {
            return 0
        }
    }
    
    /*
    /*   static func totalBalanceInCurrencyForListOfAccounts(onDate : Date, accountList: [Account], currencyHistoricalData: CurrencyHistoricalDataProtocol, currency: Currency) -> Double {
     
     if accountList.isEmpty == false {
     var amount : Double = 0
     for account in accountList {
     var exchangeRate : Double = 1
     if let rate =  currencyHistoricalData.exchangeRate(curr: currency.name!, to: account.currency!.name!) {
     exchangeRate = rate
     }
     amount += balanceForDateLessThenSelected(date: onDate, accounts: [account]) * exchangeRate
     }
     return amount
     }
     else {
     return 0
     }
     }
     */
    */
    static func balanceForDateLessThenSelected(date : Date, accounts: [Account]) -> Double{
        var debitSaldo : Double = 0
        var creditSaldo : Double = 0
        
        for account in accounts {
            
            let transactionItems = account.transactionItems?.allObjects as! [TransactionItem]
            
            for item in transactionItems {
                if item.type == AccounttingMethod.debit.rawValue && (item.transaction?.date)! < date {
                    debitSaldo += item.amount
                }
                else if item.type == AccounttingMethod.credit.rawValue && (item.transaction?.date)! < date {
                    creditSaldo += item.amount
                }
            }
        }
        
        if accounts[0].type == AccountType.assets.rawValue {
            return debitSaldo - creditSaldo
        }
        else {
            return creditSaldo - debitSaldo
        }
    }
    
    
    // MARK: - Methods that prepare data for visualisation (Charts)
    
    static func createDateIntervalArray(dateInterval : DateInterval , dateComponent : Calendar.Component) -> [DateInterval] {
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
    
    
    static func getBalancesForDateIntervals(accounts : [Account], dateInterval : DateInterval , dateComponent : Calendar.Component) -> [(date : Date, value : Double)] {
      
        //creates date interval
        let intervalArray : [DateInterval] = createDateIntervalArray(dateInterval: dateInterval, dateComponent: dateComponent)
       
        //calculate accountSaldoToLeftBorderDate
        var accountSaldoToLeftBorderDate : Double = 0
        var result : [(date : Date, value : Double)] = [(date : dateInterval.start, value : accountSaldoToLeftBorderDate)]
        
        if accounts.isEmpty == false {
            if AccountManager.getRootAccountFor(accounts[0]).name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) || AccountManager.getRootAccountFor(accounts[0]).name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) ||
                AccountManager.getRootAccountFor(accounts[0]).name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors) {
                
                accountSaldoToLeftBorderDate = balanceForDateLessThenSelected(date: dateInterval.start, accounts: accounts)
            }
            
            for (index,timeInterval) in intervalArray.enumerated() {
                var debitTotal : Double = 0
                var creditTotal : Double = 0
                
                for account in accounts {
                    let transactionItems = account.transactionItems?.allObjects as! [TransactionItem]
                    
                    for item in transactionItems {
                        if timeInterval.contains(item.transaction!.date!) {
                            if item.type == AccounttingMethod.debit.rawValue{
                                debitTotal += item.amount
                            }
                            else if item.type == AccounttingMethod.credit.rawValue{
                                creditTotal += item.amount
                            }
                        }
                    }
                }
                // FIXME: - remove condition below if its unused
                if true ||
                    AccountManager.getRootAccountFor(accounts[0]).name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) ||
                    AccountManager.getRootAccountFor(accounts[0]).name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) ||
                    AccountManager.getRootAccountFor(accounts[0]).name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors) {
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
    
    
    static func prepareDataToShow(parentAccount: Account?, dateInterval: DateInterval, accountingCurrency: Currency, currencyHistoricalData: CurrencyHistoricalDataProtocol? = nil, dateComponent: Calendar.Component, isListForAnalytic: Bool,sortTableDataBy: SortCategoryType, context: NSManagedObjectContext) throws -> PresentingData {
        var accountsToShow : [Account] = []
        
        if let account = parentAccount {
            if let children = account.directChildren {
                accountsToShow = children.allObjects as! [Account]
                if AccountManager.getRootAccountFor(account).name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) ||
                    AccountManager.getRootAccountFor(account).name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) ||
                    AccountManager.getRootAccountFor(account).name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors) {
//                    print("Nothing need to be added")
                }
                else {
                    accountsToShow.append(account)
                }
            }
        }
        else {
            let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
            accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "path", ascending: false)]
            accountFetchRequest.predicate = NSPredicate(format: "parent = nil")
            accountsToShow = try context.fetch(accountFetchRequest)
        }
        
        if isListForAnalytic == false {
            accountsToShow = accountsToShow.filter({
                if $0.isHidden {
                    return false
                }
                else {
                    return true
                }
            })
        }
        
        var accountsData : [AccountData] = []
        var lineChartDataSet : [LineChartDataSet] = []
               
        var maxValue : Double = 0
        var minValue : Double = 0
        
        for (index, account) in accountsToShow.enumerated() {
            var title = ""
            var arrayOfResultsForTmpAccount : [(date: Date, value: Double)] = []
            if account != parentAccount {
                title = account.name!
                var accoluAndAllChildren : [Account] = [account]
                accoluAndAllChildren += AccountManager.getAllChildrenForAcctount(account)
                arrayOfResultsForTmpAccount = getBalancesForDateIntervals(accounts: accoluAndAllChildren, dateInterval: dateInterval, dateComponent: dateComponent)
            }
            else {
                title = NSLocalizedString("<Other>", comment: "")
                arrayOfResultsForTmpAccount = getBalancesForDateIntervals(accounts: [account], dateInterval: dateInterval, dateComponent: dateComponent)
            }
            
            //convert (date: Date, value: Double) to ChartDataEntry(x:Double, y: Double)
            var entries : [ChartDataEntry] = []
            var checkSum : Double = 0
            for item in arrayOfResultsForTmpAccount {
                checkSum += item.value
                if item.value > maxValue {
                    maxValue = item.value
                }
                else if item.value < minValue {
                    minValue = item.value
                }
                entries.append(ChartDataEntry(x: item.date.timeIntervalSince1970, y: item.value))
            }
            
            let set  = LineChartDataSet(entries: entries, label: account.name)
            set.axisDependency = .left
            
            //colored line
            let colorSet = [NSUIColor(red: 192/255.0, green: 255/255.0, blue: 140/255.0, alpha: 1.0),
                            NSUIColor(red: 140/255.0, green: 234/255.0, blue: 255/255.0, alpha: 1.0),
                            NSUIColor(red: 255/255.0, green: 140/255.0, blue: 157/255.0, alpha: 1.0),
                            NSUIColor(red: 207/255.0, green: 248/255.0, blue: 246/255.0, alpha: 1.0),
                            NSUIColor(red: 148/255.0, green: 212/255.0, blue: 212/255.0, alpha: 1.0),
                            NSUIColor(red: 136/255.0, green: 180/255.0, blue: 187/255.0, alpha: 1.0),
                            NSUIColor(red: 118/255.0, green: 174/255.0, blue: 175/255.0, alpha: 1.0),
                            NSUIColor(red: 42/255.0, green: 109/255.0, blue: 130/255.0, alpha: 1.0),
                            NSUIColor(red: 217/255.0, green: 80/255.0, blue: 138/255.0, alpha: 1.0),
                            NSUIColor(red: 254/255.0, green: 149/255.0, blue: 7/255.0, alpha: 1.0),
                            NSUIColor(red: 255/255.0, green: 247/255.0, blue: 140/255.0, alpha: 1.0),
                            NSUIColor(red: 254/255.0, green: 247/255.0, blue: 120/255.0, alpha: 1.0),
                            NSUIColor(red: 106/255.0, green: 167/255.0, blue: 134/255.0, alpha: 1.0),
                            NSUIColor(red: 53/255.0, green: 194/255.0, blue: 209/255.0, alpha: 1.0),
                            NSUIColor(red: 64/255.0, green: 89/255.0, blue: 128/255.0, alpha: 1.0),
                            NSUIColor(red: 149/255.0, green: 165/255.0, blue: 124/255.0, alpha: 1.0),
                            NSUIColor(red: 217/255.0, green: 184/255.0, blue: 162/255.0, alpha: 1.0),
                            NSUIColor(red: 191/255.0, green: 134/255.0, blue: 134/255.0, alpha: 1.0),
                            NSUIColor(red: 179/255.0, green: 48/255.0, blue: 80/255.0, alpha: 1.0),
                            NSUIColor(red: 193/255.0, green: 37/255.0, blue: 82/255.0, alpha: 1.0),
                            NSUIColor(red: 255/255.0, green: 102/255.0, blue: 0/255.0, alpha: 1.0),
                            NSUIColor(red: 255/255.0, green: 208/255.0, blue: 140/255.0, alpha: 1.0),
                            NSUIColor(red: 245/255.0, green: 199/255.0, blue: 0/255.0, alpha: 1.0),
                            NSUIColor(red: 106/255.0, green: 150/255.0, blue: 31/255.0, alpha: 1.0),
                            NSUIColor(red: 179/255.0, green: 100/255.0, blue: 53/255.0, alpha: 1.0),
                            NSUIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0),
                            NSUIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 1.0),
                            NSUIColor(red: 231/255.0, green: 76/255.0, blue: 60/255.0, alpha: 1.0),
                            NSUIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1.0)
            ]
            var color : NSUIColor!
            if index < colorSet.count {
                color = colorSet[index]
                set.setColor(colorSet[index])
            }
            else {
                color = UIColor(red: CGFloat.random(in: 0...255) / 255, green: CGFloat.random(in: 0...255) / 255, blue: CGFloat.random(in: 0...255) / 255, alpha: 1)
            }
            set.setColor(color)
            set.lineWidth = 3
            set.drawCirclesEnabled = false
            set.drawValuesEnabled = false
            set.fillAlpha = 1
            set.drawCircleHoleEnabled = false
            
            
            var amountInAccountCurrency : Double {
                if arrayOfResultsForTmpAccount.isEmpty == false {
                    return arrayOfResultsForTmpAccount.last!.value
                }
                return 0
            }
            
            var amountInAccountingCurrency: Double {
                if accountingCurrency == account.currency {
                    return amountInAccountCurrency
                }
                else if amountInAccountCurrency != 0,
                        let currencyHistoricalData = currencyHistoricalData,
                        let accountCurrency = account.currency {
                    
                    var exchangeRate : Double = 1
                    
                    if let rate =  currencyHistoricalData.exchangeRate(curr: accountingCurrency.code!, to: accountCurrency.code!) {
                        exchangeRate = rate
                    }
                    return round(amountInAccountCurrency * exchangeRate * 100) / 100
                }
                return 0
            }
            
            if isListForAnalytic{
                if checkSum != 0{
                    lineChartDataSet.append(set)
                    accountsData.append(AccountData(account: account, title: title, color: color, amountInAccountCurrency: amountInAccountCurrency, amountInAccountingCurrency: amountInAccountingCurrency))
                }
            }
            else {
                lineChartDataSet.append(set)
                accountsData.append(AccountData(account: account, title: title, color: color, amountInAccountCurrency: amountInAccountCurrency, amountInAccountingCurrency: amountInAccountingCurrency))
            }
        }
        return PresentingData(dateInterval:dateInterval, presentingCurrency: accountingCurrency,lineChartData: ChartData(minValue: minValue, maxValue: maxValue, lineChartDataSet: lineChartDataSet), tableData: accountsData, sortTableDataBy: sortTableDataBy)
    }
    
    
    static func addBaseAccounts(accountingCurrency: Currency, context: NSManagedObjectContext) {
        AccountsNameLocalisationManager.createAllLocalizedAccountName()
        
        try? createAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.money), type: AccountType.assets.rawValue, currency: nil, createdByUser: false, context: context)
        try? createAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.credits), type: AccountType.liabilities.rawValue, currency: nil, createdByUser: false, context: context)
        try? createAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.debtors), type: AccountType.assets.rawValue, currency: nil, createdByUser: false, context: context)
        try? createAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.capital), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? createAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.expense), type: AccountType.assets.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
        try? createAccount(parent: nil, name: AccountsNameLocalisationManager.getLocalizedAccountName(.income), type: AccountType.liabilities.rawValue, currency: accountingCurrency, createdByUser: false, context: context)
    }
}
