//
//  MITransactionEditorRouter.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import UIKit

class MITransactionEditorRouter: MITransactionEditorRouterInput {

    weak var viewController: UIViewController?
    weak var output: MITransactionEditorRouterOutput?

    func getAccount(with requestor: AccountRequestor, parent: Account?, excludeAccountList: [Account]) {
        guard let viewController = viewController else {return}
        let accountNavigatorVC = AccountNavigationViewController()
        accountNavigatorVC.parentAccount = parent
        accountNavigatorVC.requestor = requestor
        accountNavigatorVC.delegate = viewController as? AccountNavigationDelegate
        accountNavigatorVC.showHiddenAccounts = false
        accountNavigatorVC.searchBarIsHidden = false
        accountNavigatorVC.excludeAccountList = excludeAccountList
        viewController.navigationController?.pushViewController(accountNavigatorVC, animated: true)
    }

    func dismiss() {
        viewController?.navigationController?.dismiss(animated: true, completion: nil)
    }

    func popViewController() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func showError(_ error: Error) {
        var title = NSLocalizedString("Error", tableName: Constants.Localizable.monobankVC, comment: "")
        if error is AppError {
            title = NSLocalizedString("Warning", tableName: Constants.Localizable.monobankVC, comment: "")
        }
        let alert = UIAlertController(title: title,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                               tableName: Constants.Localizable.monobankVC,
                                                               comment: ""),
                                      style: .default, handler: { (_) in
            if !(error is AppError) {
                self.viewController?.navigationController?.popViewController(animated: true)
            }
        }))
        viewController?.present(alert, animated: true, completion: nil)
    }

    func showSaveAlert() {
        let saveTitle = NSLocalizedString("Save", tableName: Constants.Localizable.mITransactionEditorVC,
                                          comment: "")
        let message = NSLocalizedString("Save changes?",
                                        tableName: Constants.Localizable.mITransactionEditorVC,
                                        comment: "")
        let alert = UIAlertController(title: saveTitle,
                                      message: message,
                                      preferredStyle: .alert)
        let yesTitle = NSLocalizedString("Yes", tableName: Constants.Localizable.mITransactionEditorVC,
                                         comment: "")
        alert.addAction(UIAlertAction(title: yesTitle,
                                      style: .default, handler: {(_) in
            self.output?.confirmActionDidClick()
        }))
        let cancelTitle = NSLocalizedString("Cancel",
                                            tableName: Constants.Localizable.mITransactionEditorVC,
                                            comment: "")
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        viewController?.present(alert, animated: true, completion: nil)
    }
}
