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
    func colorNameTextField(_ color: UIColor)
    func typeDidSet(_ accountType: AccountTypeViewModel?)
    func currencyDidSet(_ currency: CurrencyViewModel?)
    func holderDidSet(_ holder: HolderViewModel?)
    func keeperDidSet(_ keeper: KeeperViewModel?)

//    func currencyIsAccounting(_ isAccounting: Bool)
}
