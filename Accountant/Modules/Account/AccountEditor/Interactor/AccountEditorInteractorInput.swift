//
//  AccountEditorInteractorInput.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation

protocol AccountEditorInteractorInput: CurrencyReceiverDelegate, KeeperReceiverDelegate, HolderReceiverDelegate {
    var currencyId: UUID { get }
    var keeperId: UUID? { get }
    var holderId: UUID? { get }
    func setName(_ name: String)
    func setBalance(_ balance: Double)
    func setLinkedAccountBalance(_ creditLimit: Double)
    func setExchangeRate(_ exchangeRate: Double)
}
