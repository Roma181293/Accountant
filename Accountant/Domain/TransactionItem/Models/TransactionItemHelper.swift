//
//  TransactionItemHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 17.06.2022.
//

import Foundation

class TransactionItemHelper {
    static func moveTransactionItemsFrom(oldAccount: Account, newAccount: Account, modifiedByUser: Bool = true,
                                         modifyDate: Date = Date()) {
        for item in oldAccount.transactionItemsList {
            item.account = newAccount
            item.modifyDate = modifyDate
            item.modifiedByUser = modifiedByUser
        }
    }

    static func clearItemsWOLinkToTransaction() {
        let context = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        let request = TransactionItem.fetchRequest()
        request.predicate = NSPredicate(format: "\(Schema.TransactionItem.transaction.rawValue) == nil")
        request.sortDescriptors = [NSSortDescriptor(key: "\(Schema.TransactionItem.createDate.rawValue)",
                                                    ascending: true)]
        guard let items = try? context.fetch(request) else {return}
        for item in items {
            context.delete(item)
        }
        try? context.save()
    }
}
