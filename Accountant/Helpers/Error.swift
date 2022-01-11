//
//  Error.swift
//  Accountant
//
//  Created by Roman Topchii on 06.08.2021.
//

import Foundation

protocol AppError: Error {}




enum AccountError : AppError {
    case attributeTypeShouldBeInitializeForRootAccount
    case accountAlreadyExists(name: String)
    case categoryAlreadyExists(name: String)
    case cantRemoveAccountThatUsedInTransactionItem(String)
    case cantRemoveCategoryThatUsedInTransactionItem(String)
    case creditAccountAlreadyExist(String)  //for cases when creates linked account
    case reservedName
    case accountDoesNotExist(String)
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
            return String(format: NSLocalizedString("Account name \"%@\" is already taken. Please use another name", comment: ""),name)
            
        case let .categoryAlreadyExists(name):
            return String(format: NSLocalizedString("Category name \"%@\" is already taken. Please use another name", comment: ""),name)
            
        case let .cantRemoveAccountThatUsedInTransactionItem(list):
            return NSLocalizedString("This account cannot be deleted because of existing transactions", comment: "")
            
        case let .cantRemoveCategoryThatUsedInTransactionItem(list):
            return NSLocalizedString("This category cannot be deleted because of existing transactions", comment: "")
            
        case let .creditAccountAlreadyExist(name):
            return String(format: NSLocalizedString("We create an associated credit account with your credit cards. Credit account \"%@\" already exists",comment: ""), AccountsNameLocalisationManager.getLocalizedAccountName(.credits)+":"+name)
            
        case .reservedName:
            return NSLocalizedString("This is name is reserved by the app. Please use another name",comment: "")
            
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
    
    
    //        public var failureReason: String? {
    //
    //        }
    //        public var recoverySuggestion: String? {
    //
    //        }
}





enum CurrencyError : AppError {
    case thisCurrencyAlreadyExists
    case thisCurrencyUsedInAccounts
    case thisIsAccountingCurrency
    case thisCurrencyAlreadyUsedInTransaction
    case accountingCurrencyNotFound
}

extension CurrencyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .thisCurrencyAlreadyExists:
            return NSLocalizedString("This currency already exists",comment: "")
        case .thisCurrencyUsedInAccounts:
            return NSLocalizedString("This currency is already used on your accounts",comment: "")
        case .thisIsAccountingCurrency:
            return NSLocalizedString("This is your accounting currency",comment: "")
        case .thisCurrencyAlreadyUsedInTransaction:
            return NSLocalizedString("This currency is already used in transactions where one of the accounts has a different currency",comment: "")
        case .accountingCurrencyNotFound:
            return NSLocalizedString("Accounting currency not found",comment: "")
        }
    }
}



enum KeeperError : AppError {
    case thisKeeperAlreadyExists
    case thisKeeperUsedInAccounts
    case emptyName
    case keeperNotFound(name: String)
}

extension KeeperError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .thisKeeperAlreadyExists:
            return NSLocalizedString("Item with same name already exists",comment: "")
        case .thisKeeperUsedInAccounts:
            return NSLocalizedString("This item is already used on your accounts",comment: "")
        case .emptyName:
            return NSLocalizedString("Please enter name", comment: "")
        case let .keeperNotFound(name):
            return NSLocalizedString("Keeper \"\(name)\" not found",comment: "")
        }
    }
}


enum HolderError : AppError {
    case thisHolderAlreadyExists
    case thisHolderUsedInAccounts
    case emptyName
    case emptyIcon
}

extension HolderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .thisHolderAlreadyExists:
            return NSLocalizedString("Holder with the same name already exists",comment: "")
        case .thisHolderUsedInAccounts:
            return NSLocalizedString("This holder is already used on your accounts",comment: "")
        case .emptyName:
            return NSLocalizedString("Please enter name", comment: "")
        case .emptyIcon:
            return NSLocalizedString("Please enter emoji icon", comment: "")
        }
    }
}




enum BudgetError : AppError {
    case thisBadgetAlreadyExists
    case incorrectLeftOrRightBorderDate
    case incorrectLeftOrRightBorderDateInNeedGenerateBudgetsForCurrentMonthMethod
    case incorrectLeftOrRightBorderDateInAutoCreateBudgetMethod
}







enum TransactionError : AppError {
    case differentAmountForSingleCurrecyTransaction
    case noDebitTransactionItem
    case noCreditTransactionItem
    case debitTransactionItemWOAccount
    case creditTransactionItemWOAccount
    case multicurrencyAccount(name: String)
}

extension TransactionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .differentAmountForSingleCurrecyTransaction:
            return NSLocalizedString("You have a transaction in the same currency, but amounts in From:Account and To:Account are not matching",comment: "")
        case .noDebitTransactionItem:
            return NSLocalizedString("Please add To:Account",comment: "")
        case .noCreditTransactionItem:
            return NSLocalizedString("Please add From:Account",comment: "")
        case .debitTransactionItemWOAccount:
            return NSLocalizedString("Please select To:Account",comment: "")
        case .creditTransactionItemWOAccount:
            return NSLocalizedString("Please select From:Account",comment: "")
        case let .multicurrencyAccount(name):
            return String(format: NSLocalizedString("Please create a subaccount for \"%@\" and select it", comment: ""), name)
        }
    }
}

enum TransactionItemError : AppError {
    
    case invalidAmountInDebitTransactioItem(path: String)
    case invalidAmountInCreditTransactioItem(path: String)
    case attributeTypeDidNotSpecified
}

extension TransactionItemError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidAmountInDebitTransactioItem(name):
            return String(format: NSLocalizedString("Please check amount value to account/category \"%@\"", comment: ""), name)
        case let .invalidAmountInCreditTransactioItem(name):
            return String(format: NSLocalizedString("Please check amount value from account/category \"%@\"", comment: ""), name)
        case .attributeTypeDidNotSpecified:
            return NSLocalizedString("There are one or more thansaction items with incorrect types value. Possible values: \"From\", \"Credit\", \"To\", \"Debit\"",comment: "")
        }
    }
}






enum AccountWithBalanceError: AppError {
    case emptyAccountName
    case emptyBalance
    case emptyCreditLimit
    case emptyExchangeRate
    case canNotFindBeboreAccountingPeriodAccount
    case notSupported
}

extension AccountWithBalanceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        
        case .emptyAccountName:
            return NSLocalizedString("Please enter the account name",comment: "")
        case .emptyBalance:
            return NSLocalizedString("Please enter balance",comment: "")
        case .emptyCreditLimit:
            return NSLocalizedString("Please enter credit limit",comment: "")
        case .emptyExchangeRate:
            return NSLocalizedString("Please enter exchange rate",comment: "")
        case .canNotFindBeboreAccountingPeriodAccount:
            return NSLocalizedString("Can not find \"Bebore accounting period\" account. Please contact support",comment: "")
        case .notSupported:
            return NSLocalizedString("Not supported",comment: "")
        }
    }
}


enum MonoBankError: AppError {
    case toEarlyToRetrieveTheData(date: Date)
   
}

extension MonoBankError: LocalizedError {
    private func formateDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")")
        return dateFormatter.string(from: date)
    }
    private func getMonoLink()-> String {
        return "https://api.monobank.ua/docs"
    }
    
    public var errorDescription: String? {
        switch self {
        case let .toEarlyToRetrieveTheData(date):
            return NSLocalizedString("Too early to retrive Monobank statements data\nPlease wait 1 minute to the next try. This limitation was imposed due to API policy \(getMonoLink()). \nLast load \(formateDate(date))\n Current call \(formateDate(Date()))",comment: "")
        }
    }
}



enum BankAccountError: AppError {
    case alreadyExist(name: String?)
   
}

extension BankAccountError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .alreadyExist(name):
            return NSLocalizedString("This account \(name ?? "") already added",comment: "")
        }
    }
}


enum UserBankProfileError: AppError {
    case alreadyExist
   
}

extension UserBankProfileError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .alreadyExist:
            return NSLocalizedString("This user bank profile already exists",comment: "")
        }
    }
}
