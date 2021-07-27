//
//  TransactionItemManager.swift
//  Accountant
//
//  Created by Roman Topchii on 25.07.2021.
//

import Foundation
import CoreData

class TransactionItemManager {
    
    static func createAndGetTransactionItem(transaction: Transaction, type: AccounttingMethod, account: Account, amount: Double, createdByUser: Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) -> TransactionItem {
        
        let createDate = Date()
        
        let item = TransactionItem(context: context)
        item.account = account
        item.amount = amount
        item.transaction = transaction
        item.type = type.rawValue
        item.createdByUser = createdByUser
        item.createDate = createDate
        item.modifiedByUser = createdByUser
        item.modifyDate = createDate
        
        return item
    }
    
    
    static func createTransactionItem(transaction: Transaction, type: AccounttingMethod, account: Account, amount: Double, createdByUser: Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) {
       createAndGetTransactionItem(transaction: transaction, type: type, account: account, amount: amount, createdByUser: createdByUser, createDate: createDate, context: context)
    }
    
   
    static func createAndGetTransactionItem(transaction: Transaction, type: Int16, account: Account, amount: Double, createdByUser: Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) -> TransactionItem {
        
        var type1: AccounttingMethod = .debit
        
        switch type {
        case 0:
            type1 = .credit
        default:
            type1 = .debit
        }
        
        return createAndGetTransactionItem(transaction: transaction, type: type1, account: account, amount: amount, createdByUser: createdByUser, createDate: createDate, context: context)
    }
    
    
    static func createTransactionItem(transaction: Transaction, type: Int16, account: Account, amount: Double, createdByUser: Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) {
       createAndGetTransactionItem(transaction: transaction, type: type, account: account, amount: amount, createdByUser: createdByUser, createDate: createDate, context: context)
    }
    
    
    static func moveTransactionItemsFrom(oldAccount: Account, newAccount: Account, modifiedByUser: Bool = true, modifyDate: Date = Date()){
        for item in oldAccount.transactionItems?.allObjects as! [TransactionItem] {
            item.account = newAccount
            item.modifyDate = modifyDate
            item.modifiedByUser = modifiedByUser
        }
    }
}
