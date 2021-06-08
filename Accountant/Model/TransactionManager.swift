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
        
        let debitTransactionItem = TransactionItem(context: context)
        debitTransactionItem.account = debit
        debitTransactionItem.amount = debitAmount
        debitTransactionItem.type = AccounttingMethod.debit.rawValue
        debitTransactionItem.createdByUser = createdByUser
        debitTransactionItem.createDate = createDate
        debitTransactionItem.modifiedByUser = createdByUser
        debitTransactionItem.modifyDate = createDate
        debitTransactionItem.transaction = transaction
        
        let creditTransactionItem = TransactionItem(context: context)
        creditTransactionItem.account = credit
        creditTransactionItem.amount = creditAmount
        creditTransactionItem.type = AccounttingMethod.credit.rawValue
        creditTransactionItem.createdByUser = createdByUser
        creditTransactionItem.createDate = createDate
        creditTransactionItem.modifiedByUser = createdByUser
        creditTransactionItem.modifyDate = createDate
        creditTransactionItem.transaction = transaction
        
        transaction.comment = comment
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
            let copiedTransactionItem = TransactionItem(context: context)
            copiedTransactionItem.account = item.account
            copiedTransactionItem.amount = item.amount
            copiedTransactionItem.type = item.type
            copiedTransactionItem.createdByUser = createdByUser
            copiedTransactionItem.createDate = createDate
            copiedTransactionItem.modifiedByUser = createdByUser
            copiedTransactionItem.modifyDate = createDate
            copiedTransactionItem.transaction = copiedTransaction
        }
    }
    
    
    
    
    static func addTransactionsFromPreTransactionList(_ preTransactionList : [PreTransaction], context: NSManagedObjectContext) {
        var transactionList : [Transaction] = []
        
        let createDate = Date()
        let createdByUser = true

        for preTransaction in preTransactionList {
            
            let transaction = Transaction(context: context)
            transaction.createDate = createDate
            transaction.createdByUser = createdByUser
            transaction.modifyDate = createDate
            transaction.modifiedByUser = createdByUser
        
            transaction.date = preTransaction.date
            
            let debitTransactionItem = TransactionItem(context: context)
            debitTransactionItem.account = preTransaction.debit
            debitTransactionItem.amount = preTransaction.debitAmount!
            debitTransactionItem.type = AccounttingMethod.debit.rawValue
            debitTransactionItem.createdByUser = createdByUser
            debitTransactionItem.createDate = createDate
            debitTransactionItem.modifiedByUser = createdByUser
            debitTransactionItem.modifyDate = createDate
            debitTransactionItem.transaction = transaction
            
            let creditTransactionItem = TransactionItem(context: context)
            creditTransactionItem.account = preTransaction.credit
            creditTransactionItem.amount = preTransaction.creditAmount!
            creditTransactionItem.type = AccounttingMethod.credit.rawValue
            creditTransactionItem.createdByUser = createdByUser
            creditTransactionItem.createDate = createDate
            creditTransactionItem.modifiedByUser = createdByUser
            creditTransactionItem.modifyDate = createDate
            creditTransactionItem.transaction = transaction
            
            transaction.comment = preTransaction.memo
            
            transactionList.append(transaction)
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
    
    
    static func importTransactionList(from data : String, context: NSManagedObjectContext) throws -> [PreTransaction] {
        var inputMatrix: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            inputMatrix.append(columns)
        }
        inputMatrix.remove(at: 0)

        //load accounts from DB
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "path", ascending: false)]
        let accounts = try context.fetch(accountFetchRequest)

        var preTransactionList : [PreTransaction] = []

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"

        for row in inputMatrix {

            let preTransaction = PreTransaction()
            preTransaction.date = formatter.date(from: row[0])

            func findAccountWithPath(_ path : String) -> Account?{
                for account in accounts {
                    if account.path! == path {
                        return account
                    }
                }
                return nil
            }

            preTransaction.credit = findAccountWithPath(row[1])
            preTransaction.creditAmount = Double(row[2])
            preTransaction.debit = findAccountWithPath(row[3])
            preTransaction.debitAmount = Double(row[4])

            if row[5] != "" {
                preTransaction.memo = row[5]
            }
            preTransactionList.append(preTransaction)
        }
        return preTransactionList
    }
    
    
    static func exportTransactionsToString(context: NSManagedObjectContext) -> String {
        let tansactionFetchRequest : NSFetchRequest<Transaction> = NSFetchRequest<Transaction>(entityName: Transaction.entity().name!)
        tansactionFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do{
            let storedTransactions = try context.fetch(tansactionFetchRequest)
            var export : String = "Date,Credit,Credit amount,Debit,Debit amount,Comment"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"
            for transaction in storedTransactions {
                
                var debitAccount: Account!
                var creditAccount: Account!
                var debitAmount: Double = 0
                var creditAmount: Double = 0
                
                for item in transaction.items?.allObjects as! [TransactionItem] {
                    if item.type == AccounttingMethod.debit.rawValue {
                        debitAccount = item.account!
                        debitAmount = item.amount
                    }
                    else if item.type == AccounttingMethod.credit.rawValue {
                        creditAccount = item.account!
                        creditAmount = item.amount
                    }
                }
                
                export += "\n"
                export +=  String(describing: formatter.string(from:transaction.date!))+","
                export +=  String(describing: creditAccount.path ?? "error")+","
                export +=  String(describing: creditAmount)+","
                export +=  String(describing: debitAccount.path ?? "error")+","
                export +=  String(describing: debitAmount)+","
                export +=  "\(transaction.comment ?? "")"
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
}
