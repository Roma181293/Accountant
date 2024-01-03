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

    private var currencyHistoricalData: CurrencyHistoricalData?
    private var moneyRootAccount: Account!
    private var creditsRootAccount: Account!
    private var debtorsRootAcccount: Account!
    private var expenseRootAccount: Account!
    private var capitalRootAccount: Account!

    required init(presenter: MonobankUBPPresenterProtocol) {
        self.presenter = presenter
        self.holder = HolderHelper.getMe(context: context)
        getCurrencyExchangeRate()
    }

    func createAccounts() { // swiftlint:disable:this function_body_length cyclomatic_complexity
        guard let userInfo = userInfo else {return}
        do {
            try getRootAccounts()

            let ubp = try UserBankProfileHelper.getOrCreateMonoBankUBP(userInfo, xToken: xToken, context: self.context)

            for item in userInfo.accounts.filter({return !$0.isExists(context: context)}) {
                guard AccountHelper.isFreeAccountName(parent: moneyRootAccount,
                                                      name: item.maskedPan.last! ,
                                                      context: context)
                else {
                    throw Account.Error.accountNameAlreadyTaken(name: moneyRootAccount.name+":"+item.maskedPan.last!)
                }

                let bankAccount = try BankAccountHelper.createAndGetMBBankAccount(item, userBankProfile: ubp,
                                                                                  context: context)

                var exchangeRate: Double = 1
                // Check balance value
                let balance: Double = Double(item.balance) / 100
                let creditLimit: Double = Double(item.creditLimit) / 100

                guard let currency = item.getCurrency(context: context) else {return}
                guard let accountingCurrency = CurrencyHelper.getAccountingCurrency(context: context)
                else {throw Currency.Error.accountingCurrencyNotFound}
                guard  let keeper = try KeeperHelper.getKeeperForName("Monobank", context: context)
                else {throw Keeper.Error.keeperNotFound(name: "Monobank")}

                // Check credit account name is free
                guard AccountHelper.isFreeAccountName(parent: creditsRootAccount,
                                                      name: item.maskedPan.last! ,
                                                      context: context)
                else {throw Account.Error.creditAccountAlreadyExist(creditsRootAccount.name + item.maskedPan.last!)}

                // Check exchange rate value
                if currency != accountingCurrency {
                    guard let currencyHistoricalData = currencyHistoricalData,
                          let rate = currencyHistoricalData.exchangeRate(pay: accountingCurrency.code,
                                                                         forOne: currency.code)
                    else {return}
                    exchangeRate = rate
                }

                let newMoneyAccount = try AccountHelper.createAndGetAccount(parent: moneyRootAccount,
                                                                            name: item.maskedPan.last!,
                                                                            type: AccountTypeHelper.getBy(.creditCard, context: context),
                                                                            currency: currency,
                                                                            keeper: keeper, holder: holder,
                                                                            context: context)

                newMoneyAccount.bankAccount = bankAccount

                let newCreditAccount = try AccountHelper.createAndGetAccount(parent: creditsRootAccount,
                                                                             name: item.maskedPan.last!,
                                                                             type: creditsRootAccount.type.defultChildType!,
                                                                             currency: currency,
                                                                             keeper: keeper, holder: holder,
                                                                             context: context)

                newMoneyAccount.linkedAccount = newCreditAccount

                if balance - creditLimit == 0 && balance != 0 {
                    let tran = TransactionHelper.createAndGetSimpleTran(date: Date(),
                                                       debit: newMoneyAccount,
                                                       credit: newCreditAccount,
                                                       debitAmount: round(creditLimit*100)/100,
                                                       creditAmount: round(creditLimit*100)/100,
                                                       createdByUser: false, context: context)
                    tran.type = .initialBalance
                } else if balance == 0 && creditLimit == 0 {
                    // No transaaction requiered
                } else if balance - creditLimit > 0 {
                    let debitAmount = round((balance - creditLimit)*100)/100
                    let tran = TransactionHelper.createAndGetSimpleTran(date: Date(),
                                                       debit: newMoneyAccount,
                                                       credit: capitalRootAccount,
                                                       debitAmount: debitAmount,
                                                       creditAmount: round(debitAmount * exchangeRate*100)/100,
                                                       createdByUser: false,
                                                       context: context)
                    tran.type = .initialBalance
                    if creditLimit != 0 {
                        let tran = TransactionHelper.createAndGetSimpleTran(date: Date(),
                                                           debit: newMoneyAccount,
                                                           credit: newCreditAccount,
                                                           debitAmount: round(creditLimit*100)/100,
                                                           creditAmount: round(creditLimit*100)/100,
                                                           createdByUser: false,
                                                           context: context)
                        tran.type = .initialBalance
                    }
                } else {
                    var expBeforeAccPeriod = expenseRootAccount.getSubAccountWith(name: LocalizationManager.getLocalizedName(.beforeAccountingPeriod))
                    if expBeforeAccPeriod == nil {
                        expBeforeAccPeriod = try? AccountHelper.createAndGetAccount(parent: expenseRootAccount,
                                                                                    name: LocalizationManager.getLocalizedName(.beforeAccountingPeriod),
                                                                                    type: expenseRootAccount.type,
                                                                                    currency: expenseRootAccount.currency,
                                                                                    createdByUser: false,
                                                                                    context: context)
                    }
                    guard let expenseBeforeAccountingPeriodSafe = expBeforeAccPeriod else {return}
                    let creditAmount = round((creditLimit - balance)*100)/100
                    let tran1 = TransactionHelper.createAndGetSimpleTran(date: Date(),
                                                       debit: expenseBeforeAccountingPeriodSafe,
                                                       credit: newMoneyAccount,
                                                       debitAmount: round(creditAmount * exchangeRate*100)/100,
                                                       creditAmount: creditAmount,
                                                       createdByUser: false,
                                                       context: context)
                    let tran2 = TransactionHelper.createAndGetSimpleTran(date: Date(),
                                                       debit: newMoneyAccount,
                                                       credit: newCreditAccount,
                                                       debitAmount: round(creditLimit*100)/100,
                                                       creditAmount: round(creditLimit*100)/100,
                                                       createdByUser: false,
                                                       context: context)
                    tran1.type = .initialBalance
                    tran2.type = .initialBalance
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
        AccountHelper.getRootAccountList(context: context).forEach({
            switch $0.name {
            case LocalizationManager.getLocalizedName(.money):
                moneyRootAccount = $0
            case LocalizationManager.getLocalizedName(.credits):
                creditsRootAccount = $0
            case LocalizationManager.getLocalizedName(.debtors):
                debtorsRootAcccount = $0
            case LocalizationManager.getLocalizedName(.expense):
                expenseRootAccount = $0
            case LocalizationManager.getLocalizedName(.capital):
                capitalRootAccount = $0
            default:
                break
            }
        })
        if moneyRootAccount == nil {
            throw Account.Error.accountDoesNotExist(name: LocalizationManager.getLocalizedName(.money))
        }
        if creditsRootAccount == nil {
            throw Account.Error.accountDoesNotExist(name: LocalizationManager.getLocalizedName(.credits))
        }
        if debtorsRootAcccount == nil {
            throw Account.Error.accountDoesNotExist(name: LocalizationManager.getLocalizedName(.debtors))
        }
        if expenseRootAccount == nil {
            throw Account.Error.accountDoesNotExist(name: LocalizationManager.getLocalizedName(.expense))
        }
        if capitalRootAccount == nil {
            throw Account.Error.accountDoesNotExist(name: LocalizationManager.getLocalizedName(.capital))
        }
    }
}
