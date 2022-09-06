//
//  PreTrasaction.swift
//  Accounting
//
//  Created by Roman Topchii on 24.10.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

class PreTransaction {
    var id : String?
    var transaction: Transaction!
    var isReadyToSave: Bool {
        if transaction.date == nil {
            return false
        }
        for item in transaction.itemsList {
            if item.amount == nil || item.account == nil {
                return false
            }
        }
        if isSingleCurrency,
           let debit = totalAmountForType(.debit),
           let credit = totalAmountForType(.credit),
           round(debit*100) != round(credit*100) {
            print(debit, credit)
            return false
        }
        return true
    }

    private var isSingleCurrency: Bool {
        for item1 in transaction.itemsList {
            for item2 in transaction.itemsList where item1.account?.currency != item2.account?.currency {
                return false
            }
        }
        return true
    }

    private func totalAmountForType(_ type: TransactionItem.TypeEnum) -> Double? {
        var totalAmount: Double = 0
        for item in transaction.itemsList.filter({if $0.type == type {return true} else {return false}}) {
            if item.amount >= 0 {
                totalAmount += item.amount
            } else {
                return nil
            }
        }
        return totalAmount
    }
}
