//
//  Account.swift
//  Accountant
//
//  Created by Roman Topchii on 08.03.2022.
//

import Foundation
import CoreData
import Charts

extension Account {
    
    convenience init(parent: Account?, name : String, type : Int16?, currency : Currency?, keeper: Keeper?, holder: Holder?, subType : Int16? = nil, createdByUser : Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) {
        
        self.init(context: context)
        self.id = UUID()
        self.createDate = createDate
        self.createdByUser = createdByUser
        self.modifyDate = createDate
        self.modifiedByUser = createdByUser
        self.name = name
        
        self.currency = currency
        self.keeper = keeper
        self.holder = holder
        
        if let subType = subType {
            self.subType = subType
        }
        
        if let parent = parent {
            self.parent = parent
            self.type = parent.type
            self.active = parent.active
        }
        else {
            self.type = type!
            self.active = true
        }
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
    
    var path: String {
        if let parent = parent {
            return parent.path + ":" + name!
        }
        return name!
    }
    
    var level: Int {
        if let parent = parent {
            return parent.level + 1
        }
        return 0
    }
    
    var directChildrenList: [Account] {
        return directChildren?.allObjects as! [Account]
    }
    
    var childrenList: [Account] {
        var result: [Account] = self.directChildrenList
        for child in directChildrenList {
            result.append(contentsOf: child.childrenList)
        }
        return result
    }
    
    var transactionItemsList: [TransactionItem] {
        return transactionItems?.allObjects as! [TransactionItem]
    }
    
    var appliedTransactionItemsList: [TransactionItem] {
        return transactionItemsList.filter{$0.transaction!.applied == true}
    }
    
    var isFreeFromTransactionItems: Bool {
        return transactionItemsList.isEmpty
    }
    
    func accountListUsingInTransactions() -> [Account] {
        var accounts = childrenList
        accounts.append(self)
        return accounts.filter({$0.isFreeFromTransactionItems == false})
    }
    
    func getSubAccountWith(name: String) -> Account? {
        for child in childrenList {
            if child.name == name {
                return child
            }
        }
        return nil
    }
    
    func changeActiveStatus(modifiedByUser : Bool = true, modifyDate: Date = Date()) throws {
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
        
        if oldActive {//deactivation
            for anc in self.childrenList.filter({$0.active == oldActive}) {
                anc.active = !oldActive
                anc.modifyDate = modifyDate
                anc.modifiedByUser = modifiedByUser
            }
        }
        else {//activation
            for anc in self.ancestorList.filter({$0.active == oldActive}) {
                anc.active = !oldActive
                anc.modifyDate = modifyDate
                anc.modifiedByUser = modifiedByUser
            }
        }
    }
    
    var canBeRenamed: Bool {
        if Account.isReservedAccountName(name!){
            return false
        }
        return true
    }
    
    
    func renameAccount(to newName : String, context : NSManagedObjectContext) throws {
        guard Account.isReservedAccountName(newName) == false else {throw AccountError.reservedName(name: newName)}
        guard Account.isFreeAccountName(parent: self.parent, name: newName, context: context)
        else {
            if self.parent?.currency == nil {
                throw AccountError.accountAlreadyExists(name: newName)
            }
            else {
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
        
        var accountUsedInTransactionItem : [Account] = []
        for acc in accounts{
            if !acc.isFreeFromTransactionItems {
                accountUsedInTransactionItem.append(acc)
            }
        }
        
        if !accountUsedInTransactionItem.isEmpty {
            var accountListString : String = ""
            accountUsedInTransactionItem.forEach({
                accountListString += "\n" + $0.path
            })
            
            if parent?.currency == nil {
                throw AccountError.cantRemoveAccountThatUsedInTransactionItem(accountListString)
            }
            else {
                throw AccountError.cantRemoveCategoryThatUsedInTransactionItem(accountListString)
            }
        }
        
        if let linkedAccount = linkedAccount, !linkedAccount.isFreeFromTransactionItems {
            throw AccountError.linkedAccountHasTransactionItem(name: linkedAccount.path)
        }
    }
    
    func removeAccount(eligibilityChacked: Bool, context: NSManagedObjectContext) throws {
        var accounts = childrenList
        accounts.append(self)
        if eligibilityChacked == false {
            try canBeRemoved()
            accounts.forEach({
                context.delete($0)
            })
        }
        else {
            if let linkedAccount = linkedAccount {
                accounts.append(linkedAccount)
            }
            accounts.forEach({
                context.delete($0)
            })
        }
    }
}


// MARK: - BALANCE
extension Account{
    var balance : Double {
        var debitTotal : Double = 0
        var creditTotal : Double = 0
        
        for account in childrenList + [self] {
            for item in account.appliedTransactionItemsList {
                if item.type == AccountingMethod.debit.rawValue{
                    debitTotal += item.amount
                }
                else if item.type == AccountingMethod.credit.rawValue{
                    creditTotal += item.amount
                }
            }
        }
        
        if type == AccountType.assets.rawValue {
            return debitTotal - creditTotal
        }
        else {
            return creditTotal - debitTotal
        }
    }
    
    func balanceOn(date : Date) -> Double{
        var debit : Double = 0
        var credit : Double = 0
        
        for account in childrenList + [self]  {
            
            let transactionItems = (account.appliedTransactionItemsList).filter{$0.transaction!.date! <= date}
            
            for item in transactionItems {
                if item.type == AccountingMethod.debit.rawValue {
                    debit += item.amount
                }
                else if item.type == AccountingMethod.credit.rawValue {
                    credit += item.amount
                }
            }
        }
        
        if type == AccountType.assets.rawValue {
            return debit - credit
        }
        else {
            return credit - debit
        }
    }
    
    private static func createDateIntervalArray(dateInterval : DateInterval , dateComponent : Calendar.Component) -> [DateInterval] {
        let calendar = Calendar.current
        
        var intervalArray : [DateInterval] = []
        var interval = calendar.dateInterval(of: dateComponent ,for: dateInterval.start)
        while let tmpInterval = interval, tmpInterval.end <= dateInterval.end{
            intervalArray.append(tmpInterval)
            interval = calendar.dateInterval(of: dateComponent ,for: tmpInterval.end)
        }
        
        if let tmpInterval = interval, tmpInterval.start < dateInterval.end && tmpInterval.end > dateInterval.end{
            intervalArray.append(DateInterval(start: tmpInterval.start, end: dateInterval.end))
        }
        //        print("date interval [",dateInterval.start,dateInterval.end,"]")
        //        intervalArray.forEach({print($0)})
        return intervalArray
    }
    
    func balance(dateInterval : DateInterval , dateComponent : Calendar.Component, calcIncludedAccountsBalances: Bool = true) -> [(date : Date, value : Double)] {
        
        //creates date interval
        let intervalArray : [DateInterval] = Account.createDateIntervalArray(dateInterval: dateInterval, dateComponent: dateComponent)
        
        //calculate accountSaldoToLeftBorderDate
        var accountSaldoToLeftBorderDate : Double = 0
        var result : [(date : Date, value : Double)] = [(date : dateInterval.start, value : accountSaldoToLeftBorderDate)]
        
        var accounts: [Account] = []
        accounts.append(self)
        
        if calcIncludedAccountsBalances {
            accounts += childrenList
        }
        
        if accounts.isEmpty == false {
            if  accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) ||
                    accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) ||
                    accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors) {
                
                accounts.forEach({
                    accountSaldoToLeftBorderDate += $0.balanceOn(date: dateInterval.start)
                })
            }
            
            for (index,timeInterval) in intervalArray.enumerated() {
                var debitTotal : Double = 0
                var creditTotal : Double = 0
                
                for account in accounts {
                    let transactionItems = (account.transactionItems?.allObjects as! [TransactionItem]).filter{$0.transaction!.applied == true}
                    
                    for item in transactionItems {
                        if timeInterval.contains(item.transaction!.date!) {
                            if item.type == AccountingMethod.debit.rawValue{
                                debitTotal += item.amount
                            }
                            else if item.type == AccountingMethod.credit.rawValue{
                                creditTotal += item.amount
                            }
                        }
                    }
                }
                // FIXME: - remove condition below if its unused
                if true ||
                    accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) ||
                    accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) ||
                    accounts[0].rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors) {
                    if  accounts[0].type == AccountType.assets.rawValue {
                        result.append((date: timeInterval.end, value: round((result[index].value + debitTotal - creditTotal)*100)/100))
                    }
                    else {
                        result.append((date: timeInterval.end, value: round((result[index].value + creditTotal - debitTotal)*100)/100))
                    }
                }
                else {
                    if accounts[0].type == AccountType.assets.rawValue {
                        result.append((date: timeInterval.end, value: round((debitTotal - creditTotal)*100)/100))
                    }
                    else {
                        result.append((date: timeInterval.end, value: round((creditTotal - debitTotal)*100)/100))
                    }
                }
            }
        }
        else {
            result = []
        }
        return result
    }
}


//MARK: - method for charts
extension Account {
    func prepareDataToShow(dateInterval: DateInterval, selectedCurrency: Currency, currencyHistoricalData: CurrencyHistoricalDataProtocol? = nil, dateComponent: Calendar.Component, isListForAnalytic: Bool,sortTableDataBy: SortCategoryType, context: NSManagedObjectContext) throws -> PresentingData {
        var accountsToShow : [Account] = directChildrenList
        if !(rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) ||
             rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) ||
             rootAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors)) {
            accountsToShow.append(self)
        }
        
        if isListForAnalytic == false {
            accountsToShow = accountsToShow.filter({
                if $0.active {
                    return true
                }
                else {
                    return false
                }
            })
        }
        
        var accountsData : [AccountData] = []
        var lineChartDataSet : [LineChartDataSet] = []
        
        var tempData: [(
            lineChartDataSet: LineChartDataSet,
            account: Account,
            title: String,
            amountInAccountCurrency: Double,
            amountInSelectedCurrency: Double,
            checkSum: Double)] = []
        
        var maxValue : Double = 0
        var minValue : Double = 0
        
        for (index, account) in accountsToShow.enumerated() {
            var title = ""
            var arrayOfResultsForTmpAccount : [(date: Date, value: Double)] = []
            if account != self {
                title = account.name!
                arrayOfResultsForTmpAccount = account.balance(dateInterval: dateInterval, dateComponent: dateComponent, calcIncludedAccountsBalances: true)
            }
            else {
                title = AccountsNameLocalisationManager.getLocalizedAccountName(.other)//NSLocalizedString("<Other>", comment: "")
                arrayOfResultsForTmpAccount = account.balance(dateInterval: dateInterval, dateComponent: dateComponent, calcIncludedAccountsBalances: false)
            }
            
            //convert (date: Date, value: Double) to ChartDataEntry(x:Double, y: Double)
            var entries : [ChartDataEntry] = []
            var checkSum : Double = 0
            for item in arrayOfResultsForTmpAccount {
                checkSum += item.value
                if item.value > maxValue {
                    maxValue = item.value
                }
                else if item.value < minValue {
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
            
            
            var amountInAccountCurrency : Double {
                if arrayOfResultsForTmpAccount.isEmpty == false {
                    return arrayOfResultsForTmpAccount.last!.value
                }
                return 0
            }
            
            var amountInSelectedCurrency: Double {
                if selectedCurrency == account.currency {
                    return amountInAccountCurrency
                }
                else if amountInAccountCurrency != 0,
                        let currencyHistoricalData = currencyHistoricalData,
                        let accountCurrency = account.currency {
                    
                    var exchangeRate : Double = 1
                    
                    if let rate =  currencyHistoricalData.exchangeRate(pay: selectedCurrency.code!, forOne: accountCurrency.code!) {
                        exchangeRate = rate
                    }
                    return round(amountInAccountCurrency * exchangeRate * 100) / 100
                }
                return 0
            }
            tempData.append((lineChartDataSet: set, account: account, title: title, amountInAccountCurrency: amountInAccountCurrency, amountInSelectedCurrency: amountInSelectedCurrency, checkSum: checkSum))
        }
        
        
        //filtered and ordered items
        if isListForAnalytic {
            tempData = tempData.filter({$0.checkSum != 0})
        }
        tempData.sort(by: {$0.amountInSelectedCurrency >= $1.amountInSelectedCurrency})
        
        // Coloring
        for (index,item) in tempData.enumerated() {
            let colorSet = Constants.ColorSetForCharts.set1
            var color : NSUIColor!
            if index < colorSet.count {
                color = colorSet[index]
                item.lineChartDataSet.setColor(colorSet[index])
            }
            else {
                color = UIColor(red: CGFloat.random(in: 0...255) / 255, green: CGFloat.random(in: 0...255) / 255, blue: CGFloat.random(in: 0...255) / 255, alpha: 1)
            }
            item.lineChartDataSet.setColor(color)
            lineChartDataSet.append(item.lineChartDataSet)
            accountsData.append(AccountData(account: item.account, title: item.title, color: color, amountInAccountCurrency: item.amountInAccountCurrency, amountInSelectedCurrency: item.amountInSelectedCurrency))
        }
        
        
        return PresentingData(dateInterval:dateInterval, presentingCurrency: selectedCurrency,lineChartData: ChartData(minValue: minValue, maxValue: maxValue, lineChartDataSet: lineChartDataSet), tableData: accountsData, sortTableDataBy: sortTableDataBy)
    }
}
//MARK: - Static methods
extension Account {
    private static var reservedAccountNames: [String] {
        return [
            //EN
            "Income"
            ,"Expenses"
            ,"Capital"
            ,"Money"
            ,"Debtors"
            ,"Creditors"
            ,"Before accounting period"
            ,"<Other>"
            ,"Other"
            //UA
            ,"Доходи"
            ,"Витрати"
            ,"Гроші"
            ,"Борги"
            ,"Боржники"
            ,"Капітал"
            ,"До обліковий період"
            ,"<Інше>"
            ,"Інше"
            //RU
            ,"Доходы"
            ,"Расходы"
            ,"Деньги"
            ,"Долги"
            ,"Должники"
            ,"Капитал"
            ,"До учетный период"
            ,"<Прочее>"
            ,"Прочее"
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
    
    
    static func isFreeAccountName(parent: Account?, name : String, context: NSManagedObjectContext) -> Bool {
        if let parent = parent {
            for child in parent.childrenList {
                if child.name == name{
                    return  false
                }
            }
            return true
        }
        else {
            let fetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "parent = nil and name = %@", name)
            do{
                let accounts = try context.fetch(fetchRequest)
                if accounts.isEmpty {
                    return true
                }
                else {
                    return false
                }
            }
            catch let error {
                print("ERROR", error)
                return false
            }
        }
    }
    
    static func createAndGetAccount(parent: Account?, name : String, type : Int16?, currency : Currency?, keeper: Keeper? = nil, holder: Holder? = nil, subType : Int16? = nil, createdByUser : Bool = true, createDate: Date = Date(), impoted: Bool = false, context: NSManagedObjectContext) throws -> Account {
        
        try validateAttributes(parent: parent, name: name, type: type, currency: currency, keeper: keeper, holder: holder, subType: subType, createdByUser: createdByUser, impoted: impoted, context: context)
        
        //Adding "Other" account for cases when parent containts transactions
        if let parent = parent, parent.isFreeFromTransactionItems == false, Account.isReservedAccountName(name) == false {
            var newAccount = parent.getSubAccountWith(name: AccountsNameLocalisationManager.getLocalizedAccountName(.other1))
            if newAccount == nil {
                newAccount = try createAndGetAccount(parent: parent, name: AccountsNameLocalisationManager.getLocalizedAccountName(.other1) , type : type, currency : currency, keeper: keeper, holder: holder, subType : subType, createdByUser : false, createDate: createDate, context: context)
            }
            if newAccount != nil {
                TransactionItemManager.moveTransactionItemsFrom(oldAccount: parent, newAccount: newAccount!, modifiedByUser: createdByUser, modifyDate: createDate)
            }
        }
        
        return Account(parent: parent, name : name, type : type, currency : currency, keeper: keeper, holder: holder, subType : subType, createdByUser : createdByUser, createDate: createDate, context: context)
    }
    
    static func createAccount(parent: Account?, name : String, type : Int16?, currency : Currency?, keeper: Keeper? = nil, holder: Holder? = nil, subType : Int16? = nil, createdByUser : Bool = true, impoted: Bool = false, context: NSManagedObjectContext) throws {
        try createAndGetAccount(parent: parent, name: name, type: type, currency: currency, keeper: keeper, holder: holder, subType: subType, createdByUser: createdByUser, createDate: Date(), impoted: impoted, context: context)
    }
    
    private static func validateAttributes(parent: Account?, name : String, type : Int16?, currency : Currency?, keeper: Keeper? = nil, holder: Holder? = nil, subType : Int16? = nil, createdByUser : Bool = true, impoted: Bool = false, context: NSManagedObjectContext) throws {
        
        guard !name.isEmpty else {throw AccountError.emptyName}
        if parent == nil && type == nil {throw AccountError.attributeTypeShouldBeInitializeForRootAccount}
        //        guard parent != nil && type != nil && parent?.type != type else {throw AccountError.accountContainAttribureTypeDifferentFromParent}
        
        // accounts with reserved names can create only app
        if !impoted {
            guard createdByUser == false || isReservedAccountName(name) == false else {throw AccountError.reservedName(name: name)}
        }
        guard isFreeAccountName(parent: parent, name : name, context: context) == true else {
            if parent?.currency == nil {
                throw AccountError.accountAlreadyExists(name: name)
            }
            else {
                throw AccountError.categoryAlreadyExists(name: name)
            }
        }
    }
    
    
    static func changeCurrencyForBaseAccounts(to currency : Currency, modifyDate: Date = Date(), modifiedByUser: Bool = true, context : NSManagedObjectContext) throws {
        let baseAccounts : [Account] = try getRootAccountList(context: context)
        var acc : [Account] = []
        for item in baseAccounts{
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
    
    
    static func getRootAccountList(context : NSManagedObjectContext) throws -> [Account] {
        let fetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "parent = nil")
        return try context.fetch(fetchRequest)
    }
    
    
    static func getAccountList(context: NSManagedObjectContext) throws -> [Account] {
        let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try context.fetch(accountFetchRequest)
    }
    
    
    static func getAccountWithPath(_ path: String, context: NSManagedObjectContext) -> Account? {
        let fetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do{
            let accounts = try context.fetch(fetchRequest)
            if !accounts.isEmpty {
                for account in accounts {
                    if account.path == path {
                        return account
                    }
                }
                return nil
            }
            else {
                return nil
            }
        }
        catch let error {
            print("ERROR", error)
            return nil
        }
    }
    
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllAccounts(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let accountsFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        accountsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        
        let accounts = try context.fetch(accountsFetchRequest)
        accounts.forEach({
            context.delete($0)
        })
    }
    
    static func exportAccountsToString(context: NSManagedObjectContext) -> String {
        
        let accountFetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: Account.entity().name!)
        accountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "parent.name", ascending: true),NSSortDescriptor(key: "name", ascending: true)]
        do{
            let storedAccounts = try context.fetch(accountFetchRequest)
            var export : String = "ParentAccount_path,Account_name,active,Account_type,Account_currency,Account_SubType,LinkedAccount_path\n"
            for account in storedAccounts {
                
                var accountType = ""
                switch account.type {
                case AccountType.assets.rawValue:
                    accountType = "Assets"
                case AccountType.liabilities.rawValue:
                    accountType = "Liabilities"
                default:
                    accountType = "Out of enumeration"
                }
                
                var accountSubType = ""
                switch account.subType {
                case AccountSubType.none.rawValue:
                    accountSubType = ""
                case AccountSubType.cash.rawValue:
                    accountSubType = "Cash"
                case AccountSubType.debitCard.rawValue:
                    accountSubType = "DebitCard"
                case AccountSubType.creditCard.rawValue:
                    accountSubType = "CreditCard"
                default:
                    accountSubType = "Out of enumeration"
                }
                
                export +=  "\(account.parent != nil ? account.parent!.path : "" ),"
                export +=  "\(account.name!),"
                export +=  "\(account.active),"
                export +=  "\(accountType),"
                export +=  "\(account.currency?.code ?? "MULTICURRENCY"),"
                export +=  "\(accountSubType),"
                export +=  "\(account.linkedAccount != nil ? account.linkedAccount!.path : "" )\n"
            }
            return export
        }
        catch let error {
            print("ERROR", error)
            return ""
        }
    }
    
    static func importAccounts(_ data : String, context: NSManagedObjectContext) throws {
        
        var accountToBeAdded : [Account] = []
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
                break//throw ImportAccountError.invalidactiveValue
            }
            
            var accountType: Int16 = 0
            switch row[3] {
            case "Assets":
                accountType = AccountType.assets.rawValue
            case "Liabilities":
                accountType = AccountType.liabilities.rawValue
            default:
                break//throw ImportAccountError.invalidAccountTypeValue
            }
            
            let curency = try? Currency.getCurrencyForCode(row[4], context: context)
            
            var accountSubType: Int16 = 0
            switch row[5] {
            case "":
                break
            case "Cash":
                accountSubType = 1
            case "DebitCard":
                accountSubType = 2
            case "CreditCard":
                accountSubType = 3
            case "Deposit":
                accountSubType = 4
            default:
                break//throw ImportAccountError.invalidAccountSubTypeValue
            }
            
            let linkedAccount = Account.getAccountWithPath(row[6], context: context)
            
            let account = try? Account.createAndGetAccount(parent: parent, name: name, type: accountType, currency: curency, impoted: true, context: context)
            account?.linkedAccount = linkedAccount
            account?.subType = accountSubType
            account?.active = active
            
            
            //CHECKING
            if let account = account {
                
                accountToBeAdded.append(account)
                var accountTypes = ""
                switch account.type {
                case AccountType.assets.rawValue:
                    accountTypes = "Assets"
                case AccountType.liabilities.rawValue:
                    accountTypes = "Liabilities"
                default:
                    accountTypes = "Out of enumeration"
                }
                
                var accountSubTypes = ""
                switch account.subType {
                case AccountSubType.none.rawValue:
                    accountSubTypes = ""
                case AccountSubType.cash.rawValue:
                    accountSubTypes = "Cash"
                case AccountSubType.debitCard.rawValue:
                    accountSubTypes = "DebitCard"
                case AccountSubType.creditCard.rawValue:
                    accountSubTypes = "CreditCard"
                default:
                    accountSubTypes = "Out of enumeration"
                }
                var export = ""
                export +=  "\(account.parent != nil ? account.parent!.path : "" ),"
                export +=  "\(account.name!),"
                export +=  "\(account.active),"
                export +=  "\(accountTypes),"
                export +=  "\(account.currency?.code ?? "MULTICURRENCY"),"
                export +=  "\(accountSubTypes),"
                export +=  "\(account.linkedAccount != nil ? account.linkedAccount!.path : "" )\n"
                //            print(export)
            }
            else {
                print("There is no account")
            }
        }
    }
}
