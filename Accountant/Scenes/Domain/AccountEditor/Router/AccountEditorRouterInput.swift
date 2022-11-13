//
//  AccountEditorRouterInput.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation
import UIKit

protocol AccountEditorRouterInput: AnyObject {
    func presentAccountTypeModule(accountTypeId: UUID)
    func presentCurrencyModule(currencyId: UUID?)
    func presentHolderModule(holderId: UUID?)
    func presentKeeperModule(keeperId: UUID?, possibleKeeperType: AccountType.KeeperGroup)
    func showPurchaseOfferModule()
    func closeModule()
    func showError(error: Error)
}
