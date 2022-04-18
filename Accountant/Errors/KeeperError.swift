//
//  KeeperError.swift
//  Accountant
//
//  Created by Roman Topchii on 11.01.2022.
//

import Foundation

enum KeeperError: AppError, Equatable {
    case thisKeeperAlreadyExists
    case thisKeeperUsedInAccounts
    case emptyName
    case keeperNotFound(name: String)
}

extension KeeperError: LocalizedError {
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
