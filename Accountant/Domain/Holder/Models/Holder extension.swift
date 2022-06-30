//
//  Holder extension.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation

extension Holder {

    var accountsList: [Account] {
        return Array(accounts)
    }

    enum Error: AppError, Equatable {
        case thisHolderAlreadyExists
        case thisHolderUsedInAccounts
        case emptyName
        case emptyIcon
    }
}

extension Holder.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .thisHolderAlreadyExists:
            return NSLocalizedString("Holder with the same name already exists", comment: "")
        case .thisHolderUsedInAccounts:
            return NSLocalizedString("This holder is already used on your accounts", comment: "")
        case .emptyName:
            return NSLocalizedString("Please enter name", comment: "")
        case .emptyIcon:
            return NSLocalizedString("Please enter emoji icon", comment: "")
        }
    }
}
