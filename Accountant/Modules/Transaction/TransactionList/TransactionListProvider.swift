//
//  TransactionListProvider.swift
//  Accountant
//
//  Created by Roman Topchii on 30.04.2022.
//

import Foundation
import CoreData

class TransactionListProvider {

    private(set) unowned var persistentContainer: PersistentContainer
    private(set) weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?

    init(with persistentContainer: PersistentContainer,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }

    private(set) lazy var fetchedResultsController: NSFetchedResultsController<Transaction> = {
        let fetchRequest = Transaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Transaction.date.rawValue, ascending: false),
                                        NSSortDescriptor(key: "\(Schema.Transaction.createDate.rawValue)", ascending: false)]
        fetchRequest.fetchBatchSize = 20

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                          sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate

        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("###\(#function): Failed to performFetch: \(nserror), \(nserror.userInfo)")
        }

        return controller
    }()

    func duplicateTransaction(at indexPath: IndexPath) {
        let objectID  = fetchedResultsController.object(at: indexPath).objectID
        let context = persistentContainer.newBackgroundContext()

        context.performAndWait {
            guard let original = context.object(with: objectID) as? Transaction else {
                fatalError("###\(#function): Failed to cast object to Transaction")
            }

            let transaction = Transaction(date: original.date, comment: original.comment, context: context)

            for item in original.itemsList {
                _ = TransactionItem(transaction: transaction, type: item.type, account: item.account,
                                    amount: item.amount, context: context)
            }

            context.save(with: .duplicateTransaction)
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
        }
    }

    func search(text: String) {
        var predicate: NSPredicate?
        if !text.isEmpty {
            predicate = NSPredicate(format: "\(Schema.Transaction.items).\(Schema.TransactionItem.account).\(Schema.Account.path) CONTAINS[c] %@ || comment CONTAINS[c] %@",
                                        argumentArray: [text, text])
        } else {
            predicate = nil
        }
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("###\(#function): Failed to performFetch: \(nserror), \(nserror.userInfo)")
        }
    }
}
