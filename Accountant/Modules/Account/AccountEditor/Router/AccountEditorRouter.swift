//
//  AccountEditorRouter.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import UIKit

class AccountEditorRouter: AccountEditorRouterInput {
    
    weak var viewController: UIViewController?
    weak var output: AccountEditorRouterOutput?

    let context = CoreDataStack.shared.persistentContainer.viewContext

    func presentAccountTypeModule(accountTypeId: UUID) {
        let vc = AccountTypeNavigationViewController(parentTypeId: accountTypeId)
        vc.delegate = output?.accountTypeDelegate
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func presentCurrencyModule(currencyId: UUID?) {
        guard let delegate = output?.currencyDelegate,
              let currencyId = currencyId,
              let currency = CurrencyHelper.getById(currencyId, context: context) else {return}
        let currencyVC = CurrencyViewController()
        currencyVC.currency = currency
        currencyVC.delegate = delegate
        viewController?.navigationController?.pushViewController(currencyVC, animated: true)
    }

    func presentHolderModule(holderId: UUID?) {
        guard let delegate = output?.holderDelegate else {return}
        let holderVC = HolderViewController()
        holderVC.delegate = delegate
        if let holderId = holderId {
            holderVC.holder = HolderHelper.getById(holderId, context: context)
        }
        viewController?.navigationController?.pushViewController(holderVC, animated: true)
    }

    func presentKeeperModule(keeperId: UUID?, possibleKeeperType: AccountType.KeeperType) {
        guard let delegate = output?.keeperDelegate else {return}
        let keeperVC = KeeperViewController()
        keeperVC.delegate = delegate
        if let keeperId = keeperId {
            keeperVC.keeper =  KeeperHelper.getById(keeperId, context: context)
        }
        switch possibleKeeperType {
        case .cash:
            keeperVC.mode = .cash
        case .bank:
            keeperVC.mode = .bank
        case .nonCash:
            keeperVC.mode = .nonCash
        case .any:
            keeperVC.mode = .all
        case .none:
            break
        }
        if possibleKeeperType == .bank {
            keeperVC.mode = .bank
        } else if possibleKeeperType == .nonCash {
            keeperVC.mode = .nonCash
        }
        viewController?.navigationController?.pushViewController(keeperVC, animated: true)
    }

    func showPurchaseOfferModule() {
        viewController?.present(PurchaseOfferViewController(), animated: true, completion: nil)
    }

    func closeModule() {
        viewController?.navigationController?.popViewController(animated: true)
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
