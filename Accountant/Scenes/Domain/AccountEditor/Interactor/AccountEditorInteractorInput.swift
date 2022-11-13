//
//  AccountEditorInteractorInput.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import Foundation

protocol AccountEditorInteractorInput: CurrencyReceiverDelegate, KeeperReceiverDelegate, HolderReceiverDelegate, AccountTypeReciverDelegate {
    var currency: CurrencyViewModel? {get}
    var keeper: KeeperViewModel? {get}
    var possibleKeeperType: AccountType.KeeperGroup {get}
    var holder: HolderViewModel? {get}
    var accountType: AccountTypeViewModel {get}
    var canBeRenamed: Bool {get}
    var mode: AccountEditorWorker.Mode {get}
    var isUserHasPaidAccess: Bool {get}
    func provideData()
    func setName(_ name: String)
    func setBalance(_ balance: Double)
    func setLinkedAccountBalance(_ creditLimit: Double)
    func setExchangeRate(_ exchangeRate: Double)
    func balanceDateDidChanged(_ date: Date)
    func saveChanges()
}
