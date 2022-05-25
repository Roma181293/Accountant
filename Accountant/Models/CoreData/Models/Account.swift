//
//  Account.swift
//  Accountant
//
//  Created by Roman Topchii on 08.03.2022.
//

import Foundation
import CoreData
import Charts

final class Account: BaseEntity {
    
    @objc enum TypeEnum: Int16 {
        case liabilities = 0
        case assets = 1
    }

    @objc enum SubTypeEnum: Int16 {
        case none = 0
        case cash = 1
        case debitCard = 2
        case creditCard = 3
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var active: Bool
    @NSManaged public var name: String
    @NSManaged public var path: String
    @NSManaged public var subType: SubTypeEnum
    @NSManaged public var type: TypeEnum
    @NSManaged public var bankAccount: BankAccount?
    @NSManaged public var currency: Currency?
    @NSManaged public var directChildren: Set<Account>!
    @NSManaged public var holder: Holder?
    @NSManaged public var keeper: Keeper?
    @NSManaged public var linkedAccount: Account?
    @NSManaged public var parent: Account?
    @NSManaged public var transactionItems: Set<TransactionItem>!

    convenience init(parent: Account?, name: String, type: TypeEnum, currency: Currency?, keeper: Keeper?,
                     holder: Holder?, subType: SubTypeEnum?, createdByUser: Bool = true,
                     createDate: Date = Date(), context: NSManagedObjectContext) {

        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        if let parent = parent {
            self.parent = parent
            self.type = parent.type
            self.active = parent.active
        } else {
            self.type = type
            self.active = true
        }
        self.name = name
        self.path = pathCalc
        self.currency = currency
        self.keeper = keeper
        self.holder = holder
        self.subType = subType ?? .none
    }

    convenience init(parent: Account, name: String, createdByUser: Bool = true,
                     createDate: Date = Date(), context: NSManagedObjectContext) {

        self.init(id: UUID(), createdByUser: createdByUser, createDate: createDate, context: context)
        self.parent = parent
        self.name = name
        self.path = pathCalc
        self.currency = parent.currency
        self.type = parent.type
        self.active = parent.active
    }

    var rootAccount: Account {
        if let parent = parent {
            return parent.rootAccount
        }
        return self
    }

    var ancestorList: [Account] {
        if let parent = parent {
            return [parent] + parent.ancestorList
        }
        return []
    }

    var pathCalc: String {
        if let parent = parent {
            return parent.pathCalc + ":" + name
        }
        return name
    }

    var level: Int {
        if let parent = parent {
            return parent.level + 1
        }
        return 0
    }

    var directChildrenList: [Account] {
        return Array(directChildren)
    }

    var childrenList: [Account] {
        var result: [Account] = self.directChildrenList
        for child in directChildrenList {
            result.append(contentsOf: child.childrenList)
        }
        return result
    }

    var transactionItemsList: [TransactionItem] {
        return Array(transactionItems)
    }

    var appliedTransactionItemsList: [TransactionItem] {
        return transactionItemsList.filter({$0.transaction!.status == .applied})
    }

    var isFreeFromTransactionItems: Bool {
        return transactionItemsList.isEmpty
    }

    var canBeRenamed: Bool {
        if Account.isReservedAccountName(name) {
            return false
        }
        return true
    }

    func accountListUsingInTransactions() -> [Account] {
        var accounts = childrenList
        accounts.append(self)
        return accounts.filter({$0.isFreeFromTransactionItems == false})
    }

    func getSubAccountWith(name: String) -> Account? {
        for child in childrenList where child.name == name {
            return child
        }
        return nil
    }

    func changeActiveStatus(modifiedByUser: Bool = true, modifyDate: Date = Date()) throws {
        if parent?.parent == nil &&
            parent?.currency == nil &&
            self.balance != 0 &&
            self.active == true {
            throw AccountError.accumulativeAccountCannotBeHiddenWithNonZeroAmount(name: self.path)
        }

        let oldActive = self.active

        self.active = !oldActive
        self.modifyDate = modifyDate
        self.modifiedByUser = modifiedByUser

        if oldActive {// deactivation
            for anc in self.childrenList.filter({$0.active == oldActive}) {
                anc.active = !oldActive
                anc.modifyDate = modifyDate
                anc.modifiedByUser = modifiedByUser
            }
        } else {// activation
            for anc in self.ancestorList.filter({$0.active == oldActive}) {
                anc.active = !oldActive
                anc.modifyDate = modifyDate
                anc.modifiedByUser = modifiedByUser
            }
        }
    }

    func rename(to newName: String, context: NSManagedObjectContext) throws {
        guard Account.isReservedAccountName(newName) == false else {throw AccountError.reservedName(name: newName)}
        guard Account.isFreeAccountName(parent: self.parent, name: newName, context: context)
        else {
            if self.parent?.currency == nil {
                throw AccountError.accountAlreadyExists(name: newName)
            } else {
                throw AccountError.categoryAlreadyExists(name: newName)
            }
        }
        self.name = newName
        self.modifyDate = Date()
        self.modifiedByUser = true
    }

    func canBeRemoved() throws {
        var accounts = childrenList
        accounts.append(self)
        var accountUsedInTransactionItem: [Account] = []
        for acc in accounts where !acc.isFreeFromTransactionItems {
            accountUsedInTransactionItem.append(acc)
        }

        if !accountUsedInTransactionItem.isEmpty {
            var accountListString: String = ""
            accountUsedInTransactionItem.forEach({
                accountListString += "\n" + $0.path
            })

            if parent?.currency == nil {
                throw AccountError.cantRemoveAccountThatUsedInTransactionItem(name: accountListString)
            } else {
                throw AccountError.cantRemoveCategoryThatUsedInTransactionItem(name: accountListString)
            }
        }
        if let linkedAccount = linkedAccount, !linkedAccount.isFreeFromTransactionItems {
            throw AccountError.linkedAccountHasTransactionItem(name: linkedAccount.path)
        }
    }

    func delete(eligibilityChacked: Bool = false) throws {
        var accounts = childrenList
        accounts.append(self)
        if eligibilityChacked == false {
            try canBeRemoved()
            if let linkedAccount = linkedAccount {
                accounts.append(linkedAccount)
            }
            accounts.forEach({
                managedObjectContext?.delete($0)
            })
        } else {
            if let linkedAccount = linkedAccount {
                accounts.append(linkedAccount)
            }
            accounts.forEach({
                managedObjectContext?.delete($0)
            })
        }
    }
}

// MARK: - BALANCE
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

        if type == TypeEnum.assets {
            return debitTotal - creditTotal
        } else {
            return creditTotal - debitTotal
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

        if type == TypeEnum.assets {
            return debit - credit
        } else {
            return credit - debit
        }
    }

    private static func createDateIntervalArray(dateInterval: DateInterval,
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
                    if  accounts[0].type == TypeEnum.assets {
                        result.append((date: timeInterval.end,
                                       value: round((result[index].value + debitTotal - creditTotal)*100)/100))
                    } else {
                        result.append((date: timeInterval.end,
                                       value: round((result[index].value + creditTotal - debitTotal)*100)/100))
                    }
                } else {
                    if accounts[0].type == TypeEnum.assets {
                        result.append((date: timeInterval.end,
                                       value: round((debitTotal - creditTotal)*100)/100))
                    } else {
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

// MARK: - method for charts
extension Account {
    func prepareDataToShow(dateInterval: DateInterval, selectedCurrency: Currency, currencyHistoricalData: CurrencyHistoricalDataProtocol? = nil, dateComponent: Calendar.Component, isListForAnalytic: Bool, sortTableDataBy: SortCategoryType, context: NSManagedObjectContext) throws -> PresentingData {  // swiftlint:disable:this cyclomatic_complexity function_body_length function_parameter_count line_length

        var accountsToShow: [Account] = directChildrenList
        if !(rootAccount.name == LocalisationManager.getLocalizedName(.money) ||
             rootAccount.name == LocalisationManager.getLocalizedName(.credits) ||
             rootAccount.name == LocalisationManager.getLocalizedName(.debtors)) {
            accountsToShow.append(self)
        }

        if isListForAnalytic == false {
            accountsToShow = accountsToShow.filter({
                if $0.active {
                    return true
                } else {
                    return false
                }
            })
        }

        var accountsData: [AccountData] = []
        var lineChartDataSet: [LineChartDataSet] = []

        var tempData: [(
            lineChartDataSet: LineChartDataSet,
            account: Account,
            title: String,
            amountInAccountCurrency: Double,
            amountInSelectedCurrency: Double,
            checkSum: Double)] = []

        var maxValue: Double = 0
        var minValue: Double = 0

        for account in accountsToShow {
            var title = ""
            var arrayOfResultsForTmpAccount: [(date: Date, value: Double)] = []
            if account != self {
                title = account.name
                arrayOfResultsForTmpAccount = account.balance(dateInterval: dateInterval,
                                                              dateComponent: dateComponent,
                                                              calcIncludedAccountsBalances: true)
            } else {
                title = LocalisationManager.getLocalizedName(.other)
                arrayOfResultsForTmpAccount = account.balance(dateInterval: dateInterval,
                                                              dateComponent: dateComponent,
                                                              calcIncludedAccountsBalances: false)
            }

            // convert (date: Date, value: Double) to ChartDataEntry(x:Double, y: Double)
            var entries: [ChartDataEntry] = []
            var checkSum: Double = 0
            for item in arrayOfResultsForTmpAccount {
                checkSum += item.value
                if item.value > maxValue {
                    maxValue = item.value
                } else if item.value < minValue {
                    minValue = item.value
                }
                entries.append(ChartDataEntry(x: item.date.timeIntervalSince1970, y: item.value))
            }

            let set  = LineChartDataSet(entries: entries, label: account.name)
            set.axisDependency = .left
            set.lineWidth = 3
            set.drawCirclesEnabled = false
            set.drawValuesEnabled = false
            set.fillAlpha = 1
            set.drawCircleHoleEnabled = false

            var amountInAccountCurrency: Double {
                if arrayOfResultsForTmpAccount.isEmpty == false {
                    return arrayOfResultsForTmpAccount.last!.value
                }
                return 0
            }

            var amountInSelectedCurrency: Double {
                if selectedCurrency == account.currency {
                    return amountInAccountCurrency
                } else if amountInAccountCurrency != 0,
                          let currencyHistoricalData = currencyHistoricalData,
                          let accountCurrency = account.currency {

                    var exchangeRate: Double = 1
                    if let rate =  currencyHistoricalData.exchangeRate(pay: selectedCurrency.code,
                                                                       forOne: accountCurrency.code) {
                        exchangeRate = rate
                    }
                    return round(amountInAccountCurrency * exchangeRate * 100) / 100
                }
                return 0
            }
            tempData.append((lineChartDataSet: set,
                             account: account,
                             title: title,
                             amountInAccountCurrency: amountInAccountCurrency,
                             amountInSelectedCurrency: amountInSelectedCurrency,
                             checkSum: checkSum))
        }

        // filtered and ordered items
        if isListForAnalytic {
            tempData = tempData.filter({$0.checkSum != 0})
        }
        tempData.sort(by: {$0.amountInSelectedCurrency >= $1.amountInSelectedCurrency})

        // Coloring
        for (index, item) in tempData.enumerated() {
            let colorSet = Constants.ColorSetForCharts.set1
            var color: NSUIColor!
            if index < colorSet.count {
                color = colorSet[index]
                item.lineChartDataSet.setColor(colorSet[index])
            } else {
                color = UIColor(red: CGFloat.random(in: 0...255) / 255,
                                green: CGFloat.random(in: 0...255) / 255,
                                blue: CGFloat.random(in: 0...255) / 255,
                                alpha: 1)
            }
            item.lineChartDataSet.setColor(color)
            lineChartDataSet.append(item.lineChartDataSet)
            accountsData.append(AccountData(account: item.account,
                                            title: item.title,
                                            color: color,
                                            amountInAccountCurrency: item.amountInAccountCurrency,
                                            amountInSelectedCurrency: item.amountInSelectedCurrency))
        }
        return PresentingData(dateInterval: dateInterval,
                              presentingCurrency: selectedCurrency,
                              lineChartData: ChartData(minValue: minValue,
                                                       maxValue: maxValue,
                                                       lineChartDataSet: lineChartDataSet),
                              tableData: accountsData,
                              sortTableDataBy: sortTableDataBy)
    }
}

// MARK: - Static methods
extension Account {
    private static var reservedAccountNames: [String] {
        return [
            // EN
            "Income",
            "Expenses",
            "Capital",
            "Money",
            "Debtors",
            "Creditors",
            "Before accounting period",
            "<Other>",
            "Other",
            // UA
            "Доходи",
            "Витрати",
            "Гроші",
            "Борги",
            "Боржники",
            "Капітал",
            "До обліковий період",
            "<Інше>",
            "Інше",
            // RU
            "Доходы",
            "Расходы",
            "Деньги",
            "Долги",
            "Должники",
            "Капитал",
            "До учетный период",
            "<Прочее>",
            "Прочее"
        ]
    }

    static func isReservedAccountName(_ name: String) -> Bool {
        for item in reservedAccountNames {
            if item.uppercased() == name.uppercased() {
                return true
            }
        }
        return false
    }

    static func isFreeAccountName(parent: Account?, name: String, context: NSManagedObjectContext) -> Bool {
        if let parent = parent {
            for child in parent.childrenList where child.name == name {
                return false
            }
            return true
        } else {
            let fetchRequest: NSFetchRequest<Account> = fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue) = nil and \(Schema.Account.name.rawValue) = %@", name)
            do {
                let accounts = try context.fetch(fetchRequest)
                if accounts.isEmpty {
                    return true
                } else {
                    return false
                }
            } catch let error {
                print("ERROR", error)
                return false
            }
        }
    }

    static func createAndGetAccount(parent: Account?, name: String, type: TypeEnum, currency: Currency?,
                                    keeper: Keeper? = nil, holder: Holder? = nil, subType: SubTypeEnum? = nil,
                                    createdByUser: Bool = true, createDate: Date = Date(),
                                    impoted: Bool = false, context: NSManagedObjectContext)
    throws -> Account {

        try validateAttributes(parent: parent, name: name, type: type, currency: currency, keeper: keeper,
                               holder: holder, subType: subType, createdByUser: createdByUser,
                               impoted: impoted, context: context)

        // Adding "Other" account for cases when parent containts transactions
        if let parent = parent, parent.isFreeFromTransactionItems == false,
           Account.isReservedAccountName(name) == false {
            var newAccount = parent.getSubAccountWith(name: LocalisationManager.getLocalizedName(.other1))
            if newAccount == nil {
                newAccount = try createAndGetAccount(parent: parent,
                                                     name: LocalisationManager.getLocalizedName(.other1),
                                                     type: type, currency: currency, keeper: keeper, holder: holder,
                                                     subType: subType, createdByUser: false, createDate: createDate,
                                                     context: context)
            }
            if newAccount != nil {
                TransactionItem.moveTransactionItemsFrom(oldAccount: parent, newAccount: newAccount!,
                                                         modifiedByUser: createdByUser, modifyDate: createDate)
            }
        }

        return Account(parent: parent, name: name, type: type, currency: currency, keeper: keeper, holder: holder,
                       subType: subType, createdByUser: createdByUser, createDate: createDate, context: context)
    }

    static func createAccount(parent: Account?, name: String, type: TypeEnum, currency: Currency?,
                              keeper: Keeper? = nil, holder: Holder? = nil, subType: SubTypeEnum? = nil,
                              createdByUser: Bool = true, impoted: Bool = false,
                              context: NSManagedObjectContext) throws {

        _ = try createAndGetAccount(parent: parent, name: name, type: type, currency: currency,
                                    keeper: keeper, holder: holder, subType: subType, createdByUser: createdByUser,
                                    createDate: Date(), impoted: impoted, context: context)
    }

    private static func validateAttributes(parent: Account?, name: String, type: TypeEnum, currency: Currency?,
                                           keeper: Keeper? = nil, holder: Holder? = nil, subType: SubTypeEnum? = nil,
                                           createdByUser: Bool = true, impoted: Bool = false,
                                           context: NSManagedObjectContext) throws {

        guard !name.isEmpty else {throw AccountError.emptyName}
        // accounts with reserved names can create only app
        if !impoted {
            guard createdByUser == false || isReservedAccountName(name) == false
            else {throw AccountError.reservedName(name: name)}
        }
        guard isFreeAccountName(parent: parent, name: name, context: context) == true else {
            if parent?.currency == nil {
                throw AccountError.accountAlreadyExists(name: name)
            } else {
                throw AccountError.categoryAlreadyExists(name: name)
            }
        }
    }

    static func changeCurrencyForBaseAccounts(to currency: Currency, modifyDate: Date = Date(),
                                              modifiedByUser: Bool = true, context: NSManagedObjectContext) {
        let baseAccounts: [Account] = getRootAccountList(context: context)
        var acc: [Account] = []
        for item in baseAccounts {
            if let currency = item.currency, currency.isAccounting == true {
                acc.append(contentsOf: item.childrenList)
                acc.append(item)
            }
        }
        for account in acc {
            account.currency = currency
            account.modifiedByUser = modifiedByUser
            account.modifyDate = modifyDate
        }
    }

    static func getRootAccountList(context: NSManagedObjectContext) -> [Account] {
        let fetchRequest: NSFetchRequest<Account> = fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue) = nil")
        return (try? context.fetch(fetchRequest)) ?? []
    }

    static func getAccountList(context: NSManagedObjectContext) throws -> [Account] {
        let accountFetchRequest: NSFetchRequest<Account> = fetchRequest()
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        return try context.fetch(accountFetchRequest)
    }

    static func getAccountWithPath(_ path: String, context: NSManagedObjectContext) -> Account? {
        let fetchRequest: NSFetchRequest<Account> = fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        do {
            let accounts = try context.fetch(fetchRequest)
            if !accounts.isEmpty {
                for account in accounts where account.path == path {
                    return account
                }
                return nil
            } else {
                return nil
            }
        } catch let error {
            print("ERROR", error)
            return nil
        }
    }

    static func exportAccountsToString(context: NSManagedObjectContext) -> String {
        let accountFetchRequest: NSFetchRequest<Account> = fetchRequest()
        let sortDescroptors = [NSSortDescriptor(key: "\(Schema.Account.parent.rawValue).\(Schema.Account.name.rawValue)", ascending: true),
                               NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
        accountFetchRequest.sortDescriptors = sortDescroptors
        do {
            let storedAccounts = try context.fetch(accountFetchRequest)
            var export: String = "ParentAccount_path,Account_name,active,Account_type,Account_currency,Account_SubType,LinkedAccount_path\n"
            for account in storedAccounts {

                var accountType = ""
                switch account.type {
                case TypeEnum.assets:
                    accountType = "Assets"
                case TypeEnum.liabilities:
                    accountType = "Liabilities"
                default:
                    accountType = "Out of enumeration"
                }

                var accountSubType = ""
                switch account.subType {
                case SubTypeEnum.none:
                    accountSubType = ""
                case SubTypeEnum.cash:
                    accountSubType = "Cash"
                case SubTypeEnum.debitCard:
                    accountSubType = "DebitCard"
                case SubTypeEnum.creditCard:
                    accountSubType = "CreditCard"
                default:
                    accountSubType = "Out of enumeration"
                }

                export +=  "\(account.parent != nil ? account.parent!.path : "" ),"
                export +=  "\(account.name),"
                export +=  "\(account.active),"
                export +=  "\(accountType),"
                export +=  "\(account.currency?.code ?? "MULTICURRENCY"),"
                export +=  "\(accountSubType),"
                export +=  "\(account.linkedAccount != nil ? account.linkedAccount!.path: "" )\n"
            }
            return export
        } catch let error {
            print("ERROR", error)
            return ""
        }
    }

    static func importAccounts(_ data: String, context: NSManagedObjectContext) throws { // swiftlint:disable:this cyclomatic_complexity function_body_length

        var accountToBeAdded: [Account] = []
        var inputMatrix: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            inputMatrix.append(columns)
        }
        inputMatrix.remove(at: 0)

        for row in inputMatrix {
            guard row.count > 1 else {break}

            let parent = Account.getAccountWithPath(row[0], context: context)

            let name = String(row[1])

            var active = false
            switch row[2] {
            case "false":
                active = false
            case "true":
                active = true
            default:
                break // throw ImportAccountError.invalidactiveValue
            }

            var accountType: Int16 = 0
            switch row[3] {
            case "Assets":
                accountType = TypeEnum.assets.rawValue
            case "Liabilities":
                accountType = TypeEnum.liabilities.rawValue
            default:
                break // throw ImportAccountError.invalidAccountTypeValue
            }

            let curency = try? Currency.getCurrencyForCode(row[4], context: context)

            var accountSubType: Int16 = 0
            switch row[5] {
            case "":
                accountSubType = 0
            case "Cash":
                accountSubType = 1
            case "DebitCard":
                accountSubType = 2
            case "CreditCard":
                accountSubType = 3
            default:
                break // throw ImportAccountError.invalidAccountSubTypeValue
            }

            let linkedAccount = Account.getAccountWithPath(row[6], context: context)

            let account = try? Account.createAndGetAccount(parent: parent,
                                                           name: name,
                                                           type: TypeEnum(rawValue: accountType)!,
                                                           currency: curency,
                                                           impoted: true,
                                                           context: context)
            account?.linkedAccount = linkedAccount
            account?.subType = SubTypeEnum(rawValue: accountSubType) ?? .none
            account?.active = active

            // CHECKING
            if let account = account {
                accountToBeAdded.append(account)
                var accountTypes = ""
                switch account.type {
                case TypeEnum.assets:
                    accountTypes = "Assets"
                case TypeEnum.liabilities:
                    accountTypes = "Liabilities"
                default:
                    accountTypes = "Out of enumeration"
                }

                var accountSubTypes = ""
                switch account.subType {
                case SubTypeEnum.none:
                    accountSubTypes = ""
                case SubTypeEnum.cash:
                    accountSubTypes = "Cash"
                case SubTypeEnum.debitCard:
                    accountSubTypes = "DebitCard"
                case SubTypeEnum.creditCard:
                    accountSubTypes = "CreditCard"
                default:
                    accountSubTypes = "Out of enumeration"
                }
                var export = ""
                export +=  "\(account.parent != nil ? account.parent!.path: "" ),"
                export +=  "\(account.name),"
                export +=  "\(account.active),"
                export +=  "\(accountTypes),"
                export +=  "\(account.currency?.code ?? "MULTICURRENCY"),"
                export +=  "\(accountSubTypes),"
                export +=  "\(account.linkedAccount != nil ? account.linkedAccount!.path: "" )\n"
                //            print(export)
            } else {
                print("There is no account")
            }
        }
    }
}
