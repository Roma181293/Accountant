//
//  AccountTypeService.swift
//  Accountant
//
//  Created by Roman Topchii on 19.06.2022.
//

import Foundation
import CoreData

protocol AccountTypeServiceDelegate: AnyObject {
    func didFetch()
    func showError(error: Error)
}

class AccountTypeService: NSObject {

    weak var delegate: AccountTypeServiceDelegate?

    private(set) unowned var persistentContainer: PersistentContainer
    private(set) var parentTypeId: UUID?
    var parentType: AccountTypeViewModel? {
        if let parentTypeId = parentTypeId, let parentType = AccountTypeHelper.getBy(parentTypeId, context: persistentContainer.viewContext) {
            return AccountTypeViewModel(parentType)
        } else {
            return nil
        }
    }

    init(with persistentContainer: PersistentContainer, parentTypeId: UUID?) {
        self.persistentContainer = persistentContainer
        self.parentTypeId = parentTypeId
    }

    private(set) lazy var fetchedResultsController: NSFetchedResultsController<AccountType> = {
        let fetchRequest = AccountType.fetchRequest()
        if let parentTypeId = parentTypeId {
            fetchRequest.predicate = NSPredicate(format: "(ANY \(Schema.AccountType.parents).\(Schema.AccountType.id.rawValue) = %@) && \(Schema.AccountType.canBeCreatedByUser) = %@",
                                                 argumentArray: [parentTypeId.uuidString, true])
        } else {
            fetchRequest.predicate = NSPredicate(format: "\(Schema.AccountType.parents.rawValue).@COUNT = %@ && \(Schema.AccountType.canBeCreatedByUser) = %@",
                                                 argumentArray: [0, true])
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.AccountType.name.rawValue, ascending: false)]
        fetchRequest.fetchBatchSize = 20

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()

    func changePersistentContainer(_ persistentContainer: PersistentContainer) {
        self.persistentContainer = persistentContainer
        let fetchRequest = AccountType.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.AccountType.name.rawValue, ascending: false)]
        fetchRequest.fetchBatchSize = 20


        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: persistentContainer.viewContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
    }

    func provideData() {
        do {
            try fetchedResultsController.performFetch()
            delegate?.didFetch()
        } catch {
            delegate?.showError(error: error)
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

    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func entityAt(_ indexPath: IndexPath) -> AccountTypeViewModel {
        return AccountTypeViewModel(fetchedResultsController.object(at: indexPath))
    }
}

extension AccountTypeService: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didFetch()
    }
}
