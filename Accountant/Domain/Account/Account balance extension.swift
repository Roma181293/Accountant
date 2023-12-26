//
//  Account balance extension.swift
//  Accountant
//
//  Created by Roman Topchii on 17.06.2022.
//

import Foundation

struct Saldo {
    let debit: Double
    let credit: Double
}

extension Account {

    func balance(inAccountingCurrency: Bool = false) -> Double {
        return balance(for: {_ in return true}, inAccountingCurrency: inAccountingCurrency)
    }

    public func balance(for isIncluded: (TransactionItem) -> Bool, inAccountingCurrency: Bool = false) -> Double {
        if type.classification == .none {
            return 0
        }
        var debit: Double = 0
        var credit: Double = 0
        if inAccountingCurrency {
            for account in childrenList + [self] {
                for item in account.transactionItemsListReadyForBalanceCalc.filter(isIncluded) {
                    debit += item.type == .debit ? item.amountInAccountingCurrency : 0
                    credit += item.type == .credit ? item.amountInAccountingCurrency : 0
                }
            }
        } else {
            for account in childrenList + [self] {
                for item in account.transactionItemsListReadyForBalanceCalc.filter(isIncluded) {
                    debit += item.type == .debit ? item.amount : 0
                    credit += item.type == .credit ? item.amount : 0
                }
            }
        }
        return round((type.classification == .assets ? debit - credit : credit - debit) * 100) / 100
    }

    func balance(dateInterval: DateInterval,
                 dateComponent: Calendar.Component,
                 calcIncludedAccountsBalances: Bool = true,
                 inAccountingCurrency: Bool = false) -> [(date: Date, value: Double)] {

        if type.classification == .none {
            return []
        }

        let intervalArray: [DateInterval] = Account.createDateIntervalArray(dateInterval: dateInterval,
                                                                            dateComponent: dateComponent)

        var result: [(date: Date, value: Double)] = [(date: dateInterval.start, value: 0)]

        var accounts: [Account] = []
        accounts.append(self)

        if calcIncludedAccountsBalances {
            accounts += childrenList
        }

        for (index, timeInterval) in intervalArray.enumerated() {
            var debit: Double = 0
            var credit: Double = 0

            if inAccountingCurrency {
                for item in accounts.flatMap({$0.transactionItemsListReadyForBalanceCalc})
                where timeInterval.contains(item.transaction!.date) {
                    debit += item.type == .debit ? item.amountInAccountingCurrency : 0
                    credit += item.type == .credit ? item.amountInAccountingCurrency : 0
                }
            } else {
                for item in accounts.flatMap({$0.transactionItemsListReadyForBalanceCalc})
                where timeInterval.contains(item.transaction!.date) {
                    debit += item.type == .debit ? item.amount : 0
                    credit += item.type == .credit ? item.amount : 0
                }
            }

            if type.classification == .assets {
                result.append((date: timeInterval.end,
                               value: round((result[index].value + debit - credit) * 100) / 100))
            } else if type.classification == .liabilities {
                result.append((date: timeInterval.end,
                               value: round((result[index].value + credit - debit) * 100) / 100))
            }
        }

        return result
    }

    private class func createDateIntervalArray(dateInterval: DateInterval,
                                               dateComponent: Calendar.Component) -> [DateInterval] {
        let calendar = Calendar.current

        var intervalArray: [DateInterval] = []
        var interval = calendar.dateInterval(of: dateComponent, for: dateInterval.start)
        while let tmpInterval = interval, tmpInterval.end <= dateInterval.end {
            intervalArray.append(tmpInterval)
            interval = calendar.dateInterval(of: dateComponent, for: tmpInterval.end)
        }
        if let tmpInterval = interval, tmpInterval.start < dateInterval.end && tmpInterval.end > dateInterval.end {
            intervalArray.append(DateInterval(start: tmpInterval.start, end: dateInterval.end))
        }
        return intervalArray
    }
}
