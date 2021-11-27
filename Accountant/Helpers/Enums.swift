//
//  Enums.swift
//  Accounting
//
//  Created by Roman Topchii on 10.03.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

enum AccountType : Int16 {
    case assets = 1
    case liabilities = 0
}

enum AccounttingMethod : Int16 {
    case debit = 1
    case credit = 0
}

enum AccountSubType : Int16 {
    case none = 0
    case cash = 1
    case debitCard = 2
    case creditCard = 3
}

enum KeeperType : Int16 {
    case cash = 0
    case bank = 1
    case person = 2
}

enum BaseAccounts : String, CaseIterable {
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

enum SortCategoryType : Int {
    case aToz = 0
    case zToa = 1
    case zeroToNine = 2
    case nineToZero = 3
}

enum DistributionType : Int {
    case amount = 0
    case currecy = 1
    case holder = 2
    case keeper = 3
}

enum AuthType : Int{
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
