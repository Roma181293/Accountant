//
//  MonobankUBPInteractor.swift
//  Accountant
//
//  Created by Roman Topchii on 14.05.2022.
//

import Foundation

protocol MonobankUBPInteractorProtocol: AnyObject {
    var userInfo: MBUserInfo? {get}
    var holder: Holder? {get set}
    func loadMBUserInfo(for token: String)
    func createAccounts()
}

class MonobankUBPInteractor: MonobankUBPInteractorProtocol {

    unowned var presenter: MonobankUBPPresenterProtocol

    let context = CoreDataStack.shared.persistentContainer.viewContext
    var xToken = ""
    var userInfo: MBUserInfo?
    var holder: Holder?

    private var currencyHistoricalData: CurrencyHistoricalDataProtocol?
    private var moneyRootAccount: Account!
    private var creditsRootAccount: Account!
    private var debtorsRootAcccount: Account!
    private var expenseRootAccount: Account!
    private var capitalRootAccount: Account!

    required init(presenter: MonobankUBPPresenterProtocol) {
        self.presenter = presenter
        self.holder = Holder.getMe(context: context)
        getCurrencyExchangeRate()
    }

    func createAccounts() { // swiftlint:disable:this function_body_length cyclomatic_complexity
        guard let userInfo = userInfo else {return}
        do {
            try getRootAccounts()

            let ubp = try UserBankProfile.getOrCreateMonoBankUBP(userInfo, xToken: xToken, context: self.context)

            for item in userInfo.accounts.filter({return !$0.isExists(context: context)}) {
                guard Account.isFreeAccountName(parent: moneyRootAccount,
                                                name: item.maskedPan.last! ,
                                                context: context)
                else {
                    throw AccountError.accountAlreadyExists(name: moneyRootAccount.name+":"+item.maskedPan.last!)
                }

                let bankAccount = try BankAccount.createAndGetMBBankAccount(item, userBankProfile: ubp,
                                                                            context: context)

                var exchangeRate: Double = 1
                // Check balance value
                let balance: Double = Double(item.balance) / 100
                let creditLimit: Double = Double(item.creditLimit) / 100

                guard let currency = item.getCurrency(context: context) else {return}
                guard let accountingCurrency = Currency.getAccountingCurrency(context: context)
                else {throw CurrencyError.accountingCurrencyNotFound}
                guard  let keeper = try Keeper.getKeeperForName("Monobank", context: context)
                else {throw KeeperError.keeperNotFound(name: "Monobank")}

                // Check credit account name is free
                guard Account.isFreeAccountName(parent: creditsRootAccount,
                                                name: item.maskedPan.last! ,
                                                context: context)
                else {throw AccountError.creditAccountAlreadyExist(creditsRootAccount.name + item.maskedPan.last!)}

                // Check exchange rate value
                if currency != accountingCurrency {
                    guard let currencyHistoricalData = currencyHistoricalData,
                          let rate = currencyHistoricalData.exchangeRate(pay: accountingCurrency.code,
                                                                         forOne: currency.code)
                    else {return}
                    exchangeRate = rate
                }

                let newMoneyAccount = try Account.createAndGetAccount(parent: moneyRootAccount,
                                                                      name: item.maskedPan.last!,
                                                                      type: moneyRootAccount.type,
                                                                      currency: currency,
                                                                      keeper: keeper, holder: holder,
                                                                      subType: Account.SubTypeEnum.creditCard,
                                                                      context: context)

                newMoneyAccount.bankAccount = bankAccount

                let newCreditAccount = try Account.createAndGetAccount(parent: creditsRootAccount,
                                                                       name: item.maskedPan.last!,
                                                                       type: creditsRootAccount.type,
                                                                       currency: currency,
                                                                       keeper: keeper, holder: holder,
                                                                       context: context)

                newMoneyAccount.linkedAccount = newCreditAccount

                if balance - creditLimit == 0 && !(balance == 0 && creditLimit == 0) {
                    Transaction.addTransactionWith2TranItems(date: Date(),
                                                             debit: newMoneyAccount,
                                                             credit: newCreditAccount,
                                                             debitAmount: round(creditLimit*100)/100,
                                                             creditAmount: round(creditLimit*100)/100,
                                                             createdByUser: false, context: context)
                } else if balance == 0 && creditLimit == 0 {

                } else if balance - creditLimit > 0 {
                    let debitAmount = round((balance - creditLimit)*100)/100
                    Transaction.addTransactionWith2TranItems(date: Date(),
                                                             debit: newMoneyAccount,
                                                             credit: capitalRootAccount,
                                                             debitAmount: debitAmount,
                                                             creditAmount: round(debitAmount * exchangeRate*100)/100,
                                                             createdByUser: false,
                                                             context: context)
                    if creditLimit != 0 {
                        Transaction.addTransactionWith2TranItems(date: Date(),
                                                                 debit: newMoneyAccount,
                                                                 credit: newCreditAccount,
                                                                 debitAmount: round(creditLimit*100)/100,
                                                                 creditAmount: round(creditLimit*100)/100,
                                                                 createdByUser: false,
                                                                 context: context)
                    }
                } else {
                    var expBeforeAccPeriod = expenseRootAccount.getSubAccountWith(name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod))
                    if expBeforeAccPeriod == nil {
                        expBeforeAccPeriod = try? Account.createAndGetAccount(parent: expenseRootAccount,
                                                                                         name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod),
                                                                                         type: expenseRootAccount.type,
                                                                                         currency: expenseRootAccount.currency,
                                                                                         createdByUser: false,
                                                                                         context: context)
                    }
                    guard let expenseBeforeAccountingPeriodSafe = expBeforeAccPeriod else {
                        throw AccountWithBalanceError.canNotFindBeboreAccountingPeriodAccount
                    }
                    let creditAmount = round((creditLimit - balance)*100)/100
                    Transaction.addTransactionWith2TranItems(date: Date(),
                                                             debit: expenseBeforeAccountingPeriodSafe,
                                                             credit: newMoneyAccount,
                                                             debitAmount: round(creditAmount * exchangeRate*100)/100,
                                                             creditAmount: creditAmount,
                                                             createdByUser: false,
                                                             context: context)
                    Transaction.addTransactionWith2TranItems(date: Date(),
                                                             debit: newMoneyAccount,
                                                             credit: newCreditAccount,
                                                             debitAmount: round(creditLimit*100)/100,
                                                             creditAmount: round(creditLimit*100)/100,
                                                             createdByUser: false,
                                                             context: context)
                }
            }
            try CoreDataStack.shared.saveContext(self.context)
            presenter.accountsDidSaved()
        } catch let error {
            self.context.rollback()
            presenter.showError(error)
        }
    }

    func loadMBUserInfo(for token: String) {
        if !token.isEmpty {
            NetworkServices.loadMBUserInfo(xToken: token, compliting: { (mbUserInfo, xToken, error) in
                if let error = error {
                    self.presenter.showError(error)
                }
                if let mbUserInfo = mbUserInfo, let xToken = xToken {
                    do {
                        self.xToken = xToken
                        self.userInfo = mbUserInfo

                        self.presenter.userInfoDidLoad()

                        if let ubp = mbUserInfo.getUBP(conetxt: self.context) {
                            ubp.xToken = xToken
                            try CoreDataStack.shared.saveContext(self.context)
                            let message = NSLocalizedString("Token has been successfully updated",
                                                            tableName: Constants.Localizable.monobankVC, comment: "")
                            self.presenter.showWarning(message: message)
                        } else {
                            self.presenter.showHolderComponent()
                        }
                    } catch let error {
                        self.presenter.showError(error)
                    }
                }
                self.presenter.unlockGetDataButton()
            })
        } else {
            presenter.showWarning(message: NSLocalizedString("Please enter Token",
                                                             tableName: Constants.Localizable.monobankVC, comment: ""))
        }
    }

    private func getCurrencyExchangeRate() {
        NetworkServices.loadCurrency(date: Date(), compliting: {currencyHistoricalData, error  in
            if let currencyHistoricalData = currencyHistoricalData {
                self.currencyHistoricalData = currencyHistoricalData
            } else if let error = error {
                self.presenter.showError(error)
            }
        })
    }

    private func getRootAccounts() throws { // swiftlint:disable:this cyclomatic_complexity
        Account.getRootAccountList(context: context).forEach({
            switch $0.name {
            case LocalisationManager.getLocalizedName(.money):
                moneyRootAccount = $0
            case LocalisationManager.getLocalizedName(.credits):
                creditsRootAccount = $0
            case LocalisationManager.getLocalizedName(.debtors):
                debtorsRootAcccount = $0
            case LocalisationManager.getLocalizedName(.expense):
                expenseRootAccount = $0
            case LocalisationManager.getLocalizedName(.capital):
                capitalRootAccount = $0
            default:
                break
            }
        })
        if moneyRootAccount == nil {
            throw AccountError.accountDoesNotExist(name: LocalisationManager.getLocalizedName(.money))
        }
        if creditsRootAccount == nil {
            throw AccountError.accountDoesNotExist(name: LocalisationManager.getLocalizedName(.credits))
        }
        if debtorsRootAcccount == nil {
            throw AccountError.accountDoesNotExist(name: LocalisationManager.getLocalizedName(.debtors))
        }
        if expenseRootAccount == nil {
            throw AccountError.accountDoesNotExist(name: LocalisationManager.getLocalizedName(.expense))
        }
        if capitalRootAccount == nil {
            throw AccountError.accountDoesNotExist(name: LocalisationManager.getLocalizedName(.capital))
        }
    }
}
