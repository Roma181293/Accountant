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
    
    struct Storyboard {
        static let welcomeViewController = "WelcomeVC_ID"
        static let startAccountingViewController = "StartAccountingVC_ID"
        
        static let tabBarController = "TabBarController_ID"
        
        static let bioAuthViewController = "BioAuthVC_ID"
        static let authPinAndBioViewController = "AuthPinAndBiometricVC_ID"
        
        static let purchaseOfferViewController = "PurchaseOfferVC_ID"
        
        static let transactionListViewController = "TransactionListVC_ID"
        static let simpleTransactionEditorViewController = "SimpleTransactionEditorVC_ID"
        static let complexTransactionEditorViewController = "ComplexTransactionEditorVC_ID"
        static let importTransactionViewController = "ImportTransactionVC_ID"
        
        static let accountNavigatorTableViewController = "AccountNavigatorTVC_ID"
        static let accountEditorWithInitialBalanceViewController = "AccountEditorWithInitialBalanceVC_ID"
        static let addAccountViewController = "AddAccountVC_ID"
        static let accountListViewController = "AccountListVC_ID"
        static let accountListTableViewController = "AccountListTVC_ID"
        
        static let currencyTableViewController = "CurrencyTVC_ID"
        
        static let budgetsListViewController = "BudgetsListVC_ID"
        static let budgetEditorViewController = "BudgetEditorVC_ID"
        
        static let analyticsViewController = "AnalyticsVC_ID"
        static let analyticsTableViewController = "AnalyticsTVC_ID"
        static let configureAnalyticsViewController = "ConfigureAnalyticsVC_ID"
        
        static let settingsTableViewController = "UserProfileTVC_ID"
        static let subscriptionsStatusViewController = "SubscriptionsStatusVC_ID"
    }
    
    struct Cell {
        static let transactionItemTableViewCell = "TransactionItemTableViewCell_ID"
        static let stepItemCell = "StepItemCell_ID"
        static let setAccountingCurrencyCell = "setAccountingCurrencyCell_ID"
        
        static let transactionCell = "TransactionCell_ID"
        static let complexTransactionCell = "ComplexTransactionCell_ID"
        static let preTransactionTableViewCell = "PreTransactionTableViewCell_ID"
        
        static let accountNavigatorCell = "AccountNavigatorCell_ID"
        
        static let moneyAccountCell = "MoneyAccountCell_ID"
        static let accountInForeignCurrencyCell = "AccountInForeignCurrencyCell_ID"
        
        static let analyticsCell = "AnalyticsCell_ID"
        static let analyticsCell1 = "AnalyticsCell1_ID"
        
        static let currencyCell = "CurrencyCell_ID"

        static let settingsCell = "SettingsCell_ID"
    }
    
    struct Segue {
        static let goToMoneyAccountListTVC = "goToMoneyAccountListTVC_ID"
        static let debitToAccountNavigator = "debitToAccountNavigator_ID"
        static let creditToAccountNavigator = "creditToAccountNavigator_ID"
        static let goToConfigurationVC = "goToConfigurationVC_ID"
        static let goToAnalyticsTVC = "goToAnalyticsTVC_ID"
    }
    
    struct APIKey {
        static let revenueCat = "kdbkctkUtCoRwtOqEDXtMeRaGxBkxLHG"
        static let googleAD = "ca-app-pub-3940256099942544/4411468910"
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
        
        
        static let set1: [NSUIColor] = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
    }
}


struct Colors {
    
    struct Main {
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
