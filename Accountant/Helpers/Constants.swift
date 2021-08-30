//
//  Constants.swift
//  Accountant
//
//  Created by Roman Topchii on 06.06.2021.
//

import Foundation
import UIKit

struct Constants {
    
    struct Storyboard {
        static let setAccountingCurrencyViewController = "SetAccountingCurrencyVC_ID"
        static let setAccountingStartDateViewController = "SetAccountingStartDateVC_ID"
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
        
        static let setAccountingCurrencyCell = "setAccountingCurrencyCell_ID"
        
        static let transactionCell = "TransactionCell_ID"
        static let complexTransactionCell = "ComplexTransactionCell_ID"
        static let preTransactionTableViewCell = "PreTransactionTableViewCell_ID"
        
        static let accountNavigatorCell = "AccountNavigatorCell_ID"
        
        static let moneyAccountCell = "MoneyAccountCell_ID"
        static let accountInForeignCurrencyCell = "AccountInForeignCurrencyCell_ID"
        
        static let analyticsCell = "AnalyticsCell_ID"
        
        static let currencyCell = "CurrencyCell_ID"
        
        static let settingsCellWithSwitchCell = "SettingsCellSwitch_ID"
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
    
//    struct Size {
        
//        static let cornerButtonRadius = CGFloat(6.0)
//        static let cornerMainRadius = CGFloat(12.0)
//        static let minimumCellSpacing = CGFloat(13.0)
//        static let backgroundMoving = CGFloat(-100.0)
//    }
}
