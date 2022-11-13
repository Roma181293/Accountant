//
//  AccountEditorViewOutput.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation

protocol AccountEditorViewOutput: AnyObject {
    func viewDidLoad()
    func confirmButtonDidTouch()
    func currencyButtonDidTouch()
    func keeperButtonDidTouch()
    func holderButtonDidTouch()
    func typeButtonDidTouch()
    func nameChangedTo(_ name: String)
    func setBalance(_ balance: String)
    func setLinkedAccountBalance(_ balance: String)
    func setExhangeRate(_ amount: String)
    func balanceDateDidChanged(_ date: Date)
}
