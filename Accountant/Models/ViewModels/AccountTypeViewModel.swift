//
//  AccountTypeViewModel.swift
//  Accountant
//
//  Created by Roman Topchii on 10.06.2022.
//

import Foundation

class AccountTypeViewModel {
    let id: UUID
    let name: String
    let linkedAccountType: AccountTypeViewModel?
    var hasCurrency: Bool
    let hasHolder: Bool
    let hasKeeper: Bool
    let hasInitialBalance: Bool
    let keeperType: AccountType.KeeperType

    init (_ accountType: AccountType) {
        self.id = accountType.id
        self.name = accountType.name
        if let linkedAccountType = accountType.linkedAccountType {
            self.linkedAccountType = AccountTypeViewModel(linkedAccountType)
        } else {
            self.linkedAccountType = nil
        }
        self.hasCurrency = accountType.hasCurrency
        self.hasHolder = accountType.hasHolder
        self.hasKeeper = accountType.hasKeeper
        self.hasInitialBalance = accountType.hasInitialBalance
        self.keeperType = accountType.keeperType
    }
}
