//
//  Transaction.swift
//  Accountant
//
//  Created by Roman Topchii on 17.06.2022.
//

import Foundation

extension Transaction {

    var itemsList: [TransactionItem] {
        return Array(items)
    }

    func delete() {
        for item in itemsList {
            item.managedObjectContext?.delete(item)
        }
        managedObjectContext?.delete(self)
    }

    func calculateType() {
        var debitUniqueAccountType: [String] = []
        for item in itemsList where item.type == .debit {
            if let rootTypeName = item.account?.rootAccount.type.name, !debitUniqueAccountType.contains(rootTypeName) {
                debitUniqueAccountType.append(rootTypeName)
            }
        }

        var creditUniqueAccountType: [String] = []
        for item in itemsList where item.type == .credit {
            if let rootTypeName = item.account?.rootAccount.type.name, !creditUniqueAccountType.contains(rootTypeName) {
                creditUniqueAccountType.append(rootTypeName)
            }
        }

        if type == .initialBalance {
            type = .initialBalance
        } else if creditUniqueAccountType.isEmpty || debitUniqueAccountType.isEmpty {
            type = .unknown
        } else if creditUniqueAccountType.count > 1 || debitUniqueAccountType.count > 1 {
            type = .other
        } else if creditUniqueAccountType.first == AccountType.NameEnum.incomeConsolidation.rawValue {
            type = .income
        } else if debitUniqueAccountType.first == AccountType.NameEnum.expenseConsolidation.rawValue {
            type = .expense
        } else if (creditUniqueAccountType.first == AccountType.NameEnum.moneyConsolidation.rawValue
                   && debitUniqueAccountType.first == AccountType.NameEnum.moneyConsolidation.rawValue)

                    || (creditUniqueAccountType.first == AccountType.NameEnum.moneyConsolidation.rawValue
                        && debitUniqueAccountType.first == AccountType.NameEnum.creditorsConsolidation.rawValue)
                    || (creditUniqueAccountType.first == AccountType.NameEnum.moneyConsolidation.rawValue
                        && debitUniqueAccountType.first == AccountType.NameEnum.debtorsConsolidation.rawValue)

                    || (creditUniqueAccountType.first == AccountType.NameEnum.creditorsConsolidation.rawValue
                        && debitUniqueAccountType.first == AccountType.NameEnum.moneyConsolidation.rawValue)
                    || (creditUniqueAccountType.first == AccountType.NameEnum.debtorsConsolidation.rawValue
                        && debitUniqueAccountType.first == AccountType.NameEnum.moneyConsolidation.rawValue)

                    || (creditUniqueAccountType.first == AccountType.NameEnum.debtorsConsolidation.rawValue
                        && debitUniqueAccountType.first == AccountType.NameEnum.creditorsConsolidation.rawValue)
                    || (creditUniqueAccountType.first == AccountType.NameEnum.creditorsConsolidation.rawValue
                        && debitUniqueAccountType.first == AccountType.NameEnum.debtorsConsolidation.rawValue) {
            type = .transfer
        }
    }

    enum Error: AppError, Equatable {
        case periodhasUnAppliedTransactions
        case differentAmountInSingleCurrecyTran
        case noDebitTransactionItem
        case noCreditTransactionItem
        case debitTransactionItemWOAccount
        case creditTransactionItemWOAccount
        case multicurrencyAccount(name: String)
    }
}

extension Transaction.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .periodhasUnAppliedTransactions:
            return NSLocalizedString("There is unapplied transaction before this date", comment: "")
        case .differentAmountInSingleCurrecyTran:
            return NSLocalizedString("You have a transaction in the same currency, but amounts in From:Account and " +
                                     "To:Account are not matching", comment: "")
        case .noDebitTransactionItem:
            return NSLocalizedString("Please add To:Account", comment: "")
        case .noCreditTransactionItem:
            return NSLocalizedString("Please add From:Account", comment: "")
        case .debitTransactionItemWOAccount:
            return NSLocalizedString("Please select To:Account", comment: "")
        case .creditTransactionItemWOAccount:
            return NSLocalizedString("Please select From:Account", comment: "")
        case let .multicurrencyAccount(name):
            return String(format: NSLocalizedString("Please create a subaccount for \"%@\" and select it", comment: ""),
                          name)
        }
    }
}
