//
//  Account balance extension.swift
//  Accountant
//
//  Created by Roman Topchii on 17.06.2022.
//

import Foundation

extension Account {

    var balance: Double {
        var debitTotal: Double = 0
        var creditTotal: Double = 0

        for account in childrenList + [self] {
            for item in account.appliedTransactionItemsList {
                if item.type == .debit {
                    debitTotal += item.amount
                } else if item.type == .credit {
                    creditTotal += item.amount
                }
            }
        }

        if type.classification == .assets {
            return debitTotal - creditTotal
        } else if type.classification == .liabilities {
            return creditTotal - debitTotal
        } else {
            return 0
        }
    }

    func balanceOn(date: Date) -> Double {
        var debit: Double = 0
        var credit: Double = 0

        for account in childrenList + [self] {
            for item in account.appliedTransactionItemsList.filter({$0.transaction!.date <= date}) {
                if item.type == .debit {
                    debit += item.amount
                } else if item.type == .credit {
                    credit += item.amount
                }
            }
        }

        if type.classification == .assets {
            return debit - credit
        } else if type.classification == .liabilities {
            return credit - debit
        } else {
            return 0
        }
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

    func balance(dateInterval: DateInterval,
                 dateComponent: Calendar.Component,
                 calcIncludedAccountsBalances: Bool = true) -> [(date: Date, value: Double)] {

        // creates date interval
        let intervalArray: [DateInterval] = Account.createDateIntervalArray(dateInterval: dateInterval,
                                                                            dateComponent: dateComponent)

        // calculate accountSaldoToLeftBorderDate
        var accountSaldoToLeftBorderDate: Double = 0
        var result: [(date: Date, value: Double)] = [(date: dateInterval.start, value: accountSaldoToLeftBorderDate)]

        var accounts: [Account] = []
        accounts.append(self)

        if calcIncludedAccountsBalances {
            accounts += childrenList
        }

        if accounts.isEmpty == false {
            if accounts[0].rootAccount.name == LocalisationManager.getLocalizedName(.money) ||
                accounts[0].rootAccount.name == LocalisationManager.getLocalizedName(.credits) ||
                accounts[0].rootAccount.name == LocalisationManager.getLocalizedName(.debtors) {

                accounts.forEach({
                    accountSaldoToLeftBorderDate += $0.balanceOn(date: dateInterval.start)
                })
            }

            for (index, timeInterval) in intervalArray.enumerated() {
                var debitTotal: Double = 0
                var creditTotal: Double = 0

                for account in accounts {
                    let transactionItems = account.transactionItemsList.filter({$0.transaction!.status == .applied})
                    for item in transactionItems {
                        if timeInterval.contains(item.transaction!.date) {
                            if item.type == .debit {
                                debitTotal += item.amount
                            } else if item.type == .credit {
                                creditTotal += item.amount
                            }
                        }
                    }
                }
                // TODO: - remove condition below if its unused
                if true ||
                    accounts[0].rootAccount.name == LocalisationManager.getLocalizedName(.money) ||
                    accounts[0].rootAccount.name == LocalisationManager.getLocalizedName(.credits) ||
                    accounts[0].rootAccount.name == LocalisationManager.getLocalizedName(.debtors) {
                    if accounts[0].type.classification == .assets {
                        result.append((date: timeInterval.end,
                                       value: round((result[index].value + debitTotal - creditTotal)*100)/100))
                    } else if accounts[0].type.classification == .liabilities {
                        result.append((date: timeInterval.end,
                                       value: round((result[index].value + creditTotal - debitTotal)*100)/100))
                    }
                } else {
                    if accounts[0].type.classification == .assets {
                        result.append((date: timeInterval.end,
                                       value: round((debitTotal - creditTotal)*100)/100))
                    } else if accounts[0].type.classification == .liabilities {
                        result.append((date: timeInterval.end,
                                       value: round((creditTotal - debitTotal)*100)/100))
                    }
                }
            }
        } else {
            result = []
        }
        return result
    }
}
