//
//  UserBankProfileListRouter.swift
//  Accountant
//
//  Created by Roman Topchii on 18.05.2022.
//

import UIKit

protocol UserBankProfileListRouterProtocol: AnyObject {
    func showBankAccountList(for userBankProfile: UserBankProfile)
    func showAllertForChangeActiveStatus(title: String, message:String, confirmAction: @escaping (() -> Void))
//    func showAllertForDelete(title: String, message:String, confirmAction: @escaping (() -> Void))
    func showError(_ error: Error)
    func showWarning(_ message: String)
    func close()
}

class UserBankProfileListRouter: UserBankProfileListRouterProtocol {

    weak var viewController: UserBankProfileListViewController!

    init(viewController: UserBankProfileListViewController) {
        self.viewController = viewController
    }

    func showBankAccountList(for userBankProfile: UserBankProfile) {
        let bankAccountVC = BankAccountTableViewController()
        bankAccountVC.userBankProfile = userBankProfile
        viewController.navigationController?.pushViewController(bankAccountVC, animated: true)
    }

    func showAllertForChangeActiveStatus(title: String, message:String, confirmAction: @escaping (() -> Void)) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",
                                                               tableName: Constants.Localizable.userBankProfileListVC,
                                                               comment: ""),
                                      style: .default, handler: { (_) in
            confirmAction()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                               tableName: Constants.Localizable.userBankProfileListVC,
                                                               comment: ""),
                                      style: .cancel))
        viewController.present(alert, animated: true, completion: nil)
    }

//    func showAllertForDelete(title: String, message:String, confirmAction: @escaping (() -> Void)) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addTextField()
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",
//                                                               tableName: Constants.Localizable.userBankProfileVC,
//                                                               comment: ""),
//                                      style: .destructive,
//                                      handler: { [weak alert] (_) in
//            guard let consent = alert?.textFields?.first?.text else {return}
//            confirmAction()
//        }))
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
//                                                               tableName: Constants.Localizable.userBankProfileVC,
//                                                               comment: ""),
//                                      style: .cancel))
//        viewController.present(alert, animated: true, completion: nil)
//    }

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
                                      style: .default, handler: { [weak viewController](_) in
            if !(error is AppError) {
                viewController?.navigationController?.popViewController(animated: true)
            }
        }))
        viewController.present(alert, animated: true, completion: nil)
    }

    func showWarning(_ message: String) {
        let title = NSLocalizedString("Warning", tableName: Constants.Localizable.monobankVC, comment: "")
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                               tableName: Constants.Localizable.monobankVC,
                                                               comment: ""),
                                      style: .default))
        viewController.present(alert, animated: true, completion: nil)
    }

    func close() {
        viewController.navigationController?.popViewController(animated: true)
    }
}
