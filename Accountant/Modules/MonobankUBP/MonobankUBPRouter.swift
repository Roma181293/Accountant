//
//  MonobankUBPRouter.swift
//  Accountant
//
//  Created by Roman Topchii on 14.05.2022.
//

import UIKit
import SafariServices

protocol MonobankUBPRouterProtocol: AnyObject {
    func showHolderList(with selected: Holder?, delegate: HolderReceiverDelegate)
    func openWeb(url: URL)
    func showError(_ errror: Error)
    func showWarning(_ message: String)
    func close()
}

class MonobankUBPRouter: MonobankUBPRouterProtocol {
    weak var viewController: MonobankUBPViewController!

    init(viewController: MonobankUBPViewController) {
        self.viewController = viewController
    }

    func showHolderList(with selected: Holder?, delegate: HolderReceiverDelegate) {
        let holderVC = HolderViewController()
        holderVC.delegate = delegate
        holderVC.holder = selected
        viewController.navigationController?.pushViewController(holderVC, animated: true)

    }

    func openWeb(url: URL) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let webVC = WebViewController(url: url, configuration: config)
        viewController.present(webVC, animated: true, completion: nil)
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
