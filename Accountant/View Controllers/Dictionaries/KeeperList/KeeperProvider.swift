//
//  KeeperProvider.swift
//  Accountant
//
//  Created by Roman Topchii on 19.04.2022.
//

import Foundation
import CoreData

class KeeperProvider {

    enum Mode {
        case bank
        case person
        case nonCash
    }

    private(set) var mode: Mode?
    private(set) var persistentContainer: NSPersistentContainer
    private(set) weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?

    init(with persistentContainer: NSPersistentContainer,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?, mode: Mode?) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
        self.mode = mode
    }

    lazy var fetchedResultsController: NSFetchedResultsController<Keeper> = {
        let fetchRequest = Keeper.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Keeper.name.rawValue, ascending: true)]
        switch mode {
        case nil:
            break
        case .bank:
            fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.type.rawValue) == %i",
                                                 Keeper.TypeEnum.bank.rawValue)
        case .person:
            fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.type.rawValue) == %i",
                                                 Keeper.TypeEnum.person.rawValue)
        case .nonCash:
            fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.type.rawValue) != %i",
                                                 Keeper.TypeEnum.cash.rawValue)
        }
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

    func numberOfKeepers(with keeperName: String) -> Int {
        let fetchRequest: NSFetchRequest<Keeper> = Keeper.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.name.rawValue) == %@", keeperName)

        let number = try? persistentContainer.viewContext.count(for: fetchRequest)
        return number ?? 0
    }

    func addKeeper(name: String, type: Keeper.TypeEnum, createdByUser: Bool = true, createDate: Date = Date(),
                   context: NSManagedObjectContext, shouldSave: Bool = true) {
        context.performAndWait {
            _ = Keeper(name: name, type: type, createdByUser: createdByUser, createDate: createDate, context: context)

            if shouldSave {
                context.save(with: .addKeeper)
            }
        }
    }

    func renameKeeper(at indexPath: IndexPath, newName: String, shouldSave: Bool = true) {
        let context = fetchedResultsController.managedObjectContext
        let keeper = fetchedResultsController.object(at: indexPath)

        if keeper.name != newName {
            keeper.name = newName
            keeper.modifyDate = Date()
            keeper.modifiedByUser = true
            context.performAndWait {
                if shouldSave {
                    context.save(with: .renameKeeper)
                }
            }
        }
    }

    func deleteKeeper(at indexPath: IndexPath, shouldSave: Bool = true) {
        let context = fetchedResultsController.managedObjectContext
        context.performAndWait {
            context.delete(fetchedResultsController.object(at: indexPath))
            if shouldSave {
                context.save(with: .deleteKeeper)
            }
        }
    }
}
