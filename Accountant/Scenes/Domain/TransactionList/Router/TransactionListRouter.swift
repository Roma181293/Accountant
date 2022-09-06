//
//  TransactionListRouter.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import UIKit
import CoreData

class TransactionListRouter: TransactionListRouterInput {

    weak var viewController: UIViewController?
    weak var output: TransactionListRouterOutput?

    func openMITransactionEditorModule(transactionId: UUID?, context: NSManagedObjectContext) {
        let mITransactionEditorVC = MITransactionEditorAssembly.configure(transactionId: transactionId, context: context)
        viewController?.navigationController?.pushViewController(mITransactionEditorVC, animated: true)
    }

    func deleteAlertFor(indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("Delete",
                                                               tableName: Constants.Localizable.transactionList,
                                                               comment: ""),
                                      message: NSLocalizedString("Do you want to delete transaction?",
                                                                 tableName: Constants.Localizable.transactionList,
                                                                 comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                                      style: .destructive,
                                      handler: {[weak self] (_) in

            self?.output?.deleteActionDidClickFor(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No",
                                                               tableName: Constants.Localizable.transactionList,
                                                               comment: ""), style: .cancel))
        self.viewController?.present(alert, animated: true, completion: nil)
    }

    func showPurchaseOfferModule() {
        viewController?.present(PurchaseOfferViewController(), animated: true, completion: nil)
    }

    func showError(error: Error) {
        var title = NSLocalizedString("Error", tableName: Constants.Localizable.accountEditor, comment: "")
        if error is AppError {
            title = NSLocalizedString("Warning", tableName: Constants.Localizable.accountEditor, comment: "")
        }

        let message = [
            error.localizedDescription,
            (error as? LocalizedError)?.failureReason,
            (error as? LocalizedError)?.recoverySuggestion
        ].compactMap { $0 }
            .joined(separator: "\n\n")

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                               tableName: Constants.Localizable.transactionList,
                                                               comment: ""), style: .default))
        viewController?.present(alert, animated: true, completion: nil)
    }
}
