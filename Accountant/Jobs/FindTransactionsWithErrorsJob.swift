//
//  FindTransactionsWithErrorsJob.swift
//  Accountant
//
//  Created by Roman Topchii on 28.12.2023.
//

import Foundation

/// This job should be executed for each app launching
class FindTransactionsWithErrorsJob {
    class func execute() {
        do {
            let coreDataStack = CoreDataStack.shared
            let context = CoreDataStack.shared.persistentContainer.viewContext

            var lastExecutionTime = TransactionHelper.getFirstTransactionDate(context: context)
            if let time = UserProfileService.getFindTransactionsWithErrorsJobExecutedLastTime() {
                lastExecutionTime = time
            } else {
                lastExecutionTime = Date()
            }
            guard let lastExecutionTime = lastExecutionTime else {return}

            let request = Transaction.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "\(Schema.Transaction.createDate)",
                                                        ascending: true)]
            request.predicate = NSPredicate(format: "(\(Schema.Transaction.status) == %@ || " +
                                            "\(Schema.Transaction.status) == %@) && " +
                                            "\(Schema.Transaction.modifyDate) >= %@",
                                            argumentArray: [Transaction.Status.applied.rawValue,
                                                            Transaction.Status.archived.rawValue,
                                                            lastExecutionTime as NSDate])
            try context.fetch(request).forEach({ transaction in
                let debitAmount = transaction.itemsList
                    .filter({$0.type == .debit})
                    .map({$0.amountInAccountingCurrency})
                    .reduce(0, +)
                let creditAmount = transaction.itemsList
                    .filter({$0.type == .credit})
                    .map({$0.amountInAccountingCurrency})
                    .reduce(0, +)

                if debitAmount != creditAmount ||
                    transaction.itemsList.first(where: {$0.account == nil}) != nil {
                    transaction.status = .error
                }
            })
            try CoreDataStack.shared.saveContext(context)
            UserProfileService.setFindTransactionsWithErrorsJobExecuted()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
