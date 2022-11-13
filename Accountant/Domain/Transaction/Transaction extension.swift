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
}
