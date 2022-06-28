//
//  AccountEditorService.swift
//  Accountant
//
//  Created by Roman Topchii on 10.06.2022.
//

import Foundation
import CoreData

protocol AccountEditorServiceDelegate: AnyObject {
    func isValidName(_ isValid: Bool)
    func nameDidSet(_ name: String)
    func typeDidSet(_ accountType: AccountTypeViewModel?, isSingle: Bool, mode: AccountEditorService.Mode)
    func currencyDidSet(_ currency: CurrencyViewModel?, accountingCurrency: CurrencyViewModel)
    func holderDidSet(_ holder: HolderViewModel?)
    func keeperDidSet(_ keeper: KeeperViewModel?)
    func rateDidSet(_ rate: Double?)
    func errorHandler(_ error: Error)
}

class AccountEditorService {

    enum Mode {
        case create
        case edit
    }

    var parentAccountType: AccountTypeViewModel {
        return AccountTypeViewModel(Array(account.type.parents).first!)
    }

    var currency: CurrencyViewModel? {
        if let currency = account.currency {
            return CurrencyViewModel(currency)
        }
        return nil
    }
    var holder: HolderViewModel? {
        if let holder = account.holder {
            return HolderViewModel(holder)
        }
        return nil
    }
    var keeper: KeeperViewModel? {
        if let keeper = account.keeper {
            return KeeperViewModel(keeper)
        }
        return nil
    }
    var canBeRenamed: Bool {
        if mode == .edit && !account.type.canBeRenamed {
            return false
        } else {
            return true
        }
    }

    weak var delegate: AccountEditorServiceDelegate?

    let mode: Mode

    private(set) var persistentContainer: PersistentContainer
    private var context: NSManagedObjectContext

    private let parent: Account
    private var account: Account

    private(set) var date: Date
    private(set) var balance: Double = 0
    private(set) var linkedAccountBalance: Double = 0
    private(set) var rate: Double?

    private let capitalRoot: Account
    private let expenseBeforeAccountingPeriod: Account

    private var accountingCurrency: Currency

    private var isValidName: Bool = false
    private var isValidType: Bool = false

    init(persistentContainer: PersistentContainer, parentAccountId: UUID) {
        mode = .create
        self.persistentContainer = persistentContainer
        self.context = persistentContainer.newBackgroundContext()

        date = Date()

        guard let parent = AccountHelper.getAccountWithId(parentAccountId, context: self.context)
        else {fatalError("Parent should exists, otherwise there is wrong app logic")}

        self.parent = parent

        guard let defultType = parent.type.defultChildType else {
            fatalError("defultChildType should exists if we use this service. " +
                       "use condition accountType.child.isEmpty == false")
        }

        guard let accountingCurrency = CurrencyHelper.getAccountingCurrency(context: context)
        else {fatalError("accounting currency should exists")}

        guard let capitalRoot = AccountHelper.getAccountWithPath(LocalisationManager.getLocalizedName(.capital),
                                                                 context: context),
              let expenseRoot = AccountHelper.getAccountWithPath(LocalisationManager.getLocalizedName(.expense),
                                                                 context: context),
              let expenseBeforeAccountingPeriod = expenseRoot.getSubAccountWith(name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod))
        else {fatalError("default accounts should exists")}

        self.capitalRoot = capitalRoot
        self.expenseBeforeAccountingPeriod = expenseBeforeAccountingPeriod

        self.accountingCurrency = accountingCurrency
        self.account = Account(parent: parent, name: "", type: defultType, currency: accountingCurrency, keeper: nil,
                               holder: nil, context: context)

        try? setType(defultType.id)
    }

    init(persistentContainer: PersistentContainer, accountId: UUID) {
        mode = .edit
        self.persistentContainer = persistentContainer
        self.context = persistentContainer.newBackgroundContext()

        date = Date()

        guard let account = AccountHelper.getAccountWithId(accountId, context: self.context)
        else {fatalError("account should exists, otherwise there is wrong app logic")}

        self.account = account
        self.parent = account.parent!

        guard let accountingCurrency = CurrencyHelper.getAccountingCurrency(context: context)
        else {fatalError("accounting currency should exists")}

        guard let capitalRoot = AccountHelper.getAccountWithPath(LocalisationManager.getLocalizedName(.capital),
                                                                 context: context),
              let expenseRoot = AccountHelper.getAccountWithPath(LocalisationManager.getLocalizedName(.expense),
                                                                 context: context),
              let expenseBeforeAccountingPeriod = expenseRoot.getSubAccountWith(name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod))
        else {fatalError("default accounts should exists")}

        self.capitalRoot = capitalRoot
        self.expenseBeforeAccountingPeriod = expenseBeforeAccountingPeriod

        self.accountingCurrency = accountingCurrency

        try? setType(account.type.id)
    }

    public func provideData() {

        delegate?.typeDidSet(AccountTypeViewModel(account.type),
                             isSingle: parent.type.childrenList.count == 1,
                             mode: mode)

        if let currency = account.currency {
            delegate?.currencyDidSet(CurrencyViewModel(currency),
                                     accountingCurrency: CurrencyViewModel(accountingCurrency))
        } else {
            delegate?.currencyDidSet(nil, accountingCurrency: CurrencyViewModel(accountingCurrency))
        }

        if let holder = account.holder {
            delegate?.holderDidSet(HolderViewModel(holder))
        } else {
            delegate?.holderDidSet(nil)
        }

        if let keeper = account.keeper {
            delegate?.keeperDidSet(KeeperViewModel(keeper))
        } else {
            delegate?.keeperDidSet(nil)
        }

        if mode == .edit {
            delegate?.nameDidSet(account.name)
        }
    }

    public func possibleKeeperType() -> AccountType.KeeperType {
        return account.type.keeperType
    }

    public func setType(_ typeId: UUID) throws {
        guard let type = parent.type.childrenList.filter({$0.id == typeId && $0.canBeCreatedByUser}).first else {
            isValidType = false
            throw Error.paretnTypeDoesntHasChildWithId
        }
        isValidType = true
        account.type = type
        setDefaultValuesForAccountType()
        configureLinkedAccount()
        provideData()
    }

    public func configureLinkedAccount() {
        if mode == .create {
            if let linkedAccountType = account.type.linkedAccountType,
               let parentLinkedAccountType = Array(linkedAccountType.parents).first,
               let linkedParentAccount = try? AccountHelper.getAccountListWithType(typeId: parentLinkedAccountType.id,
                                                                                   context: context).first {

                if let linkedAccount = account.linkedAccount {
                    context.delete(linkedAccount)
                }

                account.linkedAccount = Account(parent: linkedParentAccount, name: account.name,
                                                type: linkedAccountType, currency: account.currency,
                                                keeper: account.keeper, holder: account.holder, context: context)
                account.linkedAccount?.linkedAccount = account
            } else {
                if let linkedAccount = account.linkedAccount {
                    context.delete(linkedAccount)
                }
                account.linkedAccount = nil
                account.linkedAccount?.linkedAccount = nil
            }
        }
        setName(account.name)
    }

    public func setCurrency(_ currencyId: UUID) {
        do {
            if account.type.hasCurrency || account.linkedAccount?.type.hasCurrency == true {
                guard let currency = CurrencyHelper.getById(currencyId, context: context)
                else {throw Error.currencyWithIdNotFound}
                account.currency = currency
                if account.linkedAccount?.type.hasCurrency == true {
                    account.linkedAccount?.currency = currency
                } else {
                    account.linkedAccount?.currency = nil
                }
                delegate?.currencyDidSet(CurrencyViewModel(currency),
                                         accountingCurrency: CurrencyViewModel(accountingCurrency))
            } else {
                account.currency = nil
                delegate?.currencyDidSet(nil, accountingCurrency: CurrencyViewModel(accountingCurrency))
            }

        } catch let error {
            delegate?.errorHandler(error)
        }
    }

    public func setHolder(_ holderId: UUID?) {
        do {
            guard let holderId = holderId
            else {
                account.holder = nil
                if account.type.hasHolder && account.type.linkedAccountType != nil {
                    account.linkedAccount?.holder = nil
                }
                delegate?.holderDidSet(nil)
                return
            }
            guard let holder = HolderHelper.getById(holderId, context: context)
            else {throw Error.holderWithIdNotFound}

            account.holder = holder
            if account.linkedAccount?.type.hasHolder == true {
                account.linkedAccount?.holder = holder
            } else {
                account.linkedAccount?.holder = nil
            }
            delegate?.holderDidSet(HolderViewModel(holder))
        } catch let error {
            delegate?.errorHandler(error)
        }
    }

    public func setKeeper(_ keeperId: UUID?) {
        do {
            guard let keeperId = keeperId else {
                account.keeper = nil
                if account.type.hasKeeper && account.type.linkedAccountType != nil {
                    account.linkedAccount?.keeper = nil
                }
                delegate?.keeperDidSet(nil)
                return
            }
            guard let keeper = KeeperHelper.getById(keeperId, context: context)
            else {throw Error.keeperWithIdNotFound}

            account.keeper = keeper
            if account.linkedAccount?.type.hasKeeper == true {
                account.linkedAccount?.keeper = keeper
            } else {
                account.linkedAccount?.keeper = nil
            }
            delegate?.keeperDidSet(KeeperViewModel(keeper))
        } catch let error {
            delegate?.errorHandler(error)
        }
    }

    public func setName(_ name: String) {

        account.name = name
        account.path = account.pathCalc

        if let linkedAccount = account.linkedAccount {
            linkedAccount.name = name
            linkedAccount.path = linkedAccount.pathCalc
        }

        try? validateName(name)
        delegate?.isValidName(isValidName)
    }

    func setBalanceDate(_ date: Date) {
        self.date = date
    }

    func setBalance(_ balance: Double) {
        self.balance = balance
    }

    func setLinkedAccountBalance(_ balance: Double) {
        self.linkedAccountBalance = balance
    }

    func setRate(_ rate: Double) {
        self.rate = rate
    }

    public func saveChanges(compliting: @escaping(() -> Void), modifiedByUser: Bool = true) {
        do {

            try validateName(account.name)
            delegate?.isValidName(isValidName)

            if isValidType {
                if account.currency == accountingCurrency {
                    rate = 1
                    delegate?.rateDidSet(rate)
                } else {
                    guard rate != nil else {throw Error.emptyExchangeRate}
                    guard rate != 0 else {throw Error.zeroRateValue}
                }

                if account.type.hasInitialBalance && account.type.hasCurrency {
                    createTransactions()
                }

                let modifyDate = Date()

                if mode == .create {
                    account.createDate = modifyDate
                    account.createdByUser = modifiedByUser
                    account.linkedAccount?.createDate = modifyDate
                    account.linkedAccount?.createdByUser = modifiedByUser
                }

                account.modifyDate = modifyDate
                account.modifiedByUser = modifiedByUser
                account.linkedAccount?.modifyDate = modifyDate
                account.linkedAccount?.modifiedByUser = modifiedByUser

                context.save(with: .addAccount)
                compliting()
            }
        } catch {
            delegate?.errorHandler(error)
        }
    }

    private func setDefaultValuesForAccountType() {
        if mode == .create {
            if account.type.hasCurrency {
                account.currency = accountingCurrency
            } else {
                account.currency = nil
            }

            var keeper: Keeper?
            if account.type.hasKeeper {
                if account.type.keeperType == .bank {
                    keeper = try? KeeperHelper.getFirstNonCashKeeper(context: context)
                } else if account.type.keeperType == .cash {
                    keeper = try? KeeperHelper.getCashKeeper(context: context)
                } else if account.type.keeperType == .nonCash {
                    keeper = try? KeeperHelper.getFirstNonCashKeeper(context: context)
                }
            }
            account.keeper = keeper

            var holder: Holder?
            if account.type.hasKeeper {
                holder = HolderHelper.getMe(context: context)
            }
            account.holder = holder
        }
    }

    private func validateName(_ name: String) throws {
        if AccountHelper.isReservedAccountName(name) {
            isValidName = false
            throw Error.reservedName
        } else if name.isEmpty {
            isValidName = false
            throw Error.emptyName
        } else if parent.childrenList.filter({$0.name == name && $0.id != account.id}).isEmpty {
            isValidName = true
            if account.linkedAccount?.parent?.childrenList.filter({$0.name == name && $0.id != account.linkedAccount?.id ?? UUID()}).isEmpty == false {
                isValidName = false
                if account.linkedAccount?.type.hasCurrency == true {
                    throw Error.accountNameAlreadyExists(account.linkedAccount?.pathCalc ?? "")
                } else {
                    throw Error.categoryNameAlreadyExists(account.linkedAccount?.pathCalc ?? "")
                }
            }
        } else {
            isValidName = false
            if account.type.hasCurrency {
                throw Error.accountNameAlreadyExists(account.pathCalc)
            } else {
                throw Error.categoryNameAlreadyExists(account.pathCalc)
            }
        }
    }

    private func createTransactions() {
        if account.linkedAccount != nil {
            createTransactionsForAccountAndLinkedAccount()
        } else if account.type.classification == .assets && balance != 0 {
            createAssetsAccountTransactions()
        } else if account.type.classification == .liabilities && balance != 0 {
            createLiabilityAccountTransactions()
        }
    }

    // swiftlint:disable all
    private func createTransactionsForAccountAndLinkedAccount() {
        guard let linkedAccount = account.linkedAccount, let rate = rate else {return}
        let comment = NSLocalizedString("Initial balance for", tableName: Constants.Localizable.accountEditorService, comment: "") + " " + (account.path) + " " + NSLocalizedString("and", tableName: Constants.Localizable.accountEditorService, comment: "") + " " + (account.linkedAccount?.path ?? "")
        if balance - linkedAccountBalance > 0 {
            let tran1 = TransactionHelper.createAndGetSimpleTran(date: date, debit: account, credit: capitalRoot,
                                                                 debitAmount: round((balance - linkedAccountBalance)*100)/100,
                                                                 creditAmount: round(round((balance - linkedAccountBalance)*100)/100 * rate*100)/100,
                                                                 comment: comment, createdByUser: true, context: context)
            tran1.type = .initialBalance

            let tran2 = TransactionHelper.createAndGetSimpleTran(date: date, debit: account, credit: linkedAccount,
                                                                 debitAmount: round(linkedAccountBalance*100)/100,
                                                                 creditAmount: round(linkedAccountBalance*100)/100,
                                                                 comment: comment, createdByUser: true, context: context)
            tran2.type = .initialBalance
        } else if balance - linkedAccountBalance == 0 && balance != 0 {
            let tran = TransactionHelper.createAndGetSimpleTran(date: date, debit: account, credit: linkedAccount,
                                                                debitAmount: round(balance*100)/100,
                                                                creditAmount: round(balance*100)/100,
                                                                comment: comment, createdByUser: true, context: context)
            tran.type = .initialBalance
        } else if balance - linkedAccountBalance < 0 {
            let tran1 = TransactionHelper.createAndGetSimpleTran(date: date, debit: expenseBeforeAccountingPeriod, credit: account,
                                                                 debitAmount: round(round((linkedAccountBalance - balance)*100)/100 * rate*100)/100,
                                                                 creditAmount: round((linkedAccountBalance - balance)*100)/100,
                                                                 comment: comment, createdByUser: true, context: context)
            tran1.type = .initialBalance

            let tran2 = TransactionHelper.createAndGetSimpleTran(date: date, debit: account, credit: linkedAccount,
                                                                 debitAmount: round(linkedAccountBalance*100)/100,
                                                                 creditAmount: round(linkedAccountBalance*100)/100,
                                                                 comment: comment, createdByUser: true, context: context)
            tran2.type = .initialBalance
        }
    }

    private func createAssetsAccountTransactions() {
        guard let rate = rate else {return}
        let comment = NSLocalizedString("Initial balance for", tableName: Constants.Localizable.accountEditorService, comment: "") + " " + (account.path)
        let tran1 = TransactionHelper.createAndGetSimpleTran(date: date, debit: account, credit: capitalRoot,
                                                             debitAmount: round(balance*100)/100,
                                                             creditAmount: round(round(balance*100)/100 * rate*100)/100,
                                                             comment: comment, createdByUser: true, context: context)
        tran1.type = .initialBalance
    }

    private func createLiabilityAccountTransactions() {
        guard let rate = rate else {return}
        let comment = NSLocalizedString("Initial balance for", tableName: Constants.Localizable.accountEditorService, comment: "") + " " + (account.path)
        let tran1 = TransactionHelper.createAndGetSimpleTran(date: date, debit: expenseBeforeAccountingPeriod, credit: account,
                                                             debitAmount: (balance * rate*100)/100,
                                                             creditAmount: balance,
                                                             comment: comment, createdByUser: true, context: context)
        tran1.type = .initialBalance
    }
    // swiftlint:enable all
}
