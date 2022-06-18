//
//  AccountEditorRouter.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import UIKit

class AccountEditorRouter: AccountEditorRouterInput {
    
    // MARK: Static methods
    weak var viewController: UIViewController?
    weak var output: AccountEditorRouterOutput?

    let context = CoreDataStack.shared.persistentContainer.viewContext

    func presentAccountTypeModule(accountTypeId: UUID) {

    }

    func presentCurrencyModule(currencyId: UUID?) {
        guard let delegate = output?.currencyDelegate,
              let currencyId = currencyId,
              let currency = CurrencyHelper.getById(currencyId, context: context) else {return}
        let currencyVC = CurrencyViewController(currency: currency, delegate: delegate, mode: .setCurrency)
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

    func presentKeeperModule(keeperId: UUID?) {
        guard let delegate = output?.keeperDelegate else {return}
        let keeperVC = KeeperViewController()
        keeperVC.delegate = delegate
        if let keeperId = keeperId {
            keeperVC.keeper =  KeeperHelper.getById(keeperId, context: context)
        }
//        if parentAccount == moneyRoot {
//            keeperVC.mode = .bank
//        } else if parentAccount == debtorsRoot {
//            keeperVC.mode = .nonCash
//        } else if parentAccount == creditsRoot {
//            keeperVC.mode = .nonCash
//        }
        viewController?.navigationController?.pushViewController(keeperVC, animated: true)
    }

    func showPurchaseOfferModule() {
        viewController?.present(PurchaseOfferViewController(), animated: true, completion: nil)
    }
}
