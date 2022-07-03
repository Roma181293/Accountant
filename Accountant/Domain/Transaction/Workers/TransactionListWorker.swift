//
//  TransactionListWorker.swift
//  Accountant
//
//  Created by Roman Topchii on 30.04.2022.
//

import Foundation
import CoreData

protocol TransactionListWorkerDelegate: AnyObject {
    func didFetchTransactions()
    func showError(error: Error)
}

class TransactionListWorker: NSObject {

    weak var delegate: TransactionListWorkerDelegate?

    private(set) unowned var persistentContainer: PersistentContainer
    private(set) var mainContext: NSManagedObjectContext

    init(with persistentContainer: PersistentContainer) {
        self.persistentContainer = persistentContainer
        self.mainContext = persistentContainer.viewContext
    }

    private(set) lazy var fetchedResultsController: NSFetchedResultsController<Transaction> = {
        let fetchRequest = Transaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: false),
                                        NSSortDescriptor(key: Schema.Transaction.createDate.rawValue, ascending: false)]
        fetchRequest.fetchBatchSize = 20

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: mainContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()

    func changePersistentContainer(_ persistentContainer: PersistentContainer) {
        self.persistentContainer = persistentContainer
        let fetchRequest = Transaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: false),
                                        NSSortDescriptor(key: Schema.Transaction.createDate.rawValue, ascending: false)]
        fetchRequest.fetchBatchSize = 20

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: mainContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
    }

    func provideData() {
        do {
            try fetchedResultsController.performFetch()
            delegate?.didFetchTransactions()
        } catch {
            delegate?.showError(error: error)
        }
    }

    func duplicateTransaction(at indexPath: IndexPath) {
        let objectID  = fetchedResultsController.object(at: indexPath).objectID
        let context = persistentContainer.newBackgroundContext()

        context.performAndWait {
            guard let original = context.object(with: objectID) as? Transaction else {
                fatalError("###\(#function): Failed to cast object to Transaction")
            }

            let transaction = Transaction(date: original.date, status: original.status,
                                          comment: original.comment, context: context)

            transaction.type = original.type

            for item in original.itemsList {
                _ = TransactionItem(transaction: transaction, type: item.type, account: item.account,
                                    amount: item.amount, context: context)
            }

            context.save(with: .duplicateTransaction)
            // FIXME: - investigate why controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) didnt call
            provideData()
        }
    }

    func deleteTransaction(at indexPath: IndexPath) {
        let objectID  = fetchedResultsController.object(at: indexPath).objectID
        let context = persistentContainer.newBackgroundContext()

        context.performAndWait {
            guard let transaction = context.object(with: objectID) as? Transaction else {
                fatalError("###\(#function): Failed to cast object to Transaction")
            }

            for item in transaction.itemsList {
                context.delete(item)
            }
            context.delete(transaction)

            context.save(with: .deleteTransaction)

            // FIXME: - investigate why controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) didnt call
            provideData()
        }
    }

   
    func search(text: String) {
        var predicate: NSPredicate?
        if !text.isEmpty {
            predicate = NSPredicate(format: "\(Schema.Transaction.items).\(Schema.TransactionItem.account).\(Schema.Account.path) CONTAINS[c] %@ || \(Schema.Transaction.comment) CONTAINS[c] %@", // swiftlint:disable:this line_length
                                    argumentArray: [text, text])
        } else {
            predicate = nil
        }
        fetchedResultsController.fetchRequest.predicate = predicate

        provideData()
    }

    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func transactionAt(_ indexPath: IndexPath) -> TransactionViewModel {
        return TransactionViewModel(transaction: fetchedResultsController.object(at: indexPath))
    }

    


}

extension TransactionListWorker: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didFetchTransactions()
    }
}
