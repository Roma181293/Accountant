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
                self.routerInput?.showPurchaseOfferVC()
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

        if interactorInput?.isMITransactionModeOn() == true {
            routerInput?.openMITransactionEditorModule(transactionId: nil)
        } else {
            routerInput?.openSimpleTransactionEditorModule(transactionId: nil)
        }
    }

    func editTransaction(at indexPath: IndexPath) {

        guard let transaction = interactorInput?.transactionAt(indexPath) else {return}
        if transaction.itemsList.count != 2 || transaction.status != .applied
            || interactorInput?.isMITransactionModeOn() == true {
            routerInput?.openMITransactionEditorModule(transactionId: transaction.id)
        } else {
            routerInput?.openSimpleTransactionEditorModule(transactionId: transaction.id)
        }
    }

    func proAcceessButtonDidClick() {
        routerInput?.showPurchaseOfferVC()
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

    // FIXME: move to tabbarcontroller
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
