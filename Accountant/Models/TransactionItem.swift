//
//  TransactionItem.swift
//  Accountant
//
//  Created by Roman Topchii on 25.07.2021.
//

import Foundation
import CoreData

extension TransactionItem {
    
    convenience init(transaction: Transaction, type: AccountingMethod, account: Account, amount: Double, createdByUser: Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
        self.account = account
        self.amount = amount
        self.transaction = transaction
        self.type = type.rawValue
        self.createdByUser = createdByUser
        self.createDate = createDate
        self.modifiedByUser = createdByUser
        self.modifyDate = createDate
    }
    
    static func moveTransactionItemsFrom(oldAccount: Account, newAccount: Account, modifiedByUser: Bool = true, modifyDate: Date = Date()){
        for item in oldAccount.transactionItemsList {
            item.account = newAccount
            item.modifyDate = modifyDate
            item.modifiedByUser = modifiedByUser
        }
    }
}
