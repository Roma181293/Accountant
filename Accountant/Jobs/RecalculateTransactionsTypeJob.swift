//
//  RecalculateTransactionsTypeJob.swift
//  Accountant
//
//  Created by Roman Topchii on 29.12.2023.
//

import Foundation

/// This job is usefull after data migration to avoid complex transaction type calculation during migration
class RecalculateTransactionsTypeJob {
    class func execute() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        context.perform({
            let request = Transaction.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: true)]
            request.predicate = NSPredicate(format: "\(Schema.Transaction.type) = %@",
                                            argumentArray: [Transaction.TypeEnum.other.rawValue])
            try? context.fetch(request)
                .forEach {
                    $0.calculateType()
                }
            try? context.save()
        })
    }
}
