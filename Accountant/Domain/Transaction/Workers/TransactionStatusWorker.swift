//
//  TransactionStatusWorker.swift
//  Accountant
//
//  Created by Roman Topchii on 03.07.2022.
//

import Foundation

class TransactionStatusWorker {

    class func applyTransactions() {
        processTransactionsStatus(before: Date(), currentStatus: .approved, nextStatus: .applied)
    }

    class func archiveTransactions(before date: Date) {
        do {
            try canBeArchivedOnDate(date)

            processTransactionsStatus(before: date, currentStatus: .approved, nextStatus: .applied)
            processTransactionsStatus(before: date, currentStatus: .applied, nextStatus: .archived)
        } catch {
            
        }
    }

    private class func processTransactionsStatus(before date: Date, currentStatus: Transaction.Status, nextStatus: Transaction.Status) {

        guard (currentStatus == .approved && nextStatus == .applied) ||
              (currentStatus == .applied && nextStatus == .archived)
        else {return}

        let context = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        let modifyDate = Date()

        let request = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: true)]
        request.predicate = NSPredicate(format: "\(Schema.Transaction.date) <= %@ && " +
                                        "\(Schema.Transaction.status) == %@",
                                        argumentArray: [date, currentStatus.rawValue])

        context.performAndWait {
            let transactions = try? context.fetch(request)
            transactions?.forEach({
                $0.status = nextStatus
                $0.modifyDate = modifyDate
                $0.modifiedByUser = false
            })

            context.save(with: .applyApprovedTransactions)
        }
    }

    private class func canBeArchivedOnDate(_ date: Date) throws {
        let context = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        let request = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: true)]
        request.predicate = NSPredicate(format: "\(Schema.Transaction.date) <= %@ && (\(Schema.Transaction.status) = %@ || \(Schema.Transaction.status) = %@)",
                                        argumentArray: [date, Transaction.Status.preDraft.rawValue, Transaction.Status.draft.rawValue])
        request.fetchLimit = 1

        guard let transactionsForArchiving = try? context.fetch(request) else {return}

        if !transactionsForArchiving.isEmpty {
            throw TransactionHelper.HelperError.periodHasUnAppliedTransactions
        }
    }
}
