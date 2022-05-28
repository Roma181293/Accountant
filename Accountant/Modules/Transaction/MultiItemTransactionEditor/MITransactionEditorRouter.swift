//
//  MITransactionEditorRouter.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import UIKit

protocol MITransactionEditorRouterProtocol: AnyObject {
    var navigationController: UINavigationController? { get set }
    func getAccount(with delegate: AccountRequestor, delegate: AccountNavigationDelegate, parent: Account?, excludeAccountList: [Account])
    func dismiss()
    func showError(_ error: Error, in viewController: UIViewController)
}

protocol MITransactionEditorCreator: AnyObject {
    var transaction: Transaction? { get set }
    func present(navigationController: UINavigationController)
}

class MITransactionEditorRouter: MITransactionEditorRouterProtocol, MITransactionEditorCreator {

    weak var navigationController: UINavigationController?

    var transaction: Transaction?

    func present(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.pushViewController(MITransactionEditorConfigurator.configure(router: self), animated: true)
    }

    func getAccount(with requestor: AccountRequestor, delegate: AccountNavigationDelegate, parent: Account?, excludeAccountList: [Account]) {
        guard let navigationController = navigationController else {return}
        let accountNavigatorVC = AccountNavigationViewController()
        accountNavigatorVC.parentAccount = parent
        accountNavigatorVC.requestor = requestor
        accountNavigatorVC.delegate = delegate
        accountNavigatorVC.showHiddenAccounts = false
        accountNavigatorVC.searchBarIsHidden = false
        accountNavigatorVC.excludeAccountList = excludeAccountList
        navigationController.pushViewController(accountNavigatorVC, animated: true)
    }

    func dismiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func showError(_ error: Error, in viewController: UIViewController) {
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
                self.navigationController?.popViewController(animated: true)
            }
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
}
