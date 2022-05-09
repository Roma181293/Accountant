//
//  MonobankGetUserInfoViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import UIKit
import SafariServices

class MonobankViewController: UIViewController { // swiftlint:disable:this type_body_length

    let context = CoreDataStack.shared.persistentContainer.viewContext
    var userInfo: MBUserInfo?
    var xToken: String = ""
    var currencyHistoricalData: CurrencyHistoricalDataProtocol?
    var moneyRootAccount: Account!
    var creditsRootAccount: Account!
    var debtorsRootAcccount: Account!
    var expenseRootAccount: Account!
    var capitalRootAccount: Account!

    var holder: Holder? {
        didSet {
            if let holder = holder {
                holderButton.setTitle(holder.icon + "-" + holder.name, for: .normal)
            } else {
                holderButton.setTitle("", for: .normal)
            }
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

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("To automatically adding your transactions from the Monobank accounts please enter Token in the field below",
                                       tableName: Constants.Localizable.monobankVC,
                                       comment: "")// + "https://api.monobank.ua"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let getTokenLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("Get token", tableName: Constants.Localizable.monobankVC, comment: "")
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
        titleLabel.text = NSLocalizedString("API documentation",
                                            tableName: Constants.Localizable.monobankVC,
                                            comment: "")
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
        label.text = NSLocalizedString("Token", tableName: Constants.Localizable.monobankVC, comment: "")
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
        label.text = NSLocalizedString("Holder", tableName: Constants.Localizable.monobankVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let holderButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
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
        button.setTitle(NSLocalizedString("Get data",
                                          tableName: Constants.Localizable.monobankVC,
                                          comment: ""),
                        for: .normal)
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
        button.setTitle(NSLocalizedString("Add accounts",
                                          tableName: Constants.Localizable.monobankVC,
                                          comment: ""), for:
                                .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("Monobank",
                                                      tableName: Constants.Localizable.monobankVC,
                                                      comment: "")
        getCurrencyExchangeRate()

        holder = try? Holder.getMe(context: context)

        tokenTextField.delegate = self

        // Register cell for TableViews
        bankAccountsTableView.register(MonobankAccountTableViewCell.self,
                                       forCellReuseIdentifier: Constants.Cell.bankAccountCell)

        // TableView delegates
        bankAccountsTableView.delegate = self
        bankAccountsTableView.dataSource = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        getDataButton.addTarget(self, action: #selector(self.getUserInfo), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.createAccounts), for: .touchUpInside)
        holderButton.addTarget(self, action: #selector(self.selectHolder), for: .touchUpInside)

        setupUI()
    }

    private func setupUI() { // swiftlint:disable:this function_body_length
        self.view.addSubview(mainView)

        holderButton.isHidden = true
        holderLabel.isHidden = true
        confirmButton.isHidden = true

        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                           constant: -10).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true

        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true

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

                        if let ubp = mbUserInfo.getUBP(conetxt: self.context) {
                            ubp.xToken = xToken
                            try CoreDataStack.shared.saveContext(self.context)
                            self.tokenDidUpdate()
                        } else {
                            self.holderButton.isHidden = false
                            self.holderLabel.isHidden = false
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
                if let error = error {
                    self.errorHandler(error: error)
                }
                self.getDataButton.isUserInteractionEnabled = true
            })
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Error",
                                                                   tableName: Constants.Localizable.monobankVC,
                                                                   comment: ""),
                                          message: NSLocalizedString("Please enter Token",
                                                                     tableName: Constants.Localizable.monobankVC,
                                                                     comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                                   tableName: Constants.Localizable.monobankVC,
                                                                   comment: ""),
                                          style: .default,
                                          handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func tokenDidUpdate() {
        let alert = UIAlertController(title: NSLocalizedString("Warning",
                                                               tableName: Constants.Localizable.monobankVC,
                                                               comment: ""),
                                      message: NSLocalizedString("Token has been successfully updated", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                               tableName: Constants.Localizable.monobankVC,
                                                               comment: ""),
                                      style: .default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func getCurrencyExchangeRate() {
        NetworkServices.loadCurrency(date: Date(), compliting: {currencyHistoricalData, error  in
            if let currencyHistoricalData = currencyHistoricalData {
                self.currencyHistoricalData = currencyHistoricalData
            } else if let error = error {
                self.errorHandler(error: error)
            }
        })
    }

    @objc func createAccounts() { // swiftlint:disable:this function_body_length
        guard let userInfo = userInfo else {return}
        do {
            try getRootAccounts()

            let ubp = try UserBankProfile.getOrCreateMonoBankUBP(userInfo, xToken: xToken, context: self.context)

            for item in userInfo.accounts.filter({return !$0.isExists(context: context)}) {
                guard Account.isFreeAccountName(parent: moneyRootAccount,
                                                name: item.maskedPan.last! ,
                                                context: context)
                else {throw AccountError.accountAlreadyExists(name: moneyRootAccount.name + ":" + item.maskedPan.last!)}

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
                                                                      keeper: keeper,
                                                                      holder: holder,
                                                                      subType: Account.SubTypeEnum.creditCard,
                                                                      context: context)

                newMoneyAccount.bankAccount = bankAccount

                let newCreditAccount = try Account.createAndGetAccount(parent: creditsRootAccount,
                                                                       name: item.maskedPan.last!,
                                                                       type: creditsRootAccount.type,
                                                                       currency: currency,
                                                                       keeper: keeper,
                                                                       holder: holder,
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
                    Transaction.addTransactionWith2TranItems(date: Date(),
                                                             debit: newMoneyAccount,
                                                             credit: capitalRootAccount,
                                                             debitAmount: round((balance - creditLimit)*100)/100,
                                                             creditAmount: round(round((balance - creditLimit)*100)/100 * exchangeRate*100)/100,
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
                    var expenseBeforeAccountingPeriod: Account? = expenseRootAccount.getSubAccountWith(name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod))

                    if expenseBeforeAccountingPeriod == nil {
                        expenseBeforeAccountingPeriod = try? Account.createAndGetAccount(parent: expenseRootAccount,
                                                                                         name: LocalisationManager.getLocalizedName(.beforeAccountingPeriod),
                                                                                         type: expenseRootAccount.type,
                                                                                         currency: expenseRootAccount.currency,
                                                                                         createdByUser: false,
                                                                                         context: context)
                    }
                    guard let expenseBeforeAccountingPeriodSafe = expenseBeforeAccountingPeriod else {
                        throw AccountWithBalanceError.canNotFindBeboreAccountingPeriodAccount
                    }

                    Transaction.addTransactionWith2TranItems(date: Date(),
                                                             debit: expenseBeforeAccountingPeriodSafe,
                                                             credit: newMoneyAccount,
                                                             debitAmount: round(round((creditLimit - balance)*100)/100 * exchangeRate*100)/100,
                                                             creditAmount: round((creditLimit - balance)*100)/100,
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
            self.navigationController?.popViewController(animated: true)
        } catch let error {
            errorHandler(error: error)
        }
    }

    private func getRootAccounts() throws {
        let rootAccountList = try Account.getRootAccountList(context: context)
        rootAccountList.forEach({

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

    func errorHandler(error: Error) {
        if error is AppError {
            let alert = UIAlertController(title: NSLocalizedString("Warning",
                                                                   tableName: Constants.Localizable.monobankVC,
                                                                   comment: ""),
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                                   tableName: Constants.Localizable.monobankVC,
                                                                   comment: ""),
                                          style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Error",
                                                                   tableName: Constants.Localizable.monobankVC,
                                                                   comment: ""),
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                                   tableName: Constants.Localizable.monobankVC,
                                                                   comment: ""),
                                          style: .default, handler: { [self](_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc func aboutApiLabelTapped(_ sender: UITapGestureRecognizer? = nil) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: Constants.URL.monoAPIDoc)
        let webVC = WebViewController(url: url!, configuration: config)
        self.present(webVC, animated: true, completion: nil)
    }

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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.bankAccountCell, for: indexPath) as! MonobankAccountTableViewCell // swiftlint:disable:this force_cast line_length
        if let userInfo = userInfo {
            let account = userInfo.accounts[indexPath.row]
            let isAdded = account.isExists(context: CoreDataStack.shared.persistentContainer.viewContext)
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
        let holderVC = HolderViewController()
        holderVC.delegate = self
        holderVC.holder = holder
        self.navigationController?.pushViewController(holderVC, animated: true)
    }

    func setHolder(_ selectedHolder: Holder?) {
        self.holder = selectedHolder
    }
}
