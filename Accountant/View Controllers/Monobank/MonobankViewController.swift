//
//  MonobankGetUserInfoViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import UIKit
import SafariServices

class MonobankViewController: UIViewController {
    
    let context = CoreDataStack.shared.persistentContainer.viewContext
    var userInfo: MBUserInfo?
    var xToken: String = ""
    
    var currencyHistoricalData: CurrencyHistoricalDataProtocol?
    
    var moneyRootAccount: Account!
    var creditsRootAccount: Account!
    var debtorsRootAcccount: Account!
    var expenseRootAccount: Account!
    var capitalRootAccount: Account!
    
    var holder: Holder! {
        didSet {
            holderButton.setTitle(holder.icon! + "-" + holder.name!, for: .normal)
        }
    }
    
    
    let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let consolidatedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("To automatically adding your transactions from the Monobank accounts please enter Token in the field below", comment: "")// + "https://api.monobank.ua"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let getTokenLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("Get token", comment: "")
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    let apiDocLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("API documentation", comment: "")
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    let leadingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let trailingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let tokenLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Token", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tokenTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 1000
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let getDataView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let holderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Holder", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let holderButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
//        button.setTitle("Holder", for: .normal)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let getDataButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle(NSLocalizedString("Get data", comment: ""), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let bankAccountsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle(NSLocalizedString("Add accounts", comment: ""), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Monobank", comment: "")
        
        getCurrencyExchangeRate()
        
        if let holder = try? HolderManager.getMe(context: context) {
            self.holder = holder
        }
        
        tokenTextField.delegate = self
       
        //MARK:- Register cell for TableViews
        bankAccountsTableView.register(MonobankAccountTableViewCell.self, forCellReuseIdentifier: Constants.Cell.bankAccountCell)
        
        //MARK:- TableView delegates
        bankAccountsTableView.delegate = self
        bankAccountsTableView.dataSource = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        getDataButton.addTarget(self, action: #selector(self.getUserInfo), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.createAccounts), for: .touchUpInside)
        holderButton.addTarget(self, action: #selector(self.selectHolder), for: .touchUpInside)
        
        setupUI()
    }
    
    private func setupUI(){
        self.view.addSubview(mainView)
        
        holderButton.isHidden = true
        holderLabel.isHidden = true
        confirmButton.isHidden = true
        
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor,constant: 20).isActive = true
        
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(getTokenLabel)
        mainStackView.addArrangedSubview(apiDocLabel)
        mainStackView.setCustomSpacing(20, after: apiDocLabel)
        
        mainStackView.addArrangedSubview(consolidatedStackView)
        consolidatedStackView.addArrangedSubview(leadingStackView)
        consolidatedStackView.addArrangedSubview(trailingStackView)
        
        leadingStackView.addArrangedSubview(tokenLabel)
        tokenLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        tokenLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        leadingStackView.addArrangedSubview(getDataView)
        getDataView.heightAnchor.constraint(equalToConstant: 34).isActive = true
        getDataView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        leadingStackView.addArrangedSubview(holderLabel)
        holderLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        holderLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        trailingStackView.addArrangedSubview(tokenTextField)
        tokenTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        trailingStackView.addArrangedSubview(getDataButton)
        getDataButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        getDataButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        trailingStackView.addArrangedSubview(holderButton)
        holderButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        holderButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        mainStackView.addArrangedSubview(bankAccountsTableView)
        bankAccountsTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        mainStackView.addArrangedSubview(confirmButton)
        confirmButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.confirmButton.isHidden = true
        
        let tokenTap = UITapGestureRecognizer(target: self, action: #selector(self.getTokenLabelTapped))
        getTokenLabel.isUserInteractionEnabled = true
        getTokenLabel.addGestureRecognizer(tokenTap)
        
        let apiDocTap = UITapGestureRecognizer(target: self, action: #selector(self.aboutApiLabelTapped))
        apiDocLabel.isUserInteractionEnabled = true
        apiDocLabel.addGestureRecognizer(apiDocTap)
    }
    
    
    @objc func getUserInfo() {
        if let xTokenStr = tokenTextField.text, !xTokenStr.isEmpty {
            
            self.holderButton.isHidden = true
            self.holderLabel.isHidden = true
            
            getDataButton.isUserInteractionEnabled = false
            
            NetworkServices.loadMBUserInfo(xToken: xTokenStr, compliting: { (mbUserInfo, xToken, error) in
                if let mbUserInfo = mbUserInfo, let xToken = xToken {
                    do {
                        self.userInfo = mbUserInfo
                        self.xToken = xToken
                
                        self.bankAccountsTableView.reloadData()

                        if let ubp = mbUserInfo.getUBP(conetxt: self.context){
                            ubp.xToken = xToken
                            try CoreDataStack.shared.saveContext(self.context)
                            self.tokenDidUpdate()
                        }
                        else {
                            self.holderButton.isHidden = false
                            self.holderLabel.isHidden = false
                        }
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
                if let error = error {
                    self.errorHandler(error: error)
                }
                self.getDataButton.isUserInteractionEnabled = true
            })
        }
        else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please enter Token", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func tokenDidUpdate() {
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Token has been successfully updated", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getCurrencyExchangeRate() {
        NetworkServices.loadCurrency(date: Date(), compliting: {currencyHistoricalData,error  in
            if let currencyHistoricalData = currencyHistoricalData {
                self.currencyHistoricalData = currencyHistoricalData
            }
            else if let error = error {
                self.errorHandler(error: error)
            }
        })
    }
    
    @objc func createAccounts(){
        guard let userInfo = userInfo else {return}
        
        do {
            try getRootAccounts()
            
            let ubp = UserBankProfileManager.getOrCreateMonoBankUBP(userInfo, xToken: xToken, context: self.context)
            
            print("userInfo.accounts.count", userInfo.accounts.count)
            for item in userInfo.accounts {
                
                guard !item.isExists(context: context) else {return}
                
                guard AccountManager.isFreeAccountName(parent: moneyRootAccount, name: item.maskedPan.last! , context: context) else {throw AccountError.accountAlreadyExists(name: moneyRootAccount.name! + ":" + item.maskedPan.last!)}
                
                let bankAccount = try BankAccountManager.createAndGetMBBankAccount(item, userBankProfile: ubp, context: context)
                
                print("item.maskedPan.last!", item.maskedPan.last!)
                
                var exchangeRate : Double = 1
                
                //Check balance value
                let balance : Double = Double(item.balance) / 100
                let creditLimit : Double = Double(item.creditLimit) / 100
                
                guard let currency = item.getCurrency(context: context) else {return}
                guard let accountingCurrency = CurrencyManager.getAccountingCurrency(context: context) else {throw CurrencyError.accountingCurrencyNotFound}
                guard  let keeper = try KeeperManager.getKeeperForName("Monobank", context: context) else {throw KeeperError.keeperNotFound(name: "Monobank")}
                
                //Check credit account name is free
                guard AccountManager.isFreeAccountName(parent: creditsRootAccount, name: item.maskedPan.last! , context: context)
                else {throw AccountError.creditAccountAlreadyExist(creditsRootAccount.name! + item.maskedPan.last!)}
                
                
                //Check exchange rate value
                if currency != accountingCurrency {
                    guard let currencyHistoricalData = currencyHistoricalData,
                          let rate = currencyHistoricalData.exchangeRate(pay: accountingCurrency.code!, forOne: currency.code!)
                    else {return}
                    exchangeRate = rate
                }
                
                let newMoneyAccount = try AccountManager.createAndGetAccount(parent: moneyRootAccount, name: item.maskedPan.last!, type: moneyRootAccount.type, currency: currency, keeper: keeper, holder:holder, subType: AccountSubType.creditCard.rawValue, context: context)
                
                newMoneyAccount.bankAccount = bankAccount
                
                let newCreditAccount = try AccountManager.createAndGetAccount(parent: creditsRootAccount, name: item.maskedPan.last!, type: creditsRootAccount.type, currency: currency, keeper: keeper, holder:holder, context: context)
                
                newMoneyAccount.linkedAccount = newCreditAccount
                
                if balance - creditLimit == 0 && !(balance == 0 && creditLimit == 0) {
                    TransactionManager.addTransaction(date: Date(), debit: newMoneyAccount, credit: newCreditAccount, debitAmount: round(creditLimit*100)/100, creditAmount: round(creditLimit*100)/100, createdByUser : false, context: context)
                }
                else if balance == 0 && creditLimit == 0 {
                    
                }
                else if balance - creditLimit > 0 {
                    TransactionManager.addTransaction(date: Date(), debit: newMoneyAccount, credit: capitalRootAccount, debitAmount: round((balance - creditLimit)*100)/100, creditAmount: round(round((balance - creditLimit)*100)/100 * exchangeRate*100)/100, createdByUser : false, context: context)
                    if creditLimit != 0 {
                        TransactionManager.addTransaction(date: Date(), debit: newMoneyAccount, credit: newCreditAccount, debitAmount: round(creditLimit*100)/100, creditAmount: round(creditLimit*100)/100, createdByUser : false, context: context)
                    }
                }
                else {
                    var expenseBeforeAccountingPeriod : Account? = AccountManager.getSubAccountWith(name: AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod), in: expenseRootAccount)
                    
                    if expenseBeforeAccountingPeriod == nil {
                        expenseBeforeAccountingPeriod = try? AccountManager.createAndGetAccount(parent: expenseRootAccount, name: AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod), type: expenseRootAccount.type, currency: expenseRootAccount.currency, createdByUser: false, context: context)
                    }
                    guard let expenseBeforeAccountingPeriodSafe = expenseBeforeAccountingPeriod else {
                        throw AccountWithBalanceError.canNotFindBeboreAccountingPeriodAccount
                    }
                    
                    TransactionManager.addTransaction(date: Date(),debit: expenseBeforeAccountingPeriodSafe, credit: newMoneyAccount, debitAmount: round(round((creditLimit - balance)*100)/100 * exchangeRate*100)/100, creditAmount: round((creditLimit - balance)*100)/100, createdByUser : false, context: context)
                    TransactionManager.addTransaction(date: Date(), debit: newMoneyAccount, credit: newCreditAccount, debitAmount: round(creditLimit*100)/100, creditAmount: round(creditLimit*100)/100, createdByUser : false, context: context)
                }
            }
            try CoreDataStack.shared.saveContext(self.context)
            self.navigationController?.popViewController(animated: true)
        }
        catch let error {
            errorHandler(error: error)
        }
    }
    
    private func getRootAccounts() throws {
        let rootAccountList = try AccountManager.getRootAccountList(context: context)
        rootAccountList.forEach({
            
            switch $0.name! {
            case AccountsNameLocalisationManager.getLocalizedAccountName(.money):
                moneyRootAccount = $0
            case AccountsNameLocalisationManager.getLocalizedAccountName(.credits):
                creditsRootAccount = $0
            case AccountsNameLocalisationManager.getLocalizedAccountName(.debtors):
                debtorsRootAcccount = $0
            case AccountsNameLocalisationManager.getLocalizedAccountName(.expense):
                expenseRootAccount = $0
            case AccountsNameLocalisationManager.getLocalizedAccountName(.capital):
                capitalRootAccount = $0
            default:
                break
            }
        })
        if moneyRootAccount == nil {
            throw AccountError.accountDoesNotExist(AccountsNameLocalisationManager.getLocalizedAccountName(.money))
        }
        if creditsRootAccount == nil {
            throw AccountError.accountDoesNotExist(AccountsNameLocalisationManager.getLocalizedAccountName(.credits))
        }
        if debtorsRootAcccount == nil {
            throw AccountError.accountDoesNotExist(AccountsNameLocalisationManager.getLocalizedAccountName(.debtors))
        }
        if expenseRootAccount == nil {
            throw AccountError.accountDoesNotExist(AccountsNameLocalisationManager.getLocalizedAccountName(.expense))
        }
        if capitalRootAccount == nil {
            throw AccountError.accountDoesNotExist(AccountsNameLocalisationManager.getLocalizedAccountName(.capital))
        }
    }
    
    func errorHandler(error : Error) {
        if error is AppError {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { [self](_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Showing up The Terms Web Controller
    @objc func aboutApiLabelTapped(_ sender: UITapGestureRecognizer? = nil) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: Constants.URL.monoAPIDoc)
        let webVC = WebViewController(url: url!, configuration: config)
        self.present(webVC, animated: true, completion: nil)
    }
    
    //MARK: - Showing up The Policy Web Controller
    @objc func getTokenLabelTapped(_ sender: UITapGestureRecognizer? = nil) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: Constants.URL.monoToken)
        let webVC = WebViewController(url: url!, configuration: config)
        self.present(webVC, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField : UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


extension MonobankViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let userInfo = userInfo else {return 0}
        return userInfo.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = MonobankAccountTableViewCell()
        if let userInfo = userInfo  {
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.bankAccountCell, for: indexPath) as! MonobankAccountTableViewCell
            let account = userInfo.accounts[indexPath.row]
            let isAdded = userInfo.isExists(context: CoreDataStack.shared.persistentContainer.viewContext)
            if !isAdded {
                confirmButton.isHidden = false
            }
            cell.configureCell(account, isAdded: isAdded)
        }
        return cell
    }
}

extension MonobankViewController: HolderReceiverDelegate {
    @objc func selectHolder() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let holderTableViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.holderTableViewController) as! HolderTableViewController
        holderTableViewController.delegate = self
        holderTableViewController.holder = holder
        self.navigationController?.pushViewController(holderTableViewController, animated: true)
    }
    
    func setHolder(_ selectedHolder: Holder) {
        self.holder = selectedHolder
    }
}
