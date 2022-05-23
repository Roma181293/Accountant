//
//  UserBankProfileListInteractor.swift
//  Accountant
//
//  Created by Roman Topchii on 18.05.2022.
//

import Foundation
import CoreData

protocol UserBankProfileListInteractorProtocol: AnyObject {
    var fetchedResultsController: NSFetchedResultsController<UserBankProfile> { get }
    func reloadData()
    func changeActiveStatus(at indexPath: IndexPath)
    func delete(at indexPath: IndexPath, withConsentText consentText: String) 
}

class UserBankProfileListInteractor: UserBankProfileListInteractorProtocol {

    unowned var presenter: UserBankProfileListPresenterProtocol

    private(set) var persistentContainer = CoreDataStack.shared.persistentContainer
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    private (set) lazy var fetchedResultsController: NSFetchedResultsController<UserBankProfile> = {
        let fetchRequest = UserBankProfile.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.UseBankProfile.id.rawValue, ascending: true)]
        fetchRequest.fetchBatchSize = 20
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context,
                                          sectionNameKeyPath: nil, cacheName: nil)
    }()

    required init(presenter: UserBankProfileListPresenterProtocol) {
        self.presenter = presenter
        fetchedResultsController.delegate = presenter
        reloadData()

    }

    func reloadData() {
        do {
            try fetchedResultsController.performFetch()
//            tableView.reloadData()
        } catch let error {
            presenter.showError(error)
        }

    }

    func changeActiveStatus(at indexPath: IndexPath) {
        let objectID  = fetchedResultsController.object(at: indexPath).objectID
        let context = persistentContainer.newBackgroundContext()

        context.performAndWait {
            guard let object = context.object(with: objectID) as? UserBankProfile else {
                fatalError("###\(#function): Failed to cast object to UserBankProfile")
            }

            if object.active {
                object.active = false
                object.bankAccountsList.forEach({
                    $0.active = false
                })
            } else {
                object.active = true
            }

            context.save(with: .changeUBPActiveStatus)
        }
    }

    func delete(at indexPath: IndexPath, withConsentText consentText: String) {
        if consentText == "MyBudget: Finance keeper" {
            let objectID  = fetchedResultsController.object(at: indexPath).objectID
            let context = persistentContainer.newBackgroundContext()

            context.performAndWait {
                guard let object = context.object(with: objectID) as? UserBankProfile else {
                    fatalError("###\(#function): Failed to cast object to UserBankProfile")
                }
                object.bankAccountsList.forEach({
                    context.delete($0)
                })
                context.delete(object)
                context.save(with: .deleteUserBankProfile)
            }
        } else {
            presenter.showWarning(message: String(format: NSLocalizedString("Consent text \"%@\" is not equal to \"MyBudget: Finance keeper\"",
                                                                            tableName: Constants.Localizable.userBankProfileListVC,
                                                                            comment: ""), consentText))
        }
    }
}
