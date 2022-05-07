//
//  HolderProvider.swift
//  Accountant
//
//  Created by Roman Topchii on 20.04.2022.
//

import Foundation
import CoreData

class HolderProvider {

    private(set) var persistentContainer: NSPersistentContainer
    private(set) weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?

    init(with persistentContainer: NSPersistentContainer,
         fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
        self.persistentContainer = persistentContainer
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }

    private(set) lazy var fetchedResultsController: NSFetchedResultsController<Holder> = {
        let fetchRequest = Holder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Holder.name.rawValue, ascending: true)]
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

    func numberOfHolders(withName name: String) -> Int {
        let fetchRequest: NSFetchRequest<Holder> = Holder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Holder.name.rawValue) == %@", name)

        let number = try? persistentContainer.viewContext.count(for: fetchRequest)
        return number ?? 0
    }

    func numberOfHolders(withIcon icon: String) -> Int {
        let fetchRequest: NSFetchRequest<Holder> = Holder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Holder.icon.rawValue) == %@", icon)

        let number = try? persistentContainer.viewContext.count(for: fetchRequest)
        return number ?? 0
    }

    func addHolder(name: String, icon: String, createdByUser: Bool = true, createDate: Date = Date(),
                   context: NSManagedObjectContext, shouldSave: Bool = true) {
        context.performAndWait {
            _ = Holder(name: name, icon: icon, createdByUser: createdByUser, createDate: createDate, context: context)

            if shouldSave {
                context.save(with: .addHolder)
            }
        }
    }

    func editHolder(at indexPath: IndexPath, newName: String, newIcon: String, shouldSave: Bool = true) {
        let context = fetchedResultsController.managedObjectContext
        let holder = fetchedResultsController.object(at: indexPath)

        if holder.name != newName || holder.icon != newIcon {
            holder.name = newName
            holder.icon = newIcon
            holder.modifyDate = Date()
            holder.modifiedByUser = true
            context.performAndWait {
                if shouldSave {
                    context.save(with: .editHolder)
                }
            }
        }
    }

    func deleteHolder(at indexPath: IndexPath, shouldSave: Bool = true) {
        let context = fetchedResultsController.managedObjectContext
        context.performAndWait {
            context.delete(fetchedResultsController.object(at: indexPath))
            if shouldSave {
                context.save(with: .deleteHolder)
            }
        }
    }
}
