//
//  AccountEditorViewInput.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation
import UIKit

protocol AccountEditorViewInput: AnyObject {
    func configureView()
    func colorNameTextFieldForState(_ isValid: Bool)
    func typeDidSet(_ accountType: AccountTypeViewModel?, isSingle: Bool, mode: AccountEditorService.Mode)
    func nameDidSet(_ name: String)
    func currencyDidSet(_ currency: CurrencyViewModel?, accountingCurrency: CurrencyViewModel)
    func holderDidSet(_ holder: HolderViewModel?)
    func keeperDidSet(_ keeper: KeeperViewModel?)
    func rateDidSet(_ rate: Double?)
    func setTitle(_ title: String)
    func configureComponentsForEditMode()
}
