//
//  AccountEditorWithInitialBalanceViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 10.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import Purchases

class AccountEditorWithInitialBalanceViewController: UIViewController { // swiftlint:disable:this type_body_length

    var isUserHasPaidAccess: Bool = false

    let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext

    var parentAccount: Account!

    var account: Account?

    var moneyRootAccount: Account!
    var creditsRootAccount: Account!
    var debtorsRootAcccount: Account!
    var expenseRootAccount: Account!
    var capitalRootAccount: Account!
    
    var isFreeNewAccountName: Bool = false
    var accountSubType: Account.SubTypeEnum? {
        didSet {
            configureUIForAccontSubType()
        }
    }

    var accountingCurrency: Currency!

    var currency: Currency! {
        didSet {
            configureUIForCurrency()
        }
    }

    var keeper: Keeper? {
        didSet {
            if let keeper = keeper {
                keeperButton.setTitle(keeper.name, for: .normal)
            } else {
                keeperButton.setTitle("", for: .normal)
            }
        }
    }

    var holder: Holder? {
        didSet {
            if let holder = holder {
                holderButton.setTitle(holder.icon + "-" + holder.name, for: .normal)
            } else {
                holderButton.setTitle("", for: .normal)
            }
        }
    }

    let mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

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
        stackView.spacing = 20
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

    let accountSubTypeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Type", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let accountSubTypeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Currency", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let currencyButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let dateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let balanceOnDateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Balance on", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Name", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let keeperLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Keeper", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let keeperButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let accountNameTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 100
        textField.placeholder = NSLocalizedString("Example: John BankName salary", comment: "")
        textField.autocapitalizationType = .words
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

    let accountBalanceTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 0
        textField.keyboardType = .decimalPad
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

    let creditLimitLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Credit limit", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let creditLimitTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 0
        textField.keyboardType = .decimalPad
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

    let exchangeRateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let exchangeRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let exchangeRateTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 0
        textField.keyboardType = .decimalPad
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

    var confirmButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.Main.confirmButton
        button.layer.cornerRadius = 34
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3
        button.layer.masksToBounds =  false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)

        mainScrollView.delegate = self
        addMainView()
        reloadProAccessData()

        addDoneButtonOnDecimalKeyboard()

        accountNameTextField.delegate = self as UITextFieldDelegate
        accountBalanceTextField.delegate = self as UITextFieldDelegate
        creditLimitTextField.delegate = self as UITextFieldDelegate
        exchangeRateTextField.delegate = self as UITextFieldDelegate

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        do {
            if let account = account {
                try getRootAccounts()
                self.navigationItem.title = NSLocalizedString("Edit account", comment: "")
                accountingCurrency = Currency.getAccountingCurrency(context: context)!
                currency = account.currency
                configureUI()
                configureUIForExistAccount(account)
            } else {
                self.navigationItem.title = NSLocalizedString("Add account", comment: "")
                try setDefaultSettings()
                configureUI()
            }
        } catch let error {
            errorHandler(error: error)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
        context.rollback()
    }

    private func addMainView() {
        // Main Scroll View
        view.addSubview(mainScrollView)
        mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        // Main View
        mainScrollView.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 10).isActive = true
        mainView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -10).isActive = true
        mainView.topAnchor.constraint(equalTo: mainScrollView.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor).isActive = true
        mainView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -20).isActive = true
        mainView.heightAnchor.constraint(equalTo: mainScrollView.heightAnchor).isActive = true
        // Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true
        mainStackView.addArrangedSubview(consolidatedStackView)
        // Leading Stack View
        consolidatedStackView.addArrangedSubview(leadingStackView)
        leadingStackView.addArrangedSubview(currencyLabel)
        leadingStackView.addArrangedSubview(accountSubTypeLabel)
        leadingStackView.addArrangedSubview(holderLabel)
        leadingStackView.addArrangedSubview(keeperLabel)
        leadingStackView.addArrangedSubview(nameLabel)
        currencyLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        accountSubTypeLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        holderLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        keeperLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        // Trailing Stack View
        consolidatedStackView.addArrangedSubview(trailingStackView)
        trailingStackView.addArrangedSubview(currencyButton)
        trailingStackView.addArrangedSubview(accountSubTypeButton)
        trailingStackView.addArrangedSubview(holderButton)
        trailingStackView.addArrangedSubview(keeperButton)
        trailingStackView.addArrangedSubview(accountNameTextField)
        currencyButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        accountSubTypeButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        holderButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        keeperButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        accountNameTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        // Date Stack View
        mainStackView.addArrangedSubview(dateStackView)
        dateStackView.addArrangedSubview(balanceOnDateLabel)
        dateStackView.addArrangedSubview(datePicker)
        mainStackView.setCustomSpacing(8, after: dateStackView)
        // Account Balance Text Field
        mainStackView.addArrangedSubview(accountBalanceTextField)
        accountBalanceTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        mainStackView.setCustomSpacing(20, after: accountBalanceTextField)
        // Credit Limit Label
        mainStackView.addArrangedSubview(creditLimitLabel)
        mainStackView.setCustomSpacing(8, after: creditLimitLabel)
        // Credit Limit Text Field
        mainStackView.addArrangedSubview(creditLimitTextField)
        creditLimitTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        mainStackView.setCustomSpacing(20, after: creditLimitTextField)
        // Exchange Rate Label
        mainStackView.addArrangedSubview(exchangeRateLabel)
        mainStackView.setCustomSpacing(8, after: exchangeRateLabel)
        // Exchange Rate Text Field
        mainStackView.addArrangedSubview(exchangeRateTextField)
        exchangeRateTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        mainStackView.setCustomSpacing(20, after: exchangeRateTextField)
        // Confirm Button
        view.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -89).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -40).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true

        confirmButton.addTarget(self, action: #selector(self.confirmCreation(_:)), for: .touchUpInside)
        currencyButton.addTarget(self, action: #selector(self.selectCurrency), for: .touchUpInside)
        keeperButton.addTarget(self, action: #selector(self.selectkeeper), for: .touchUpInside)
        holderButton.addTarget(self, action: #selector(self.selectHolder), for: .touchUpInside)
        accountSubTypeButton.addTarget(self, action: #selector(self.changeAccountSubType), for: .touchUpInside)
        accountNameTextField.addTarget(self, action: #selector(self.checkName(_:)), for: .editingChanged)
    }

    @objc func selectHolder() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let holderTableViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.holderTableVC) as? HolderViewController else {return} // swiftlint:disable:this line_length
        holderTableViewController.delegate = self
        holderTableViewController.holder = holder
        self.navigationController?.pushViewController(holderTableViewController, animated: true)
    }

    @objc private func selectkeeper() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let keeperTableViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.keeperTableVC) as? KeeperViewController else {return} // swiftlint:disable:this line_length
        keeperTableViewController.delegate = self
        keeperTableViewController.keeper = keeper
        if parentAccount == moneyRootAccount {
            keeperTableViewController.mode = .bank
        } else if parentAccount == debtorsRootAcccount {
            keeperTableViewController.mode = .nonCash
        } else if parentAccount == creditsRootAccount {
            keeperTableViewController.mode = .nonCash
        }
        self.navigationController?.pushViewController(keeperTableViewController, animated: true)
    }

    @objc private func selectCurrency() {
        guard AccessCheckManager.checkUserAccessToCreateAccountInNotAccountingCurrency(environment: coreDataStack.activeEnviroment()!, isUserHasPaidAccess: isUserHasPaidAccess) // swiftlint:disable:this line_length
        else {
            self.showPurchaseOfferVC()
            return
        }

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let currencyTableViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.currencyTableVC) as? CurrencyTableViewController else {return} // swiftlint:disable:this line_length
        currencyTableViewController.delegate = self
        currencyTableViewController.currency = currency
        self.navigationController?.pushViewController(currencyTableViewController, animated: true)
    }

    @objc private func changeAccountSubType() {
        switch accountSubType {
        case .debitCard:
            accountSubType = .creditCard
        case .creditCard:
            accountSubType = .cash
            if let keeper = try? Keeper.getCashKeeper(context: context) {
                self.keeper = keeper
            }
        case .cash:
            accountSubType = .debitCard
            if let keeper = try? Keeper.getFirstNonCashKeeper(context: context) {
                self.keeper = keeper
            }
        default:
            break
        }
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

    private func showPurchaseOfferVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let purchaseOfferVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferVC) as? PurchaseOfferViewController else {return} // swiftlint:disable:this line_length
        self.present(purchaseOfferVC, animated: true, completion: nil)
    }

    @objc private func confirmCreation(_ sender: UIButton) {
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
                if accountNameTextField.text! == "" {
                    throw AccountWithBalanceError.emptyAccountName
                } else {
                    guard isFreeNewAccountName
                    else {throw AccountError.accountAlreadyExists(name: accountNameTextField.text!)}
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

    private func getRootAccounts() throws { // swiftlint:disable:this cyclomatic_complexity
        let rootAccountList = try Account.getRootAccountList(context: context)
        rootAccountList.forEach({
            switch $0.name {
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
            throw AccountError.accountDoesNotExist(name: AccountsNameLocalisationManager.getLocalizedAccountName(.money))
        }
        if creditsRootAccount == nil {
            throw AccountError.accountDoesNotExist(name: AccountsNameLocalisationManager.getLocalizedAccountName(.credits))
        }
        if debtorsRootAcccount == nil {
            throw AccountError.accountDoesNotExist(name: AccountsNameLocalisationManager.getLocalizedAccountName(.debtors))
        }
        if expenseRootAccount == nil {
            throw AccountError.accountDoesNotExist(name: AccountsNameLocalisationManager.getLocalizedAccountName(.expense))
        }
        if capitalRootAccount == nil {
            throw AccountError.accountDoesNotExist(name: AccountsNameLocalisationManager.getLocalizedAccountName(.capital))
        }
    }

    func setDefaultSettings() throws {
        try getRootAccounts()

        accountingCurrency = Currency.getAccountingCurrency(context: context)!
        currency = Currency.getAccountingCurrency(context: context)!

        if let keeper = try? Keeper.getFirstNonCashKeeper(context: context) {
            self.keeper = keeper
        }
        if let holder = try? Holder.getMe(context: context) {
            self.holder = holder
        }
    }

    private func configureUI() {
        if parentAccount == moneyRootAccount {
            keeperLabel.text = NSLocalizedString("Bank", comment: "")
            accountSubType = .debitCard
            accountSubTypeButton.isHidden = false
            accountSubTypeLabel.isHidden = false
        } else if parentAccount == debtorsRootAcccount {
            keeperLabel.text = NSLocalizedString("Borrower/Bank", comment: "")
            accountSubTypeButton.isHidden = true
            accountSubTypeLabel.isHidden = true
        } else if parentAccount == creditsRootAccount {
            keeperLabel.text = NSLocalizedString("Creditor", comment: "")
            accountSubTypeButton.isHidden = true
            accountSubTypeLabel.isHidden = true
        } else {
            accountSubTypeButton.isHidden = true
            accountSubTypeLabel.isHidden = true
        }

        creditLimitLabel.isHidden = true
        creditLimitTextField.isHidden = true

        if accountSubType == .creditCard {
            creditLimitLabel.isHidden = false
            creditLimitTextField.isHidden = false
        }
    }

    private func configureUIForExistAccount(_ acc: Account) {
        accountNameTextField.text = acc.name
        currency = acc.currency!
        holder = acc.holder
        keeper = acc.keeper
        accountSubType = acc.subType
        if accountSubType == .cash, let keeper = try? Keeper.getCashKeeper(context: context) {
            self.keeper = keeper
        }

        if parentAccount == moneyRootAccount {
            keeperLabel.text = NSLocalizedString("Bank", comment: "")
        } else if parentAccount == debtorsRootAcccount {
            keeperLabel.text = NSLocalizedString("Borrower/Bank", comment: "")
        } else if parentAccount == creditsRootAccount {
            keeperLabel.text = NSLocalizedString("Creditor", comment: "")
        }

        accountSubTypeButton.isEnabled = false
        accountSubTypeButton.isHidden = true
        accountSubTypeLabel.isHidden = true
        currencyButton.isEnabled = false
        accountBalanceTextField.isHidden = true
        datePicker.isHidden = true
        balanceOnDateLabel.isHidden = true
        creditLimitLabel.isHidden = true
        creditLimitTextField.isHidden = true
        accountNameTextField.isUserInteractionEnabled = false
        accountNameTextField.textColor = .systemGray
        nameLabel.textColor = .systemGray
        currencyLabel.isHidden = true
        currencyButton.isHidden = true
        exchangeRateLabel.isHidden = true
        exchangeRateTextField.isHidden = true
    }

    private func configureUIForCurrency() {
        currencyButton.setTitle(currency.code, for: .normal)
        if currency == accountingCurrency {
            exchangeRateLabel.isHidden = true
            exchangeRateTextField.isHidden = true
            exchangeRateLabel.text = ""
            exchangeRateTextField.text = ""
        } else {
            exchangeRateLabel.isHidden = false
            exchangeRateTextField.isHidden = false
            exchangeRateLabel.text = NSLocalizedString("Exchange rate", comment: "") + " \(accountingCurrency.code)/\(currency.code)" // swiftlint:disable:this line_length
        }
    }

    private func configureUIForAccontSubType() {
        guard let accountSubType = accountSubType else {return}
        switch accountSubType {
        case .debitCard:
            accountSubTypeButton.setImage(UIImage(systemName: "creditcard"), for: .normal)
            accountSubTypeButton.setTitle("Debit", for: .normal)
            keeperLabel.isHidden = false
            keeperButton.isHidden = false
            creditLimitLabel.isHidden = true
            creditLimitTextField.isHidden = true
        case .cash:
            accountSubTypeButton.setImage(UIImage(systemName: "keepernote"), for: .normal)
            accountSubTypeButton.setTitle("Cash", for: .normal)
            keeperLabel.isHidden = true
            keeperButton.isHidden = true
            creditLimitLabel.isHidden = true
            creditLimitTextField.isHidden = true
        case .creditCard:
            accountSubTypeButton.setImage(UIImage(systemName: "creditcard.fill"), for: .normal)
            accountSubTypeButton.setTitle("Credit", for: .normal)
            keeperLabel.isHidden = false
            keeperButton.isHidden = false
            creditLimitLabel.isHidden = false
            creditLimitTextField.isHidden = false
        default:
            break
        }
    }

    @objc private func checkName(_ sender: UITextField) {
        if sender.text! == "" {
            isFreeNewAccountName = false
        } else {
            if parentAccount == moneyRootAccount && accountSubType == .creditCard {
                if Account.isFreeAccountName(parent: parentAccount,
                                             name: accountNameTextField.text!,
                                             context: context) &&
                    Account.isFreeAccountName(parent: creditsRootAccount,
                                              name: accountNameTextField.text!,
                                              context: context) {
                    accountNameTextField.backgroundColor = .systemBackground
                    isFreeNewAccountName = true
                } else {
                    accountNameTextField.backgroundColor = UIColor(displayP3Red: 255/255,
                                                                   green: 179/255,
                                                                   blue: 195/255,
                                                                   alpha: 1)
                    isFreeNewAccountName = false
                }
            } else {
                if Account.isFreeAccountName(parent: parentAccount,
                                             name: accountNameTextField.text!,
                                             context: context) {
                    accountNameTextField.backgroundColor = .systemBackground
                    isFreeNewAccountName = true
                } else {
                    accountNameTextField.backgroundColor = UIColor(displayP3Red: 255/255,
                                                                   green: 179/255,
                                                                   blue: 195/255,
                                                                   alpha: 1)
                    isFreeNewAccountName = false
                }
            }
        }
    }

    private func createAccountsAndTransactions() throws { // swiftlint:disable:this cyclomatic_complexity function_body_length line_length
        var exchangeRate: Double = 1
        // Check balance value
        guard let balance: Double = Double(accountBalanceTextField.text!.replacingOccurrences(of: ",", with: "."))
        else {throw AccountWithBalanceError.emptyBalance}

        if parentAccount == moneyRootAccount, let accountSubType = accountSubType {
            if accountSubType == .cash || accountSubType == .debitCard {
                // Check exchange rate value
                if currency != accountingCurrency {
                    if let rate: Double = Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                        exchangeRate = rate
                    } else {throw AccountWithBalanceError.emptyExchangeRate}
                }
                let moneyAccount = try Account.createAndGetAccount(parent: parentAccount,
                                                                   name: accountNameTextField.text!,
                                                                   type: parentAccount.type,
                                                                   currency: currency,
                                                                   keeper: keeper,
                                                                   holder: holder, subType: accountSubType,
                                                                   context: context)
                if balance != 0 {
                    Transaction.addTransactionWith2TranItems(date: datePicker.date,
                                                             debit: moneyAccount,
                                                             credit: capitalRootAccount,
                                                             debitAmount: round(balance*100)/100,
                                                             creditAmount: round(round(balance*100)/100 * exchangeRate*100)/100, // swiftlint:disable:this line_length
                                                             createdByUser: false,
                                                             context: context)
                }
            } else if accountSubType == .creditCard {
                // Check credit account name is free
                guard Account.isFreeAccountName(parent: creditsRootAccount,
                                                name: accountNameTextField.text!,
                                                context: context)
                else {throw AccountError.creditAccountAlreadyExist(creditsRootAccount.name + ":" + (accountNameTextField.text ?? ""))} // swiftlint:disable:this line_length

                // Check credit limit value
                guard let creditLimit: Double = Double(creditLimitTextField.text!.replacingOccurrences(of: ",", with: ".")) // swiftlint:disable:this line_length
                else {throw AccountWithBalanceError.emptyCreditLimit}

                // Check exchange rate value
                if currency != accountingCurrency {
                    if let rate: Double = Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                        exchangeRate = rate
                    } else {
                        throw AccountWithBalanceError.emptyExchangeRate
                    }
                }

                let newMoneyAccount = try Account.createAndGetAccount(parent: parentAccount,
                                                                      name: accountNameTextField.text!,
                                                                      type: parentAccount.type,
                                                                      currency: currency,
                                                                      keeper: keeper,
                                                                      holder: holder,
                                                                      subType: accountSubType,
                                                                      context: context)
                let newCreditAccount = try Account.createAndGetAccount(parent: creditsRootAccount,
                                                                       name: accountNameTextField.text!,
                                                                       type: creditsRootAccount.type,
                                                                       currency: currency,
                                                                       keeper: keeper,
                                                                       holder: holder,
                                                                       context: context)

                newMoneyAccount.linkedAccount = newCreditAccount

                if balance - creditLimit > 0 {
                    Transaction.addTransactionWith2TranItems(date: datePicker.date,
                                                             debit: newMoneyAccount,
                                                             credit: capitalRootAccount,
                                                             debitAmount: round((balance - creditLimit)*100)/100,
                                                             creditAmount: round(round((balance - creditLimit)*100)/100 * exchangeRate*100)/100, // swiftlint:disable:this line_length
                                                             createdByUser: false,
                                                             context: context)
                    Transaction.addTransactionWith2TranItems(date: datePicker.date,
                                                             debit: newMoneyAccount,
                                                             credit: newCreditAccount,
                                                             debitAmount: round(creditLimit*100)/100,
                                                             creditAmount: round(creditLimit*100)/100,
                                                             createdByUser: false,
                                                             context: context)
                } else if balance - creditLimit == 0 {
                    if !(balance == 0 && creditLimit == 0) {
                        Transaction.addTransactionWith2TranItems(date: datePicker.date,
                                                                 debit: newMoneyAccount,
                                                                 credit: newCreditAccount,
                                                                 debitAmount: round(creditLimit*100)/100,
                                                                 creditAmount: round(creditLimit*100)/100,
                                                                 createdByUser: false,
                                                                 context: context)
                    }
                } else {
                    var expenseBeforeAccountingPeriod: Account? = expenseRootAccount.getSubAccountWith(name: AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod)) // swiftlint:disable:this line_length
                    if expenseBeforeAccountingPeriod == nil {
                        expenseBeforeAccountingPeriod = try? Account.createAndGetAccount(parent: expenseRootAccount,
                                                                                         name: AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod), // swiftlint:disable:this line_length
                                                                                         type: expenseRootAccount.type,
                                                                                         currency: expenseRootAccount.currency, // swiftlint:disable:this line_length
                                                                                         createdByUser: false,
                                                                                         context: context)
                    }
                    guard let expenseBeforeAccountingPeriodSafe = expenseBeforeAccountingPeriod
                    else {throw AccountWithBalanceError.canNotFindBeboreAccountingPeriodAccount}
                    Transaction.addTransactionWith2TranItems(date: datePicker.date,
                                                             debit: expenseBeforeAccountingPeriodSafe,
                                                             credit: newMoneyAccount,
                                                             debitAmount: round(round((creditLimit - balance)*100)/100 * exchangeRate*100)/100, // swiftlint:disable:this line_length
                                                             creditAmount: round((creditLimit - balance)*100)/100,
                                                             createdByUser: false,
                                                             context: context)
                    Transaction.addTransactionWith2TranItems(date: datePicker.date,
                                                             debit: newMoneyAccount,
                                                             credit: newCreditAccount,
                                                             debitAmount: round(creditLimit*100)/100,
                                                             creditAmount: round(creditLimit*100)/100,
                                                             createdByUser: false,
                                                             context: context)
                }
            }
        } else if parentAccount == debtorsRootAcccount {
            // Check exchange rate value
            if currency != accountingCurrency {
                if let rate: Double = Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: ".")) { // swiftlint:disable:this line_length
                    exchangeRate = rate
                } else {
                    throw AccountWithBalanceError.emptyExchangeRate
                }
            }
            let newDebtorsAccount = try Account.createAndGetAccount(parent: parentAccount,
                                                                    name: accountNameTextField.text!,
                                                                    type: parentAccount.type,
                                                                    currency: currency,
                                                                    keeper: keeper,
                                                                    holder: holder,
                                                                    context: context)
            Transaction.addTransactionWith2TranItems(date: datePicker.date,
                                                     debit: newDebtorsAccount,
                                                     credit: capitalRootAccount,
                                                     debitAmount: round(balance*100)/100,
                                                     creditAmount: round(round(balance*100)/100 * exchangeRate*100)/100,
                                                     createdByUser: false,
                                                     context: context)
        } else if parentAccount == creditsRootAccount {
            // Check exchange rate value
            if currency != accountingCurrency {
                if let rate: Double = Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                    exchangeRate = rate
                } else {
                    throw AccountWithBalanceError.emptyExchangeRate
                }
            }
            try? Account.createAccount(parent: expenseRootAccount, name: AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod), // swiftlint:disable:this line_length
                                       type: Account.TypeEnum.assets,
                                       currency: expenseRootAccount.currency,
                                       createdByUser: false,
                                       context: context)
            let newCreditAccount = try Account.createAndGetAccount(parent: parentAccount,
                                                                   name: accountNameTextField.text!,
                                                                   type: parentAccount.type,
                                                                   currency: currency,
                                                                   keeper: keeper,
                                                                   holder: holder,
                                                                   context: context)
            guard let expenseBeforeAccountingPeriod: Account = Account.getAccountWithPath("\(AccountsNameLocalisationManager.getLocalizedAccountName(.expense)):\(AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod))", context: context) // swiftlint:disable:this line_length
            else {throw AccountWithBalanceError.canNotFindBeboreAccountingPeriodAccount}
            Transaction.addTransactionWith2TranItems(date: datePicker.date,
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
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                          style: .default,
                                          handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                          style: .default,
                                          handler: { [self](_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Keyboard methods
extension AccountEditorWithInitialBalanceViewController: UIScrollViewDelegate {
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 40), right: 0.0)
        self.mainScrollView.contentInset = contentInsets
        self.mainScrollView.scrollIndicatorInsets = contentInsets
        self.mainScrollView.contentSize = self.view.frame.size
    }

    @objc func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.mainScrollView.contentInset = contentInsets
        self.mainScrollView.scrollIndicatorInsets = contentInsets
        self.mainScrollView.contentSize = self.mainView.frame.size
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func addDoneButtonOnDecimalKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0,
                                                                  width: UIScreen.main.bounds.width,
                                                                  height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""),
                                                    style: .done, target: self,
                                                    action: #selector(self.doneButtonAction))
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        accountNameTextField.inputAccessoryView = doneToolbar
        accountBalanceTextField.inputAccessoryView = doneToolbar
        creditLimitTextField.inputAccessoryView = doneToolbar
        exchangeRateTextField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        accountNameTextField.resignFirstResponder()
        accountBalanceTextField.resignFirstResponder()
        creditLimitTextField.resignFirstResponder()
        exchangeRateTextField.resignFirstResponder()
    }
}

extension AccountEditorWithInitialBalanceViewController: CurrencyReceiverDelegate {
    func setCurrency(_ selectedCurrency: Currency) {
        self.currency = selectedCurrency
    }
}

extension AccountEditorWithInitialBalanceViewController: KeeperReceiverDelegate {
    func setKeeper(_ selectedKeeper: Keeper?) {
        self.keeper = selectedKeeper
    }
}

extension AccountEditorWithInitialBalanceViewController: HolderReceiverDelegate {
    func setHolder(_ selectedHolder: Holder?) {
        self.holder = selectedHolder
    }
} // swiftlint:disable:this file_length
