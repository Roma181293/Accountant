//
//  AccountEditorViewOutput.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation

protocol AccountEditorViewOutput: AnyObject {
    func confirmButtonDidTouch()
    func currencyButtonDidTouch()
    func keeperButtonDidTouch()
    func holderButtonDidTouch()
    func typeButtonDidTouch()
    func nameChangedTo(_ name: String)
    func balanceChangedTo(_ balance: String)
    func creditLimitChangedTo(_ creditLimit: String)
    func exchangeRateChangedTo(_ exchangeRate: String)
}
