//
//  TransactionManager.swift
//  Accounting
//
//  Created by Roman Topchii on 03.01.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import Foundation
import CoreData

class TransactionManager {
    
    static func addTransaction(date : Date, debit : Account, credit : Account, debitAmount : Double, creditAmount : Double, comment : String? = nil, createdByUser : Bool = true, context: NSManagedObjectContext) {
        let transaction = Transaction(context: context)
        
        let createDate = Date()
        transaction.createDate = createDate
        transaction.createdByUser = createdByUser
        transaction.modifyDate = createDate
        transaction.modifiedByUser = createdByUser
        
        transaction.date = date
        
        TransactionItemManager.createTransactionItem(transaction: transaction, type: .credit, account: credit, amount: creditAmount, createdByUser:  createdByUser, createDate: createDate, context: context)
        TransactionItemManager.createTransactionItem(transaction: transaction, type: .debit, account: debit, amount: debitAmount, createdByUser:  createdByUser, createDate: createDate, context: context)
        
        transaction.comment = comment
    }

    
    
    static func createAndGetEmptyTransaction(date : Date, comment : String? = nil, createdByUser : Bool = true, context: NSManagedObjectContext) -> Transaction {
            let transaction = Transaction(context: context)
            
            let createDate = Date()
            transaction.createDate = createDate
            transaction.createdByUser = createdByUser
            transaction.modifyDate = createDate
            transaction.modifiedByUser = createdByUser
            
            transaction.date = date
            
            transaction.comment = comment
        return transaction
    }
    
    
    static func copyTransaction(_ transaction: Transaction, createdByUser : Bool = true, context: NSManagedObjectContext) {
        let copiedTransaction = Transaction(context: context)
        
        let createDate = Date()
        copiedTransaction.createDate = createDate
        copiedTransaction.createdByUser = createdByUser
        copiedTransaction.modifyDate = createDate
        copiedTransaction.modifiedByUser = createdByUser
        copiedTransaction.date = transaction.date
        copiedTransaction.comment = transaction.comment
        
        let copiedTransactionItems = transaction.items!.allObjects as! [TransactionItem]
        for item in copiedTransactionItems{
            TransactionItemManager.createTransactionItem(transaction: copiedTransaction, type: item.type, account: item.account!, amount: item.amount, context: context)
        }
    }
    
    
    static func deleteTransaction(_ transaction : Transaction, context: NSManagedObjectContext){
        do {
            for item in transaction.items!.allObjects as! [TransactionItem]{
                context.delete(item)
            }
            context.delete(transaction)
            try CoreDataStack.shared.saveContext(context)
        }
        catch let error {
            print("ERROR", error)
        }
    }
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllTransactions(context: NSManagedObjectContext){
        let transactionFetchRequest : NSFetchRequest<Transaction> = NSFetchRequest<Transaction>(entityName: Transaction.entity().name!)
        transactionFetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        
        do {
            let transactions = try context.fetch(transactionFetchRequest)
            for transaction in transactions {
                for item in transaction.items!.allObjects as! [TransactionItem]{
                    context.delete(item)
                }
                context.delete(transaction)
            }
        }
        catch let error {
            print("ERROR", error)
        }
    }
    
    
    static func importTransactionList(from data : String, context: NSManagedObjectContext) throws -> [PreTransaction] {
        var inputMatrix: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            inputMatrix.append(columns)
        }
        inputMatrix.remove(at: 0)

        //load accounts from the DB
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "path", ascending: false)]
        let accounts = try context.fetch(accountFetchRequest)

        var preTransactionList : [PreTransaction] = []

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"

        for row in inputMatrix {
            
            guard row.count > 1 else {break}
            
            func getPreTransactionWithId(_ id : String) -> PreTransaction? {
                let candidate = preTransactionList.filter({if $0.id == id {return true} else {return false}})
                if candidate.count == 1 {
                    return candidate[0]
                }
                return nil
            }
            
            
            var preTransaction : PreTransaction!
            
            if let pretransaction = getPreTransactionWithId(row[0]) {
                preTransaction = pretransaction
                if let date = formatter.date(from: row[1]), preTransaction.transaction.date == nil {
                    preTransaction.transaction.date = date
                }
            }
            else {
                preTransaction = PreTransaction()
                preTransaction.transaction = Transaction(context: context)
                preTransaction.id = row[0]
                preTransaction.transaction.date = formatter.date(from: row[1])
                if row[5] != "" {
                    preTransaction.transaction.comment = row[5]
                }
            
                preTransaction.transaction.createDate = Date()
                preTransaction.transaction.modifyDate = Date()
                preTransaction.transaction.createdByUser = true
                preTransaction.transaction.modifiedByUser = true
                preTransactionList.append(preTransaction)
            }

            func findAccountWithPath(_ path : String) -> Account?{
                for account in accounts {
                    if account.path! == path {
                        return account
                    }
                }
                return nil
            }
            
            let transactionItem = TransactionItem(context: context)
            if row[2] == "Credit" || row[2] == "From" {
                transactionItem.type = 0
            }
            else if row[2] == "Debit" || row[2] == "To" {
                transactionItem.type = 1
            }
            else {
                throw TransactionItemError.attributeTypeDidNotSpecified
            }
            transactionItem.account = findAccountWithPath(row[3])
            if let amount = Double(row[4]) {
                transactionItem.amount = amount
            }
            else {
                transactionItem.amount = -1
            }

            transactionItem.transaction = preTransaction.transaction
            transactionItem.createDate = Date()
            transactionItem.modifyDate = Date()
            transactionItem.createdByUser = true
            transactionItem.modifiedByUser = true
        }
        return preTransactionList
    }
    
    
    static func exportTransactionsToString(context: NSManagedObjectContext) -> String {
        let tansactionFetchRequest : NSFetchRequest<Transaction> = NSFetchRequest<Transaction>(entityName: Transaction.entity().name!)
        tansactionFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do{
            let storedTransactions = try context.fetch(tansactionFetchRequest)
            var export : String = "Id,Date,Type,Account,Amount,Comment"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"
            for transaction in storedTransactions {
                
                let startIndex =  transaction.id.debugDescription.index(transaction.id.debugDescription.firstIndex(of: "x")!, offsetBy: 1)
                let endIndex = transaction.id.debugDescription.index(transaction.id.debugDescription.firstIndex(of: ")")!, offsetBy: -1)
                let transactionId = transaction.id.debugDescription[startIndex...endIndex]
                
                for item in transaction.items?.allObjects as! [TransactionItem] {
                    export += "\n"
                    
                    export +=  String(describing: transactionId) + ","
                    
                    export +=  String(describing: formatter.string(from:transaction.date!)) + ","
                    var type :String = ""
                    if item.type == 0 {
                        type = "Credit"
                    }
                    else if item.type == 1 {
                        type = "Debit"
                    }
                    export +=  type + ","
                    export +=  String(describing: item.account!.path ?? "error") + ","
                    export +=  String(describing: item.amount) + ","
                    export +=  "\(transaction.comment ?? "")"
                }
            }
            return export
        }
        catch let error {
            print("ERROR", error)
            return ""
        }
    }
    
    
    static func getDateForFirstTransaction(context: NSManagedObjectContext) -> Date? {
        let transactionFetchRequest : NSFetchRequest<Transaction> = NSFetchRequest<Transaction>(entityName: Transaction.entity().name!)
        transactionFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        transactionFetchRequest.fetchBatchSize = 1
        do{
            let storedTransactions = try context.fetch(transactionFetchRequest)
            return storedTransactions.first?.date
        }
        catch let error {
            print("ERROR", error)
            return nil
        }
    }
    
    
    static func validateTransactionDataBeforeSave(_ transaction: Transaction) throws {
        
        func getDataAboutTransactionItems(transaction: Transaction, type: AccounttingMethod, amount: inout Double, currency: inout Currency?, itemsCount: inout Int) throws {
            for item in (transaction.items?.allObjects as! [TransactionItem]).filter({$0.type == type.rawValue}) {
                itemsCount += 1
                amount += item.amount
                if let account = item.account{
                    if let cur = account.currency {
                        if currency != cur {
                            currency = nil //multicurrency transaction
                        }
                    }
                    else {
                        throw TransactionError.multicurrencyAccount(name: account.path!)
                    }
                    
                    if item.amount < 0 {
                        switch type {
                        case .debit:
                            throw TransactionItemError.invalidAmountInDebitTransactioItem(path: account.path!)
                        case .credit:
                            throw TransactionItemError.invalidAmountInCreditTransactioItem(path: account.path!)
                        }
                    }
                }
                else {
                    switch type {
                    case .debit:
                        throw TransactionError.debitTransactionItemWOAccount
                    case .credit:
                        throw TransactionError.creditTransactionItemWOAccount
                    }
                }
            }
        }
        
        var debitAmount: Double = 0
        var creditAmount: Double = 0
        
        var debitItemsCount: Int = 0
        var creditItemsCount: Int = 0
        
        //MARK:- Prepare data to check ability to save transaction
        var debitCurrency: Currency? = (transaction.items?.allObjects as! [TransactionItem]).filter({$0.type == 1})[0].account?.currency
        var creditCurrency: Currency? = (transaction.items?.allObjects as! [TransactionItem]).filter({$0.type == 0})[0].account?.currency
        
        try getDataAboutTransactionItems(transaction: transaction, type: .debit, amount: &debitAmount, currency: &debitCurrency, itemsCount: &debitItemsCount)
        
        try getDataAboutTransactionItems(transaction: transaction, type: .credit, amount: &creditAmount, currency: &creditCurrency, itemsCount: &creditItemsCount)
        
        
        //MARK:- Check ability to save transaction
        
        if debitItemsCount == 0 {
            throw TransactionError.noDebitTransactionItem
        }
        if creditItemsCount == 0 {
            throw TransactionError.noCreditTransactionItem
        }
        
        if debitCurrency == creditCurrency {
            if debitAmount != creditAmount {
                throw TransactionError.differentAmountForSingleCurrecyTransaction
            }
        }
    }
}
