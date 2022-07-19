//
//  AccountType extension.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation

extension AccountType {

    var childrenList: [AccountType] {
        return Array(children)
    }

    var hasMoreThenOneChildren: Bool {
        return childrenList.filter({$0.canBeCreatedByUser}).count > 1
    }

    var useCustomViewToCreateAccount: Bool {
        return hasHolder || hasKeeper || hasInitialBalance || linkedAccountType != nil
    }

    var defultChildType: AccountType? {
        if childrenList.filter({$0.canBeCreatedByUser}).isEmpty {
            return nil
        } else {
            return childrenList.filter({$0.canBeCreatedByUser}).sorted(by: {$0.priority > $1.priority}).first
        }
    }

    enum NameEnum: String {
        case accounting = "Accounting"
        case moneyConsolidation = "Money consolidation"
        case creditCard = "Credit Card"
        case debitCard = "Debit Card"
        case cash = "Cash"
        case debtorsConsolidation = "Debtors consolidation"
        case debtor = "Debtor"
        case creditorsConsolidation = "Creditors consolidation"
        case creditor = "Creditor"
        case incomeConsolidation = "Income consolidation"
        case expenseConsolidation = "Expense consolidation"
        case capitalConsolidation = "Capital consolidation"
        case liabilitiesCategoryConsolidation = "Liabilities category consolidation"
        case assetsCategoryConsolidation = "Assets category consolidation"
        case liabilitiesCategory = "Liabilities category"
        case assetsCategory = "Assets category"
        case expenseBeforeAccountingPeriod = "Expense before accounting period"
    }
}
