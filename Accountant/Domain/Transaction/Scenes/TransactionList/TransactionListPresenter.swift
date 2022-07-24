//
//  TransactionListPresenter.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import Foundation
import UIKit

class TransactionListPresenter {

    weak var viewInput: TransactionListViewInput?
    var interactorInput: TransactionListInteractorInput?
    var routerInput: TransactionListRouterInput?
}

// MARK: - TransactionListViewOutput
extension TransactionListPresenter: TransactionListViewOutput {

    func numberOfSections() -> Int {
        return interactorInput?.numberOfSections() ?? 1
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return interactorInput?.numberOfRowsInSection(section) ?? 0
    }

    func transactionAt(_ indexPath: IndexPath) -> TransactionViewModel {
        return interactorInput!.transactionAt(indexPath)
    }

    func duplicateTransactionAction(at indexPath: IndexPath) -> UIContextualAction {

        let duplicate = UIContextualAction(style: .normal,
                                           title: NSLocalizedString("Duplicate",
                                                                    tableName: Constants.Localizable.transactionList,
                                                                    comment: "")) { _, _, complete in
            if self.interactorInput?.canDuplicateTransaction() == true {
                self.interactorInput?.duplicateTransaction(at: indexPath)
            } else {
                self.routerInput?.showPurchaseOfferModule()
            }
            complete(true)
        }
        duplicate.backgroundColor = .systemBlue
        duplicate.image = UIImage(systemName: "doc.on.doc")
        return duplicate
    }

    func deleteTransactionAction(at indexPath: IndexPath) -> UIContextualAction {

        let delete = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Delete",
                                                                 tableName: Constants.Localizable.transactionList,
                                                                 comment: "")) { (_, _, complete) in
            self.routerInput?.deleteAlertFor(indexPath: indexPath)
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")
        return delete
    }

    func search(text: String) {
        interactorInput?.search(text: text)
    }

    func createTransaction() {
        routerInput?.openMITransactionEditorModule(transactionId: nil, context: interactorInput!.activeContext())
    }

    func editTransaction(at indexPath: IndexPath) {
        guard let transaction = interactorInput?.transactionAt(indexPath) else {return}
        routerInput?.openMITransactionEditorModule(transactionId: transaction.id,
                                                   context: interactorInput!.activeContext())
    }

    func proAcceessButtonDidClick() {
        routerInput?.showPurchaseOfferModule()
    }

    func syncStatmentsButtonDidClick() {
        interactorInput?.loadStatmentsData()
    }

    func viewWillAppear() {
        if interactorInput?.activeEnvironment() == .test {
            viewInput?.drawTabBarBadge(isHidden: false)
        } else {
            viewInput?.drawTabBarBadge(isHidden: true)
        }

        if interactorInput?.hasActiveBankAccounts() == true {
            viewInput?.drawSyncStatmentsButton(isHidden: false)
        } else {
            viewInput?.drawSyncStatmentsButton(isHidden: true)
        }

        interactorInput?.viewWillAppear()

        guard let userHasPaidAccess = interactorInput?.userHasPaidAccess() else {return}
        viewInput?.drawProAccessButton(isHidden: userHasPaidAccess)
    }
}

// MARK: - TransactionListInteractorOutput
extension TransactionListPresenter: TransactionListInteractorOutput {

    func didFetchTransactions() {
        viewInput?.reloadData()
    }

    func showError(error: Error) {
        routerInput?.showError(error: error)
    }

    // TODO: move to tabbarcontroller
    func environmentDidChange(environment: Environment) {
        if environment == .test {
            viewInput?.drawTabBarBadge(isHidden: false)
        } else {
            viewInput?.drawTabBarBadge(isHidden: true)
        }
    }
}

// MARK: - TransactionListRouterOutput
extension TransactionListPresenter: TransactionListRouterOutput {

    func deleteActionDidClickFor(indexPath: IndexPath) {
        interactorInput?.deleteTransaction(at: indexPath)
    }
}
