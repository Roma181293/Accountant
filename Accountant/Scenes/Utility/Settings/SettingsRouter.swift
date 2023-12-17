//
//  SettingsRouter.swift
//  Accountant
//
//  Created by Roman Topchii on 08.05.2022.
//

import UIKit
import SafariServices
import UniformTypeIdentifiers

enum SetttingsRoutingDestination: RoutingDestinationBase {
    case offerVC
    case startAccounting(UIViewController?)
    case archive
    case accountNavVC
    case bankProfilesVC
    case importTransactionVC(fromFile: URL)
    case privacyPolicy
    case termsOfUse
    case error(Error)
    case share(filesToShare: [URL])
    case openDocumentPickerVC
    case userGuide
    case exchange
}

class SettingsRouter: Router {
    typealias RoutingDestination = SetttingsRoutingDestination

    weak var viewController: UIViewController?

    func route(to destination: RoutingDestination) { // swiftlint:disable:this function_body_length cyclomatic_complexity line_length
        switch destination {
        case .offerVC:
            viewController?.navigationController?.present(PurchaseOfferViewController(), animated: true)
        case .startAccounting(let parent):
            let startAccountingVC = StartAccountingViewController()
            startAccountingVC.parentVC = parent
            viewController?.navigationController?.pushViewController(startAccountingVC, animated: true)
        case .archive:
            viewController?.navigationController?.pushViewController(ArchivingManagerViewController(), animated: true)
        case .accountNavVC:
            let accNavVC = AccountNavigationViewController()
            accNavVC.searchBarIsHidden = false
            viewController?.navigationController?.pushViewController(accNavVC, animated: true)
        case .bankProfilesVC:
            viewController?.navigationController?.pushViewController(UserBankProfileListViewController(), animated: true)
        case .importTransactionVC(let url):
            let importTranVC = ImportTransactionViewController(fileURL: url)
            viewController?.navigationController?.pushViewController(importTranVC, animated: true)
        case .privacyPolicy:
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let url = URL(string: Constants.URL.privacyPolicy)
            let webVC = WebViewController(url: url!, configuration: config)
            viewController?.present(webVC, animated: true, completion: nil)
        case .termsOfUse:
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let url = URL(string: Constants.URL.termsOfUse)
            let webVC = WebViewController(url: url!, configuration: config)
            viewController?.present(webVC, animated: true, completion: nil)
        case .error(let error):
            var title = NSLocalizedString("Error", tableName: Constants.Localizable.settingsVC, comment: "")
            if error as? AppError != nil {
                title = NSLocalizedString("Warning", tableName: Constants.Localizable.settingsVC, comment: "")
            }
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                                   tableName: Constants.Localizable.settingsVC,
                                                                   comment: ""),
                                          style: .default))
            viewController?.present(alert, animated: true, completion: nil)
        case .share(filesToShare: let filesToShare):
            let activityVC = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            viewController?.present(activityVC, animated: true, completion: nil)
        case .openDocumentPickerVC:
            guard let delegate = viewController as? UIDocumentPickerDelegate else {return}
            if #available(iOS 14.0, *) {
                let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text], asCopy: true)
                importMenu.delegate = delegate
                importMenu.modalPresentationStyle = .formSheet
                viewController?.present(importMenu, animated: true, completion: nil)
            } else {
                let importMenu = UIDocumentPickerViewController(documentTypes: ["text"], in: .import)
                importMenu.delegate = delegate
                importMenu.modalPresentationStyle = .formSheet
                viewController?.present(importMenu, animated: true, completion: nil)
            }
        case .userGuide:
            viewController?.present(InstructionViewController(), animated: true, completion: nil)
        case .exchange:
            viewController?.navigationController?.pushViewController(ExchangeTableViewController(), animated: true)
        }
    }
}
