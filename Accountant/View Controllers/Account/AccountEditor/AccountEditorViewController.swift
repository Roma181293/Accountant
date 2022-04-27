//
//  AccountEditorViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 10.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import Purchases

class AccountEditorViewController: UIViewController { // swiftlint:disable:this type_body_length

    var parentAccount: Account!
    var account: Account?

    private var isUserHasPaidAccess: Bool = false
    private let coreDataStack = CoreDataStack.shared
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    private var expenseRoot: Account!
    private var capitalRoot: Account!

    private(set) var moneyRoot: Account!
    private(set) var creditsRoot: Account!
    private(set) var debtorsRoot: Account!
    private(set) var isFreeNewAccountName: Bool = false
    private(set) var accountSubType: Account.SubTypeEnum?
    private(set) var accountingCurrency: Currency!
    private(set) var currency: Currency!
    private(set) var holder: Holder?
    private(set) var keeper: Keeper?

    private lazy var mainView: AccountEditorView = {return AccountEditorView(controller: self)}()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)

        reloadProAccessData()

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        getRootAccounts()
        accountingCurrency = Currency.getAccountingCurrency(context: context)!

        if let account = account {
            self.navigationItem.title = NSLocalizedString("Edit account",
                                                          tableName: Constants.Localizable.accountEditorVC,
                                                          comment: "")
            currency = account.currency
            holder = account.holder
            keeper = account.keeper
            accountSubType = account.subType
            if accountSubType == .cash {
                self.keeper = try? Keeper.getCashKeeper(context: context)
            }
            mainView.configureUIForEditAccount()
        } else {
            self.navigationItem.title = NSLocalizedString("Add account",
                                                          tableName: Constants.Localizable.accountEditorVC,
                                                          comment: "")
            currency = Currency.getAccountingCurrency(context: context)!
            keeper = try? Keeper.getFirstNonCashKeeper(context: context)
            holder = try? Holder.getMe(context: context)
            if parentAccount == moneyRoot {
                accountSubType = .debitCard
            }
            mainView.configureUIForNewAccount()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
        context.rollback()
    }

    @objc private func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            } else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
            }
        }
    }

    @objc func confirmCreation(_ sender: UIButton) {
        do {
            if let account = account {
                account.holder = holder
                account.keeper = keeper
                if context.hasChanges {
                    account.modifyDate = Date()
                    account.modifiedByUser = true
                    try coreDataStack.saveContext(context)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                if mainView.name == "" {
                    throw AccountWithBalanceError.emptyAccountName
                } else {
                    guard isFreeNewAccountName
                    else {throw AccountError.accountAlreadyExists(name: mainView.name)}
                    context.rollback()
                    try createAccountsAndTransactions()
                    try coreDataStack.saveContext(context)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } catch let error {
            self.errorHandler(error: error)
        }
    }

    private func getRootAccounts() {
        let rootAccountList = Account.getRootAccountList(context: context)
        rootAccountList.forEach({
            switch $0.name {
            case LocalisationManager.getLocalizedName(.money):  moneyRoot = $0
            case LocalisationManager.getLocalizedName(.credits): creditsRoot = $0
            case LocalisationManager.getLocalizedName(.debtors): debtorsRoot = $0
            case LocalisationManager.getLocalizedName(.expense): expenseRoot = $0
            case LocalisationManager.getLocalizedName(.capital): capitalRoot = $0
            default: break
            }
        })
    }

    @objc func checkName(_ sender: UITextField) {
        guard let name = sender.text, !name.isEmpty, name.count > 1
        else {
            isFreeNewAccountName = false
            return
        }
        if Account.isReservedAccountName(name) {
            isFreeNewAccountName = false
        } else {
            if parentAccount == moneyRoot && accountSubType == .creditCard {
                if Account.isFreeAccountName(parent: parentAccount, name: name, context: context) &&
                    Account.isFreeAccountName(parent: creditsRoot, name: name, context: context) {
                    isFreeNewAccountName = true
                } else {
                    isFreeNewAccountName = false
                }
            } else {
                if Account.isFreeAccountName(parent: parentAccount, name: name, context: context) {
                    isFreeNewAccountName = true
                } else {
                    isFreeNewAccountName = false
                }
            }
        }
        mainView.setNameBackgroundColor()
    }

    private func createAccountsAndTransactions() throws { // swiftlint:disable:this cyclomatic_complexity function_body_length line_length
        var exchangeRate: Double = 1

        // Check balance value
        guard let balance: Double = mainView.balance else {throw AccountWithBalanceError.emptyBalance}
        if parentAccount == moneyRoot, let accountSubType = accountSubType {
            if accountSubType == .cash || accountSubType == .debitCard {
                // Check exchange rate value
                if currency != accountingCurrency {
                    if let rate: Double = mainView.rate {
                        exchangeRate = rate
                    } else {throw AccountWithBalanceError.emptyExchangeRate}
                }
                let moneyAccount = try Account.createAndGetAccount(parent: parentAccount,
                                                                   name: mainView.name,
                                                                   type: parentAccount.type,
                                                                   currency: currency,
                                                                   keeper: keeper,
                                                                   holder: holder, subType: accountSubType,
                                                                   context: context)
                if balance != 0 {
                    Transaction.addTransactionWith2TranItems(date: mainView.date,
                                                             debit: moneyAccount,
                                                             credit: capitalRoot,
                                                             debitAmount: round(balance*100)/100,
                                                             creditAmount: round(round(balance*100)/100 * exchangeRate*100)/100, // swiftlint:disable:this line_length
                                                             createdByUser: false,
                                                             context: context)
                }
            } else if accountSubType == .creditCard {
                // Check credit account name is free
                guard Account.isFreeAccountName(parent: creditsRoot,
                                                name: mainView.name,
                                                context: context)
                else {throw AccountError.creditAccountAlreadyExist(creditsRoot.name + ":" + mainView.name)} // swiftlint:disable:this line_length

                // Check credit limit value
                guard let creditLimit: Double = mainView.creditLimit
                else {throw AccountWithBalanceError.emptyCreditLimit}

                // Check exchange rate value
                if currency != accountingCurrency {
                    if let rate: Double = mainView.rate {
                        exchangeRate = rate
                    } else {throw AccountWithBalanceError.emptyExchangeRate}
                }

                let newMoneyAccount = try Account.createAndGetAccount(parent: parentAccount,
                                                                      name: mainView.name,
                                                                      type: parentAccount.type,
                                                                      currency: currency,
                                                                      keeper: keeper,
                                                                      holder: holder,
                                                                      subType: accountSubType,
                                                                      context: context)
                let newCreditAccount = try Account.createAndGetAccount(parent: creditsRoot,
                                                                       name: mainView.name,
                                                                       type: creditsRoot.type,
                                                                       currency: currency,
                                                                       keeper: keeper,
                                                                       holder: holder,
                                                                       context: context)

                newMoneyAccount.linkedAccount = newCreditAccount

                if balance - creditLimit > 0 {
                    Transaction.addTransactionWith2TranItems(date: mainView.date,
                                                             debit: newMoneyAccount,
                                                             credit: capitalRoot,
                                                             debitAmount: round((balance - creditLimit)*100)/100,
                                                             creditAmount: round(round((balance - creditLimit)*100)/100 * exchangeRate*100)/100, // swiftlint:disable:this line_length
                                                             createdByUser: false,
                                                             context: context)
                    Transaction.addTransactionWith2TranItems(date: mainView.date,
                                                             debit: newMoneyAccount,
                                                             credit: newCreditAccount,
                                                             debitAmount: round(creditLimit*100)/100,
                                                             creditAmount: round(creditLimit*100)/100,
                                                             createdByUser: false,
                                                             context: context)
                } else if balance - creditLimit == 0 {
                    if !(balance == 0 && creditLimit == 0) {
                        Transaction.addTransactionWith2TranItems(date: mainView.date,
                                                                 debit: newMoneyAccount,
                                                                 credit: newCreditAccount,
                                                                 debitAmount: round(creditLimit*100)/100,
                                                                 creditAmount: round(creditLimit*100)/100,
                                                                 createdByUser: false,
                                                                 context: context)
                    }
                } else {
                    var expBeforeAccPeriod: Account? = expenseRoot.getSubAccountWith(name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod)) // swiftlint:disable:this line_length
                    if expBeforeAccPeriod == nil {
                        expBeforeAccPeriod = try? Account.createAndGetAccount(parent: expenseRoot,
                                                                                         name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod), // swiftlint:disable:this line_length
                                                                                         type: expenseRoot.type,
                                                                                         currency: expenseRoot.currency, // swiftlint:disable:this line_length
                                                                                         createdByUser: false,
                                                                                         context: context)
                    }
                    guard let expenseBeforeAccountingPeriodSafe = expBeforeAccPeriod
                    else {throw AccountWithBalanceError.canNotFindBeboreAccountingPeriodAccount}
                    Transaction.addTransactionWith2TranItems(date: mainView.date,
                                                             debit: expenseBeforeAccountingPeriodSafe,
                                                             credit: newMoneyAccount,
                                                             debitAmount: round(round((creditLimit - balance)*100)/100 * exchangeRate*100)/100, // swiftlint:disable:this line_length
                                                             creditAmount: round((creditLimit - balance)*100)/100,
                                                             createdByUser: false,
                                                             context: context)
                    Transaction.addTransactionWith2TranItems(date: mainView.date,
                                                             debit: newMoneyAccount,
                                                             credit: newCreditAccount,
                                                             debitAmount: round(creditLimit*100)/100,
                                                             creditAmount: round(creditLimit*100)/100,
                                                             createdByUser: false,
                                                             context: context)
                }
            }
        } else if parentAccount == debtorsRoot {
            // Check exchange rate value
            if currency != accountingCurrency {
                if let rate: Double = mainView.rate {
                    exchangeRate = rate
                } else {throw AccountWithBalanceError.emptyExchangeRate}
            }
            let newDebtorsAccount = try Account.createAndGetAccount(parent: parentAccount,
                                                                    name: mainView.name,
                                                                    type: parentAccount.type,
                                                                    currency: currency,
                                                                    keeper: keeper,
                                                                    holder: holder,
                                                                    context: context)
            Transaction.addTransactionWith2TranItems(date: mainView.date,
                                                     debit: newDebtorsAccount,
                                                     credit: capitalRoot,
                                                     debitAmount: round(balance*100)/100,
                                                     creditAmount: round(round(balance*100)/100 * exchangeRate*100)/100,
                                                     createdByUser: false,
                                                     context: context)
        } else if parentAccount == creditsRoot {
            // Check exchange rate value
            if currency != accountingCurrency {
                if let rate: Double = mainView.rate {
                    exchangeRate = rate
                } else {throw AccountWithBalanceError.emptyExchangeRate}
            }
            try? Account.createAccount(parent: expenseRoot, name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod), // swiftlint:disable:this line_length
                                       type: Account.TypeEnum.assets,
                                       currency: expenseRoot.currency,
                                       createdByUser: false,
                                       context: context)
            let newCreditAccount = try Account.createAndGetAccount(parent: parentAccount,
                                                                   name: mainView.name,
                                                                   type: parentAccount.type,
                                                                   currency: currency,
                                                                   keeper: keeper,
                                                                   holder: holder,
                                                                   context: context)
            guard let expenseBeforeAccountingPeriod: Account = Account.getAccountWithPath("\(LocalisationManager.getLocalizedName(.expense)):\(LocalisationManager.getLocalizedName(.beforeAccountingPeriod))", context: context) // swiftlint:disable:this line_length
            else {throw AccountWithBalanceError.canNotFindBeboreAccountingPeriodAccount}
            Transaction.addTransactionWith2TranItems(date: mainView.date,
                                                     debit: expenseBeforeAccountingPeriod,
                                                     credit: newCreditAccount,
                                                     debitAmount: (balance * exchangeRate*100)/100,
                                                     creditAmount: balance,
                                                     createdByUser: false,
                                                     context: context)
        } else {throw AccountWithBalanceError.notSupported}
    }

    func errorHandler(error: Error) {
        if error is AppError {
            let alert = UIAlertController(title: NSLocalizedString("Warning",
                                                                   tableName: Constants.Localizable.accountEditorVC,
                                                                   comment: ""),
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                                   tableName: Constants.Localizable.accountEditorVC,
                                                                   comment: ""),
                                          style: .default,
                                          handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Error",
                                                                   tableName: Constants.Localizable.accountEditorVC,
                                                                   comment: ""),
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                                   tableName: Constants.Localizable.accountEditorVC,
                                                                   comment: ""),
                                          style: .default,
                                          handler: { [self](_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Routing
extension AccountEditorViewController {
    @objc func selectHolder() {
        let holderVC = HolderViewController()
        holderVC.delegate = self
        holderVC.holder = holder
        self.navigationController?.pushViewController(holderVC, animated: true)
    }

    @objc func selectkeeper() {
        let keeperVC = KeeperViewController()
        keeperVC.delegate = self
        keeperVC.keeper = keeper
        if parentAccount == moneyRoot {
            keeperVC.mode = .bank
        } else if parentAccount == debtorsRoot {
            keeperVC.mode = .nonCash
        } else if parentAccount == creditsRoot {
            keeperVC.mode = .nonCash
        }
        self.navigationController?.pushViewController(keeperVC, animated: true)
    }

    @objc func selectCurrency() {
        guard AccessManager.canCreateAccountInNonAccountingCurrency(environment: coreDataStack.activeEnviroment()!, isUserHasPaidAccess: isUserHasPaidAccess) // swiftlint:disable:this line_length
        else {
            self.showPurchaseOfferVC()
            return
        }
        let currencyVC = CurrencyViewController(currency: currency, delegate: self, mode: .setCurrency)
        self.navigationController?.pushViewController(currencyVC, animated: true)
    }

    @objc func changeAccountSubType() {
        switch accountSubType {
        case .debitCard:
            accountSubType = .creditCard
        case .creditCard:
            accountSubType = .cash
            keeper = try? Keeper.getCashKeeper(context: context)
        case .cash:
            accountSubType = .debitCard
            keeper = try? Keeper.getFirstNonCashKeeper(context: context)
        default:
            break
        }
        mainView.setAccountSubType()
        mainView.setKeeper()
    }

    private func showPurchaseOfferVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let purchaseOfferVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferVC) as? PurchaseOfferViewController else {return} // swiftlint:disable:this line_length
        self.present(purchaseOfferVC, animated: true, completion: nil)
    }
}

// MARK: - Keyboard methods
extension AccountEditorViewController: UIScrollViewDelegate {
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 40), right: 0.0)
        mainView.mainScrollView.contentInset = contentInsets
        mainView.mainScrollView.scrollIndicatorInsets = contentInsets
        mainView.mainScrollView.contentSize = self.view.frame.size
    }

    @objc func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        mainView.mainScrollView.contentInset = contentInsets
        mainView.mainScrollView.scrollIndicatorInsets = contentInsets
        mainView.mainScrollView.contentSize = self.mainView.frame.size
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func doneButtonAction() {
        mainView.accountNameTextField.resignFirstResponder()
        mainView.accountBalanceTextField.resignFirstResponder()
        mainView.creditLimitTextField.resignFirstResponder()
        mainView.exchangeRateTextField.resignFirstResponder()
    }
}

extension AccountEditorViewController: CurrencyReceiverDelegate {
    func setCurrency(_ selectedCurrency: Currency) {
        self.currency = selectedCurrency
        mainView.setCurrency()
    }
}

extension AccountEditorViewController: KeeperReceiverDelegate {
    func setKeeper(_ selectedKeeper: Keeper?) {
        self.keeper = selectedKeeper
        mainView.setKeeper()
    }
}

extension AccountEditorViewController: HolderReceiverDelegate {
    func setHolder(_ selectedHolder: Holder?) {
        self.holder = selectedHolder
        mainView.setHolder()
    }
} // swiftlint:disable:this file_length
