//
//  CurrencyProvider.swift
//  Accountant
//
//  Created by Roman Topchii on 20.04.2022.
//

import Foundation
import CoreData

class CurrencyProvider {

    private(set) var persistentContainer: NSPersistentContainer
    private(set) weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?

    init(with persistentContainer: NSPersistentContainer,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate? = nil) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }

    lazy var fetchedResultsController: NSFetchedResultsController<Currency> = {
        let fetchRequest = Currency.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Currency.code.rawValue, ascending: true)]
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

    func addCurrency(code: String, iso4217: Int16, name: String?, createdByUser: Bool = true,
                     createDate: Date = Date(), context: NSManagedObjectContext, shouldSave: Bool = true) {
        context.performAndWait {
            _ = Currency(code: code, iso4217: iso4217, name: name, createdByUser: createdByUser,
                         createDate: createDate, context: context)
            if shouldSave {
                context.save(with: .addCurrency)
            }
        }
    }

    func setAccountingCurrency(indexPath: IndexPath, modifyDate: Date = Date(),
                               modifiedByUser: Bool = true, context: NSManagedObjectContext, shouldSave: Bool = true) {
        context.performAndWait {
            let oldCurr = Currency.getAccountingCurrency(context: context)
            let newCurr = fetchedResultsController.object(at: indexPath)
            if let oldCurr = oldCurr {
                Account.changeCurrencyForBaseAccounts(to: newCurr, modifyDate: modifyDate,
                                                      modifiedByUser: modifiedByUser, context: context)
                oldCurr.isAccounting = false
                oldCurr.modifyDate = modifyDate
                oldCurr.modifiedByUser = modifiedByUser

                newCurr.isAccounting = true
                newCurr.modifyDate = modifyDate
                newCurr.modifiedByUser = modifiedByUser
            } else {
                Account.changeCurrencyForBaseAccounts(to: newCurr, context: context)
                newCurr.isAccounting = true
                newCurr.modifyDate = modifyDate
                newCurr.modifiedByUser = modifiedByUser
            }
            if shouldSave {
                context.save(with: .setAccountingCurrency)
            }
        }
    }
}
