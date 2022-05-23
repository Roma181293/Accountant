//
//  UserBankProfileListPresenter.swift
//  Accountant
//
//  Created by Roman Topchii on 18.05.2022.
//

import Foundation
import UIKit
import CoreData

protocol UserBankProfileListPresenterProtocol: NSFetchedResultsControllerDelegate {
    var router: UserBankProfileListRouterProtocol! {get set}
    func configureView()
    func numberOfUBPs(section: Int) -> Int
    func ubpAt(_ indexPath: IndexPath) -> UserBankProfile
    func tableViewDidSelectRowAt(_ indexPath: IndexPath)
    func deleteAction(for indexPath: IndexPath) -> UIContextualAction
    func changeActiveStatus(for indexPath: IndexPath) -> UIContextualAction
    func viewWillAppear()
    func showError(_ error: Error)
    func showWarning(message: String)
}

class UserBankProfileListPresenter: NSObject, UserBankProfileListPresenterProtocol {

    weak var view: UserBankProfileListViewController!
    var interactor: UserBankProfileListInteractorProtocol!
    var router: UserBankProfileListRouterProtocol!

    required init(view: UserBankProfileListViewController) {
        self.view = view
    }

    func configureView() {
        view.configureView()
    }

    func numberOfUBPs(section: Int) -> Int {
        return interactor.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func ubpAt(_ indexPath: IndexPath) -> UserBankProfile {
        return interactor.fetchedResultsController.object(at: indexPath)
    }

    func tableViewDidSelectRowAt(_ indexPath: IndexPath) {
        router.showBankAccountList(for: ubpAt(indexPath))
    }

    func deleteAction(for indexPath: IndexPath) -> UIContextualAction {
        let delete = UIContextualAction(style: .normal, title: nil) { (_, _, complete) in
            let title = NSLocalizedString("Delete", tableName: Constants.Localizable.userBankProfileListVC, comment: "")
            let message = NSLocalizedString("Do you want delete this bank profile in the app? All related transactions to this bank profile will be kept. Please enter \"MyBudget: Finance keeper\" to confirm this action", tableName: Constants.Localizable.userBankProfileListVC, comment: "") // swiftlint:disable:this line_length

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addTextField()
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",
                                                                   tableName: Constants.Localizable.userBankProfileListVC,
                                                                   comment: ""),
                                          style: .default,
                                          handler: { [weak alert] (_) in
                guard let consent = alert?.textFields?.first?.text else {return}
                self.interactor.delete(at: indexPath, withConsentText: consent)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                                   tableName: Constants.Localizable.userBankProfileListVC,
                                                                   comment: ""),
                                          style: .cancel))
            self.view.present(alert, animated: true, completion: nil)
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")
        return delete
    }

    func changeActiveStatus(for indexPath: IndexPath) -> UIContextualAction {
        let selectedUBP = ubpAt(indexPath)

        let changeActiveStatus = UIContextualAction(style: .normal, title: nil) { (_, _, complete) in
            var title = NSLocalizedString("Activate", tableName: Constants.Localizable.userBankProfileListVC, comment: "")
            var message = NSLocalizedString("Activate this bank profile in the app? Please note that you need manually activate each bank account for this profile", tableName: Constants.Localizable.userBankProfileListVC, comment: "") // swiftlint:disable:this line_length
            if selectedUBP.active {
                title = NSLocalizedString("Deactivate", tableName: Constants.Localizable.userBankProfileListVC,
                                          comment: "")
                message = NSLocalizedString("Do you want deactivate this bank profile in the app? It also deactivate all bank accounts for this profile. Statements for inactive accounts is not loading", tableName: Constants.Localizable.userBankProfileListVC, comment: "")// swiftlint:disable:this line_length
            }
            self.router.showAllertForChangeActiveStatus(title: title, message: message, confirmAction: {
                self.interactor.changeActiveStatus(at: indexPath)
            })
            complete(true)
        }
        if selectedUBP.active {
            changeActiveStatus.backgroundColor = .systemGray
            changeActiveStatus.image = UIImage(systemName: "eye.slash")
        } else {
            changeActiveStatus.backgroundColor = .systemIndigo
            changeActiveStatus.image = UIImage(systemName: "eye")
        }
        return changeActiveStatus
    }

    func viewWillAppear() {
        interactor.reloadData()
    }

    func showError(_ error: Error) {
        router.showError(error)
    }

    func showWarning(message: String) {
        router.showWarning(message)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension UserBankProfileListPresenter: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        view.reloadData()
    }
}
