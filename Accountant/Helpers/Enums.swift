//
//  Enums.swift
//  Accounting
//
//  Created by Roman Topchii on 10.03.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

enum BaseAccounts: String, CaseIterable {
    case income = "Income"
    case expense = "Expenses"
    case money = "Money"
    case credits = "Credits"
    case debtors = "Debtors"
    case capital = "Capital"
    case beforeAccountingPeriod = "Before accounting period"
    case other = "<Other>"
    case other1 = "Other"
}

enum SortCategoryType: Int {
    case aToz = 0
    case zToa = 1
    case zeroToNine = 2
    case nineToZero = 3
}

enum DistributionType: Int {
    case amount = 0
    case currecy = 1
    case holder = 2
    case keeper = 3
}

enum AuthType: Int {
    case appAuth = 0
    case bioAuth = 1
    case none = 2
}

enum AuthenticationState {
    case loggedin
    case loggedout
}

enum Environment: String {
    case prod = "Production"
    case test = "Test"
}
