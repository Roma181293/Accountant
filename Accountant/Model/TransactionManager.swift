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
        transaction.createDate = createDate
        transaction.createdByUser = createdByUser
        
        transaction.date = date
        
        let debitTransactionItem = TransactionItem(context: context)
        debitTransactionItem.account = debit
        debitTransactionItem.amount = debitAmount
        debitTransactionItem.createdByUser = createdByUser
        debitTransactionItem.createDate = createDate
        debitTransactionItem.modifiedByUser = createdByUser
        debitTransactionItem.modifyDate = createDate
        transaction.addToItems(debitTransactionItem)
        
        let creditTransactionItem = TransactionItem(context: context)
        creditTransactionItem.account = credit
        creditTransactionItem.amount = creditAmount
        creditTransactionItem.createdByUser = createdByUser
        creditTransactionItem.createDate = createDate
        creditTransactionItem.modifiedByUser = createdByUser
        creditTransactionItem.modifyDate = createDate
        transaction.addToItems(creditTransactionItem)
        
        transaction.comment = comment
    }
    
    
    
    
//    static func addTransactionsFromPreTransactionList(_ preTransactionList : [PreTransaction], context: NSManagedObjectContext) {
//        var transactionList : [Transaction] = []
//        for preTransaction in preTransactionList {
//            let transaction = Transaction(context: context)
//            transaction.id = UUID()
//            transaction.createDate = Date()
//            transaction.createdByUser = true
//            transaction.transactionDate = preTransaction.transactionDate
//            transaction.debitAccount = preTransaction.debitAccount
//            transaction.creditAccount = preTransaction.creditAccount
//            transaction.amountInDebitCurrency = preTransaction.amountInDebitCurrency!
//            transaction.amountInCreditCurrency = preTransaction.amountInCreditCurrency!
//            transaction.memo = preTransaction.memo
//            transactionList.append(transaction)
//        }
//    }
    
    
    static func deleteTransaction(_ transaction : Transaction, context: NSManagedObjectContext){
        do {
            context.delete(transaction)
            try CoreDataStack.shared.saveContext(context)
        }
        catch let error {
            print("ERROR", error)
        }
    }
    
    
//    static func importTransactionList(from data : String, context: NSManagedObjectContext) throws -> [PreTransaction] {
//        var inputMatrix: [[String]] = []
//        let rows = data.components(separatedBy: "\n")
//        for row in rows {
//            let columns = row.components(separatedBy: ",")
//            inputMatrix.append(columns)
//        }
//        inputMatrix.remove(at: 0)
//
//        //load accounts from DB
//        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
//        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "nativeId", ascending: false)]
//        let accounts = try context.fetch(accountFetchRequest)
//
//        var preTransactionList : [PreTransaction] = []
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"
//
//        for row in inputMatrix {
//
//            let preTransaction = PreTransaction()
//            preTransaction.transactionDate = formatter.date(from: row[0])
//
//            func findAccountWithNativeId(_ nativeId : String) -> Account?{
//                for account in accounts {
//                    if account.nativeId! == nativeId {
//                        return account
//                    }
//                }
//                return nil
//            }
//
//            preTransaction.creditAccount = findAccountWithNativeId(row[1])
//            preTransaction.amountInCreditCurrency = Double(row[2])
//            preTransaction.debitAccount = findAccountWithNativeId(row[3])
//            preTransaction.amountInDebitCurrency = Double(row[4])
//
//            if row[5] != "" {
//                preTransaction.memo = row[5]
//            }
//            preTransactionList.append(preTransaction)
//        }
//        return preTransactionList
//    }
    
    
//    static func exportTransactionsToString(context: NSManagedObjectContext) -> String {
//        let tansactionFetchRequest : NSFetchRequest<Transaction> = NSFetchRequest<Transaction>(entityName: Transaction.entity().name!)
//        tansactionFetchRequest.sortDescriptors = [NSSortDescriptor(key: "transactionDate", ascending: false)]
//        do{
//            let storedTransactions = try context.fetch(tansactionFetchRequest)
//            var export : String = "date,credit Account,Amount In Credit Currency,debit Account,Amount In Debit Currency,memo"
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss z"
//            for transaction in storedTransactions {
//                export += "\n"
//                export +=  String(describing: formatter.string(from:transaction.transactionDate!))+","
//                export +=  String(describing: transaction.creditAccount?.nativeId! ?? "error")+","
//                export +=  String(describing: transaction.amountInCreditCurrency)+","
//                export +=  String(describing: transaction.debitAccount?.nativeId! ?? "error")+","
//                export +=  String(describing: transaction.amountInDebitCurrency)+","
//                export +=  "\(transaction.memo ?? "")"
//            }
//            return export
//        }
//        catch let error {
//            print("ERROR", error)
//            return ""
//        }
//    }
    
    
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
