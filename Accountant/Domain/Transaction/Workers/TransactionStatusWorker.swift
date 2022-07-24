//
//  TransactionStatusWorker.swift
//  Accountant
//
//  Created by Roman Topchii on 03.07.2022.
//

import Foundation
import CoreData

protocol ApplyTransactionStatusWorker {
    func changePersistantContainer(_ persistentContainer: PersistentContainer)
    func applyTransactions()
}

protocol ArchiveTransactionStatusWorker {
    func changePersistantContainer(_ persistentContainer: PersistentContainer)
    func archiveTransactions(before date: Date) throws
}

class TransactionStatusWorker: ApplyTransactionStatusWorker, ArchiveTransactionStatusWorker {

    private(set) var persistentContainer: PersistentContainer

    init(persistentContainer: PersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func changePersistantContainer(_ persistentContainer: PersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func applyTransactions() {
        processTransactionsStatus(before: Date(),
                                  currentStatus: .approved,
                                  nextStatus: .applied,
                                  with: .applyApprovedTransactions)
    }

    func archiveTransactions(before date: Date) throws {
        try canBeArchivedOnDate(date)

        processTransactionsStatus(before: date,
                                  currentStatus: .approved,
                                  nextStatus: .archived,
                                  with: .archivingTransactions)
        processTransactionsStatus(before: date,
                                  currentStatus: .applied,
                                  nextStatus: .archived,
                                  with: .archivingTransactions)
    }

    func unArchiveTransactions(after date: Date) {
        processTransactionsStatus(after: date, currentStatus: .archived, nextStatus: .applied, with: .unarchivingTransactions)
    }

    private func processTransactionsStatus(before date: Date, currentStatus: Transaction.Status,
                                           nextStatus: Transaction.Status,
                                           with contextualInfo: ContextSaveContextualInfo) {

        guard (currentStatus == .approved && nextStatus == .applied) ||
                (currentStatus == .applied && nextStatus == .archived)
        else {return}

        let modifyDate = Date()

        let request = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: true)]
        request.predicate = NSPredicate(format: "\(Schema.Transaction.date) <= %@ && " +
                                        "\(Schema.Transaction.status) == %@",
                                        argumentArray: [date, currentStatus.rawValue])
        let context = persistentContainer.newBackgroundContext()
        context.performAndWait {
            let transactions = try? context.fetch(request)
            transactions?.forEach({
                $0.status = nextStatus
                $0.modifyDate = modifyDate
                $0.modifiedByUser = false
            })

            context.save(with: contextualInfo)
        }
    }

    private func processTransactionsStatus(after date: Date, currentStatus: Transaction.Status,
                                           nextStatus: Transaction.Status,
                                           with contextualInfo: ContextSaveContextualInfo) {

        guard (currentStatus == .archived && nextStatus == .applied)
        else {return}

        let modifyDate = Date()

        let request = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: true)]
        request.predicate = NSPredicate(format: "\(Schema.Transaction.date) > %@ && " +
                                        "\(Schema.Transaction.status) == %@",
                                        argumentArray: [date, currentStatus.rawValue])
        let context = persistentContainer.newBackgroundContext()
        context.performAndWait {
            let transactions = try? context.fetch(request)
            transactions?.forEach({
                $0.status = nextStatus
                $0.modifyDate = modifyDate
                $0.modifiedByUser = false
            })

            context.save(with: contextualInfo)
        }
    }

    private func canBeArchivedOnDate(_ date: Date) throws {

        let request = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: true)]
        request.predicate = NSPredicate(format: "\(Schema.Transaction.date) <= %@ && (\(Schema.Transaction.status) = %@ || \(Schema.Transaction.status) = %@)",
                                        argumentArray: [date, Transaction.Status.preDraft.rawValue, Transaction.Status.draft.rawValue])
        request.fetchLimit = 1

        let context = persistentContainer.newBackgroundContext()
        guard let transactionsForArchiving = try? context.fetch(request) else {return}

        if !transactionsForArchiving.isEmpty {
            throw TransactionHelper.HelperError.periodHasUnAppliedTransactions
        }
    }
}
