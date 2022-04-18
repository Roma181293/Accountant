//
//  AccountError.swift
//  Accountant
//
//  Created by Roman Topchii on 11.01.2022.
//

import Foundation

enum AccountError: AppError, Equatable {
    case attributeTypeShouldBeInitializeForRootAccount
    case accountAlreadyExists(name: String)
    case categoryAlreadyExists(name: String)
    case cantRemoveAccountThatUsedInTransactionItem(name: String)
    case cantRemoveCategoryThatUsedInTransactionItem(name: String)
    case creditAccountAlreadyExist(String)  // for cases when creates linked account
    case reservedName(name: String)
    case accountDoesNotExist(name: String)
    case accumulativeAccountCannotBeHiddenWithNonZeroAmount(name: String)
    case linkedAccountHasTransactionItem(name: String)
    case emptyName
}

extension AccountError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .attributeTypeShouldBeInitializeForRootAccount:
            return NSLocalizedString("Attribute \"Type\" should be filled in for the root account", comment: "")
        case let .accountAlreadyExists(name):
            return String(format: NSLocalizedString("Account name \"%@\" is already taken. Please use another name", comment: ""), name)
        case let .categoryAlreadyExists(name):
            return String(format: NSLocalizedString("Category name \"%@\" is already taken. Please use another name", comment: ""), name)
        case .cantRemoveAccountThatUsedInTransactionItem(_):
            return NSLocalizedString("This account cannot be deleted because of existing transactions", comment: "")
        case .cantRemoveCategoryThatUsedInTransactionItem(_):
            return NSLocalizedString("This category cannot be deleted because of existing transactions", comment: "")
        case let .creditAccountAlreadyExist(name):
            return String(format: NSLocalizedString("We create an associated credit account with your credit cards. Credit account \"%@\" already exists", comment: ""), name)
        case let .reservedName(name):
            return NSLocalizedString("Name \"\(name)\" is reserved by the app. Please use another name", comment: "")
        case let .accountDoesNotExist(name):
            return String(format: NSLocalizedString("\"%@\" account does not exist. Please contact support", comment: ""), name)
        case let .accumulativeAccountCannotBeHiddenWithNonZeroAmount(name):
            return String(format: NSLocalizedString("You cannot hide \"%@\" account. Only accounts with 0 balance can be hidden", comment: ""), name)
        case let .linkedAccountHasTransactionItem(name):
            return String(format: NSLocalizedString("Linked account \"%@\" cannot be removed because of existing transactions", comment: ""), name)
        case .emptyName:
            return NSLocalizedString("Please enter name", comment: "")
        }
    }
}
