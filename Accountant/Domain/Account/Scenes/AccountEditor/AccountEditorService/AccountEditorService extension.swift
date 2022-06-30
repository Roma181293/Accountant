//
//  AccountEditorService extension.swift
//  Accountant
//
//  Created by Roman Topchii on 27.06.2022.
//

import Foundation

extension AccountEditorService {

    enum Error: AppError {
        case emptyName
        case reservedName
        case accountNameAlreadyExists(String)
        case categoryNameAlreadyExists(String)
        case paretnTypeDoesntHasChildWithId
        case currencyWithIdNotFound
        case holderWithIdNotFound
        case keeperWithIdNotFound
        case emptyExchangeRate
        case zeroRateValue
    }
}

extension AccountEditorService.Error: LocalizedError {

    private var tableName: String {
        return Constants.Localizable.accountEditorService
    }

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return NSLocalizedString("Empty name", tableName: tableName, comment: "")
        case .reservedName:
            return NSLocalizedString("Reserved name", tableName: tableName, comment: "")
        case let .accountNameAlreadyExists(name):
            return String(format: NSLocalizedString("Account name \"%@\" is already taken", tableName: tableName,
                                                    comment: ""), name)
        case let .categoryNameAlreadyExists(name):
            return String(format: NSLocalizedString("Category name \"%@\" is already taken", tableName: tableName,
                                                    comment: ""), name)
        case .paretnTypeDoesntHasChildWithId:
            return NSLocalizedString("Parent type does not has children with id", tableName: tableName, comment: "")
        case .currencyWithIdNotFound:
            return NSLocalizedString("Currency with id not found", tableName: tableName, comment: "")
        case .holderWithIdNotFound:
            return NSLocalizedString("Holder with id not found", tableName: tableName, comment: "")
        case .keeperWithIdNotFound:
            return NSLocalizedString("Keeper with id not found", tableName: tableName, comment: "")
        case .emptyExchangeRate:
            return NSLocalizedString("Empty rate", tableName: tableName, comment: "")
        case .zeroRateValue:
            return NSLocalizedString("Zero rate value", tableName: tableName, comment: "")
        }
    }

    var failureReason: String? {
        switch self {
        case .emptyName:
            return NSLocalizedString("Name cannot be empty", tableName: tableName, comment: "")
        case .reservedName:
            return NSLocalizedString("Some names are reserved by the app", tableName: tableName, comment: "")
        case .accountNameAlreadyExists:
            return NSLocalizedString("The account name should be unique", tableName: tableName, comment: "")
        case .categoryNameAlreadyExists:
            return NSLocalizedString("The category name should be unique", tableName: tableName, comment: "")
        case .emptyExchangeRate:
            return NSLocalizedString("Exchange rate is required", tableName: tableName, comment: "")
        case .zeroRateValue:
            return NSLocalizedString("Exchange rate can not be equal to zero", tableName: tableName, comment: "")
        default:
            return nil
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .emptyName:
            return NSLocalizedString("Please enter name", tableName: tableName, comment: "")
        case .reservedName, .accountNameAlreadyExists, .categoryNameAlreadyExists:
            return NSLocalizedString("Please use another name", tableName: tableName, comment: "")
        case .emptyExchangeRate:
            return NSLocalizedString("Please enter rate value", tableName: tableName, comment: "")
        case .zeroRateValue:
            return NSLocalizedString("Please enter value grater then zero", tableName: tableName, comment: "")
        default:
            return NSLocalizedString("Please contact to support", tableName: tableName, comment: "")
        }
    }
}
