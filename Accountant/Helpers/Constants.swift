//
//  Constants.swift
//  Accountant
//
//  Created by Roman Topchii on 06.06.2021.
//

import Foundation
import UIKit
import Charts

struct Constants {
    struct Localizable {
        static let settingsVC = "SettingsVCLocalizable"
        static let bankAccountTVC = "BankAccountTVCLocalizable"
        static let userBankProfileTVC = "UserBankProfileTVCLocalizable"
        static let monobankVC = "MonobankVCLocalizable"
        static let keeperVC = "KeeperVCLocalizable"
        static let holderVC = "HolderVCLocalizable"
    }

    struct Storyboard {
        static let welcomeVC = "WelcomeVC_ID"
        static let startAccountingVC = "StartAccountingVC_ID"
        static let instructionVC = "InstructionVC_ID"

        static let tabBarController = "TabBarController_ID"

        static let bioAuthVC = "BioAuthVC_ID"
        static let authPinAndBioVC = "AuthPinAndBiometricVC_ID"

        static let purchaseOfferVC = "PurchaseOfferVC_ID"

        static let transactionListVC = "TransactionListVC_ID"
        static let simpleTransactionEditorVC = "SimpleTransactionEditorVC_ID"
        static let complexTransactionEditorVC = "ComplexTransactionEditorVC_ID"
        static let importTransactionVC = "ImportTransactionVC_ID"

        static let accountNavigatorTableVC = "AccountNavigatorTVC_ID"
        static let accountEditorWithInitialBalanceVC = "AccountEditorWithInitialBalanceVC_ID"
        static let addAccountVC = "AddAccountVC_ID"
        static let accountListVC = "AccountListVC_ID"
        static let accountListTableVC = "AccountListTVC_ID"

        static let currencyTableVC = "CurrencyTVC_ID"

        static let budgetsListVC = "BudgetsListVC_ID"
        static let budgetEditorVC = "BudgetEditorVC_ID"

        static let analyticsVC = "AnalyticsVC_ID"
        static let analyticsTableVC = "AnalyticsTVC_ID"
        static let configureAnalyticsVC = "ConfigureAnalyticsVC_ID"

        static let keeperTableVC = "KeeperTVC_ID"
        static let holderTableVC = "HolderTVC_ID"
        static let settingsVC = "SettingsVC_ID"

        static let monobankVC = "MonobankVC_ID"
    }

    struct Cell {
        static let transactionItemTableViewCell = "TransactionItemTableViewCell_ID"

        static let complexTransactionCell = "ComplexTransactionCell_ID"
        static let preTransactionTableViewCell = "PreTransactionTableViewCell_ID"

        static let accountNavigatorCell = "AccountNavigatorCell_ID"
        static let accountNavigationTableViewCell = "AccountNavigationTableViewCell_ID"

        static let accountTableViewCell = "AccountTableViewCell_ID"

        static let analyticsCell1 = "AnalyticsCell1_ID"

        static let keeperCell = "KeeperCell_ID"
        static let holderCell = "HolderCell_ID"

        static let currencyCell = "CurrencyCell_ID"
        static let settingsCell = "SettingsCell_ID"

        static let bankAccountCell = "BankAccountCell_ID"
        static let exchangeCell = "ExchangeCell_ID"
        static let userBankProfileCell = "UserBankProfileCell_ID"
    }

    struct Segue {
        static let goToMoneyAccountListTVC = "goToMoneyAccountListTVC_ID"
        static let debitToAccountNavigator = "debitToAccountNavigator_ID"
        static let creditToAccountNavigator = "creditToAccountNavigator_ID"
        static let goToConfigurationVC = "goToConfigurationVC_ID"
        static let goToAnalyticsTVC = "goToAnalyticsTVC_ID"
    }

    struct APIKey {
        static let revenueCat = "WtNuPdTrjjiiOwUaTogcvKOAbeydXpNx"
        static let googleAD = "ca-app-pub-3940256099942544/4411468910"
    }

    struct URL {
        static let privacyPolicy = "https://drive.google.com/file/d/1H3CZXn03YgGGM2uThEQ1yQ1G5PCvt3SB/view?usp=sharing"
        static let termsOfUse = "https://drive.google.com/file/d/1jGybkl74yTbOfzcFtGSySw8k86GjTP5N/view?usp=sharing"
        static let monoAPIDoc = "https://api.monobank.ua/docs"
        static let monoToken = "https://api.monobank.ua"
    }

    struct Size {

        static let cornerButtonRadius = CGFloat(8.0)
        static let cornerMainRadius = CGFloat(12.0)
        static let cornerCardRadius = CGFloat(15.0)
        static let minimumCellSpacing = CGFloat(13.0)
        static let backgroundMoving = CGFloat(-100.0)

    }
    struct ColorSetForCharts {
        static let set: [NSUIColor] = [NSUIColor(red: 192/255.0, green: 255/255.0, blue: 140/255.0, alpha: 1.0),
                                       NSUIColor(red: 140/255.0, green: 234/255.0, blue: 255/255.0, alpha: 1.0),
                                       NSUIColor(red: 255/255.0, green: 140/255.0, blue: 157/255.0, alpha: 1.0),
                                       NSUIColor(red: 207/255.0, green: 248/255.0, blue: 246/255.0, alpha: 1.0),
                                       NSUIColor(red: 148/255.0, green: 212/255.0, blue: 212/255.0, alpha: 1.0),
                                       NSUIColor(red: 136/255.0, green: 180/255.0, blue: 187/255.0, alpha: 1.0),
                                       NSUIColor(red: 118/255.0, green: 174/255.0, blue: 175/255.0, alpha: 1.0),
                                       NSUIColor(red: 42/255.0, green: 109/255.0, blue: 130/255.0, alpha: 1.0),
                                       NSUIColor(red: 217/255.0, green: 80/255.0, blue: 138/255.0, alpha: 1.0),
                                       NSUIColor(red: 254/255.0, green: 149/255.0, blue: 7/255.0, alpha: 1.0),
                                       NSUIColor(red: 255/255.0, green: 247/255.0, blue: 140/255.0, alpha: 1.0),
                                       NSUIColor(red: 254/255.0, green: 247/255.0, blue: 120/255.0, alpha: 1.0),
                                       NSUIColor(red: 106/255.0, green: 167/255.0, blue: 134/255.0, alpha: 1.0),
                                       NSUIColor(red: 53/255.0, green: 194/255.0, blue: 209/255.0, alpha: 1.0),
                                       NSUIColor(red: 64/255.0, green: 89/255.0, blue: 128/255.0, alpha: 1.0),
                                       NSUIColor(red: 149/255.0, green: 165/255.0, blue: 124/255.0, alpha: 1.0),
                                       NSUIColor(red: 217/255.0, green: 184/255.0, blue: 162/255.0, alpha: 1.0),
                                       NSUIColor(red: 191/255.0, green: 134/255.0, blue: 134/255.0, alpha: 1.0),
                                       NSUIColor(red: 179/255.0, green: 48/255.0, blue: 80/255.0, alpha: 1.0),
                                       NSUIColor(red: 193/255.0, green: 37/255.0, blue: 82/255.0, alpha: 1.0),
                                       NSUIColor(red: 255/255.0, green: 102/255.0, blue: 0/255.0, alpha: 1.0),
                                       NSUIColor(red: 255/255.0, green: 208/255.0, blue: 140/255.0, alpha: 1.0),
                                       NSUIColor(red: 245/255.0, green: 199/255.0, blue: 0/255.0, alpha: 1.0),
                                       NSUIColor(red: 106/255.0, green: 150/255.0, blue: 31/255.0, alpha: 1.0),
                                       NSUIColor(red: 179/255.0, green: 100/255.0, blue: 53/255.0, alpha: 1.0),
                                       NSUIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0),
                                       NSUIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 1.0),
                                       NSUIColor(red: 231/255.0, green: 76/255.0, blue: 60/255.0, alpha: 1.0),
                                       NSUIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1.0)
        ]

        static let set1: [NSUIColor] = [UIColor.systemBlue, UIColor.systemTeal,
                                        UIColor.systemGreen, UIColor.systemYellow,
                                        UIColor.systemOrange, UIColor.systemRed]
    }
}

struct Colors {
    struct Main {
        static let defaultCellTextColor = UIColor(named: "blackGrayColor")
        static let defaultButton = UIColor.systemGray4
        static let confirmButton = UIColor.systemGray5
        static let darkBlue = UIColor(red: 27/255, green: 35/255, blue: 47/255, alpha: 1)
        static let lightBlue = UIColor(red: 104/255, green: 150/255, blue: 218/255, alpha: 1)
        static let darkOrange = UIColor(red: 217/255, green: 104/255, blue: 38/255, alpha: 1)
        static let lightOrange = UIColor(red: 220/255, green: 160/255, blue: 29/255, alpha: 1)
    }
    struct Additional {
        static let lightGreen = UIColor(red: 101/255, green: 200/255, blue: 122/255, alpha: 1)
        static let lightGrey = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        static let darkBlue = UIColor(red: 5/255, green: 23/255, blue: 38/255, alpha: 1)
        static let darkBlackTransparent = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        static let lightRed = UIColor(red: 251/255, green: 95/255, blue: 95/255, alpha: 1)
        static let darkRed = UIColor(red: 240/255, green: 48/255, blue: 6/255, alpha: 1)
    }
}
