//
//  Keeper extension.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation

extension Keeper {

    var accountsList: [Account] {
        return Array(accounts)
    }

    var userBankProfilesList: [UserBankProfile] {
        return Array(userBankProfiles)
    }

    enum Error: AppError, Equatable {
        case thisKeeperAlreadyExists
        case thisKeeperUsedInAccounts
        case emptyName
        case keeperNotFound(name: String)
    }
}

extension Keeper.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .thisKeeperAlreadyExists:
            return NSLocalizedString("Item with same name already exists", comment: "")
        case .thisKeeperUsedInAccounts:
            return NSLocalizedString("This item is already used on your accounts", comment: "")
        case .emptyName:
            return NSLocalizedString("Please enter name", comment: "")
        case let .keeperNotFound(name):
            return NSLocalizedString("Keeper \"\(name)\" not found", comment: "")
        }
    }
}
