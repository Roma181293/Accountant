//
//  AccountEditorWithInitialBalanceViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 10.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import Purchases

class AccountEditorWithInitialBalanceViewController: UIViewController, UIScrollViewDelegate {
    
    var isUserHasPaidAccess: Bool = false
    
    let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    var parentAccount : Account!
    
    var moneyRootAccount : Account!
    var creditsRootAccount : Account!
    var debtorsRootAcccount : Account!
    var expenseRootAccount : Account!
    var capitalRootAccount: Account!
    
    var isFreeNewAccountName : Bool = false
    var accountSubType: AccountSubType? {
        didSet {
            configureUIForAccontSubType()
        }
    }
    
    var accountingCurrency : Currency!
    var currency : Currency! {
        didSet{
            configureUIForCurrency()
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
    
    
    let mainView : UIView = {
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
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let accountSubTypeView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let accountSubTypeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Type:", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let accountSubTypeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let currencyView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Currency:", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let currencyButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
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
    
    let accountNameTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 100
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
        mainScrollView.delegate = self
        addMainView()
        
        reloadProAccessData()
        
        //MARK:- adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData), name: .receivedProAccessData, object: nil)
        
        do {
            try getRootAccounts()
            
            accountingCurrency = CurrencyManager.getAccountingCurrency(context: context)!
            currency = CurrencyManager.getAccountingCurrency(context: context)!
            
            addDoneButtonOnDecimalKeyboard()
            
            accountNameTextField.delegate = self as UITextFieldDelegate
            accountBalanceTextField.delegate = self as UITextFieldDelegate
            creditLimitTextField.delegate = self as UITextFieldDelegate
            exchangeRateTextField.delegate = self as UITextFieldDelegate
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
            
            configureUI()
        }
        catch let error{
            errorHandler(error: error)
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
        context.rollback()
    }
    
    private func addMainView() {
        
        //MARK:- Main Scroll View
        view.addSubview(mainScrollView)
        //        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: mainScrollView.frame.height)
        mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        //MARK:- Main View
        mainScrollView.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 10).isActive = true
        mainView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -10).isActive = true
        mainView.topAnchor.constraint(equalTo: mainScrollView.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor).isActive = true
        mainView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -20).isActive = true
        mainView.heightAnchor.constraint(equalTo: mainScrollView.heightAnchor).isActive = true
        
        //MARK:- Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 50).isActive = true
        
        //MARK:- Stack View
        mainStackView.addArrangedSubview(stackView)
        stackView.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        
        //MARK:- Currency View -
        stackView.addArrangedSubview(currencyView)
        currencyView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5).isActive = true
        //MARK:- Currency Label
        currencyView.addSubview(currencyLabel)
        currencyLabel.leadingAnchor.constraint(equalTo: currencyView.leadingAnchor).isActive = true
        currencyLabel.centerYAnchor.constraint(equalTo: currencyView.centerYAnchor).isActive = true
        
        //MARK:- Currency Button
        currencyView.addSubview(currencyButton)
        currencyButton.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 8).isActive = true
        currencyButton.centerYAnchor.constraint(equalTo: currencyView.centerYAnchor).isActive = true
        currencyButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        currencyButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        //MARK:- Account SubType View -
        stackView.addArrangedSubview(accountSubTypeView)
        accountSubTypeView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5).isActive = true
        //MARK:- Account SubType Label
        accountSubTypeView.addSubview(accountSubTypeLabel)
        accountSubTypeLabel.leadingAnchor.constraint(equalTo: accountSubTypeView.leadingAnchor).isActive = true
        accountSubTypeLabel.centerYAnchor.constraint(equalTo: accountSubTypeView.centerYAnchor).isActive = true
        
        //MARK:- Account SubType Button
        accountSubTypeView.addSubview(accountSubTypeButton)
        accountSubTypeButton.leadingAnchor.constraint(equalTo: accountSubTypeLabel.trailingAnchor, constant: 8).isActive = true
        accountSubTypeButton.centerYAnchor.constraint(equalTo: accountSubTypeView.centerYAnchor).isActive = true
        accountSubTypeButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        accountSubTypeButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        //MARK:- Name Label
        mainStackView.addArrangedSubview(nameLabel)
        mainStackView.setCustomSpacing(8, after: nameLabel)
        
        //MARK:- Name Text Field
        mainStackView.addArrangedSubview(accountNameTextField)
        accountNameTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        mainStackView.setCustomSpacing(20, after: accountNameTextField)
        
        //MARK: - Date Stack View
        mainStackView.addArrangedSubview(dateStackView)
        dateStackView.addArrangedSubview(balanceOnDateLabel)
        dateStackView.addArrangedSubview(datePicker)
        mainStackView.setCustomSpacing(8, after: dateStackView)
        
        //MARK:- Account Balance Text Field
        mainStackView.addArrangedSubview(accountBalanceTextField)
        accountBalanceTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        mainStackView.setCustomSpacing(20, after: accountBalanceTextField)
        
        //MARK:- Credit Limit Label
        mainStackView.addArrangedSubview(creditLimitLabel)
        mainStackView.setCustomSpacing(8, after: creditLimitLabel)
      
        //MARK:- Credit Limit Text Field
        mainStackView.addArrangedSubview(creditLimitTextField)
        creditLimitTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        mainStackView.setCustomSpacing(20, after: creditLimitTextField)
        
        //MARK:- Exchange Rate Label
        mainStackView.addArrangedSubview(exchangeRateLabel)
        mainStackView.setCustomSpacing(8, after: exchangeRateLabel)
        
        //MARK:- Exchange Rate Text Field
        mainStackView.addArrangedSubview(exchangeRateTextField)
        exchangeRateTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        mainStackView.setCustomSpacing(20, after: exchangeRateTextField)

        
        //MARK:- Confirm Button
        view.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -89).isActive = true //49- tabbar heigth
        confirmButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -40).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
        
        
        confirmButton.addTarget(self, action: #selector(self.confirmCreation(_:)), for: .touchUpInside)
        currencyButton.addTarget(self, action: #selector(self.selectCurrency(_:)), for: .touchUpInside)
        accountSubTypeButton.addTarget(self, action: #selector(self.changeAccountSubType(_:)), for: .touchUpInside)
        accountNameTextField.addTarget(self, action: #selector(self.checkName(_:)), for: .editingChanged)
        
    }
    
    @objc private func changeAccountSubType(_ sender: Any) {
        switch accountSubType {
        case .debitCard:
            accountSubType = .cash
        case .cash:
            accountSubType = .creditCard
        case .creditCard:
            accountSubType = .debitCard
        default:
            break
        }
    }
    
    @objc private func selectCurrency(_ sender: Any) {
        guard AccessCheckManager.checkUserAccessToCreateAccountInNotAccountingCurrency(environment: coreDataStack.activeEnviroment()!, isUserHasPaidAccess: isUserHasPaidAccess)
        else {
            self.showPurchaseOfferVC()
            return
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let currencyTableViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.currencyTableViewController) as! CurrencyTableViewController
        currencyTableViewController.delegate = self
        currencyTableViewController.currency = currency
        self.navigationController?.pushViewController(currencyTableViewController, animated: true)
    }
    
   
    
    @objc private func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            }
            else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
            }
        }
    }
    
    private func showPurchaseOfferVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc private func confirmCreation(_ sender: UIButton) {
        do{
            if accountNameTextField.text! == "" {
                throw AccountWithBalanceError.emptyAccountName
            }
            else {
                guard isFreeNewAccountName else {
                    throw AccountError.accountAlreadyExists(name: accountNameTextField.text!)
                }
                
                context.rollback()
                try createAccountsAndTransactions()
                try coreDataStack.saveContext(context)
                self.navigationController?.popViewController(animated: true)
            }
        }
        catch let error{
            self.errorHandler(error: error)
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
    
    private func configureUI() {
        currencyButton.backgroundColor = .systemGray5
        accountSubTypeButton.backgroundColor = .systemGray5
        datePicker.preferredDatePickerStyle = .compact
        exchangeRateLabel.isHidden = true
        exchangeRateTextField.isHidden = true
        exchangeRateLabel.text = ""
        exchangeRateTextField.text = ""
        
        self.navigationItem.title = NSLocalizedString("Add account", comment: "")
        
        if parentAccount == moneyRootAccount {
            accountSubType = .debitCard
            accountSubTypeButton.isHidden = false
            accountSubTypeLabel.isHidden = false
        }
        else {
            accountSubTypeButton.isHidden = true
            accountSubTypeLabel.isHidden = true
        }

        datePicker.isUserInteractionEnabled = true
        balanceOnDateLabel.isHidden = false
        datePicker.isHidden = false
        accountBalanceTextField.isHidden = false
        configureUIForCurrency()
        
        confirmButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        creditLimitLabel.isHidden = true
        creditLimitTextField.isHidden = true
        
        if let moneyAccountType = accountSubType,  moneyAccountType == .creditCard {
            creditLimitLabel.isHidden = false
            creditLimitTextField.isHidden = false
        }
    }
    
    private func configureUIForCurrency() {
        currencyButton.setTitle(currency.code!, for: .normal)
        if currency == accountingCurrency {
            exchangeRateLabel.isHidden = true
            exchangeRateTextField.isHidden = true
            exchangeRateLabel.text = ""
            exchangeRateTextField.text = ""
        }
        else {
            exchangeRateLabel.isHidden = false
            exchangeRateTextField.isHidden = false
            exchangeRateLabel.text = NSLocalizedString("Exchange rate", comment: "") + " \(accountingCurrency.code!)/\(currency.code!)"
        }
    }
    
    private func configureUIForAccontSubType() {
        guard let moneyAccountType = accountSubType else {return}
        
        switch moneyAccountType {
        case .debitCard:
            accountSubTypeButton.setImage(UIImage(systemName: "creditcard"), for: .normal)
            accountSubTypeButton.setTitle("Debit", for: .normal)
            creditLimitLabel.isHidden = true
            creditLimitTextField.isHidden = true
        case .cash:
            accountSubTypeButton.setImage(UIImage(systemName: "banknote"), for: .normal)
            accountSubTypeButton.setTitle("Cash", for: .normal)
            creditLimitLabel.isHidden = true
            creditLimitTextField.isHidden = true
        case .creditCard:
            accountSubTypeButton.setImage(UIImage(systemName: "creditcard.fill"), for: .normal)
            accountSubTypeButton.setTitle("Credit", for: .normal)
            creditLimitLabel.isHidden = false
            creditLimitTextField.isHidden = false
        default:
            break
        }
    }
    
    
    @objc private func checkName(_ sender: UITextField){
        if sender.text! == "" {
            isFreeNewAccountName = false
        }
        else{
            if parentAccount == moneyRootAccount && accountSubType == .creditCard {
                if AccountManager.isFreeAccountName(parent: parentAccount, name: accountNameTextField.text!, context: context) &&
                    AccountManager.isFreeAccountName(parent: creditsRootAccount, name: accountNameTextField.text!, context: context) {
                    accountNameTextField.backgroundColor = .systemBackground
                    isFreeNewAccountName = true
                }
                else {
                    accountNameTextField.backgroundColor = UIColor(displayP3Red: 255/255, green: 179/255, blue: 195/255, alpha: 1)
                    isFreeNewAccountName = false
                }
            }
            else {
                if AccountManager.isFreeAccountName(parent: parentAccount, name: accountNameTextField.text!, context: context) {
                    accountNameTextField.backgroundColor = .systemBackground
                    isFreeNewAccountName = true
                }
                else {
                    accountNameTextField.backgroundColor = UIColor(displayP3Red: 255/255, green: 179/255, blue: 195/255, alpha: 1)
                    isFreeNewAccountName = false
                }
            }
        }
    }
    
    private func createAccountsAndTransactions() throws {
        var exchangeRate : Double = 1
        
        //Check balance value
        guard let balance : Double = Double(accountBalanceTextField.text!.replacingOccurrences(of: ",", with: ".")) else {
            throw AccountWithBalanceError.emptyBalance
        }
        
        if parentAccount == moneyRootAccount, let accountSubType = accountSubType {
            if accountSubType == .cash || accountSubType == .debitCard {
                //Check exchange rate value
                if currency != accountingCurrency {
                    if let rate : Double = Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                        exchangeRate = rate
                    }
                    else {
                        throw AccountWithBalanceError.emptyExchangeRate
                    }
                }
                let moneyAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency, subType: accountSubType.rawValue, context: context)
                if balance != 0 {
                    TransactionManager.addTransaction(date: datePicker.date, debit: moneyAccount, credit: capitalRootAccount, debitAmount: round(balance*100)/100, creditAmount: round(round(balance*100)/100 * exchangeRate*100)/100, createdByUser : false, context: context)
                }
            }
            else if accountSubType == .creditCard {
                //Check credit account name is free
                guard AccountManager.isFreeAccountName(parent: creditsRootAccount, name: accountNameTextField.text!, context: context) else {
                    throw AccountError.creditAccountAlreadyExist(creditsRootAccount.name! + accountNameTextField.text!)
                }
                
                //Check credit limit value
                guard let creditLimit : Double = Double(creditLimitTextField.text!.replacingOccurrences(of: ",", with: ".")) else {
                    throw AccountWithBalanceError.emptyCreditLimit
                }
                
                //Check exchange rate value
                if currency != accountingCurrency {
                    if let rate : Double = Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                        exchangeRate = rate
                    }
                    else {
                        throw AccountWithBalanceError.emptyExchangeRate
                    }
                }
                
                let newMoneyAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency, subType: accountSubType.rawValue, context: context)
                let newCreditAccount = try AccountManager.createAndGetAccount(parent: creditsRootAccount, name: accountNameTextField.text!, type: creditsRootAccount.type, currency: currency, context: context)
                
                newMoneyAccount.linkedAccount = newCreditAccount
                
                if balance - creditLimit > 0 {
                    TransactionManager.addTransaction(date: datePicker.date, debit: newMoneyAccount, credit: capitalRootAccount, debitAmount: round((balance - creditLimit)*100)/100, creditAmount: round(round((balance - creditLimit)*100)/100 * exchangeRate*100)/100, createdByUser : false, context: context)
                    TransactionManager.addTransaction(date: datePicker.date, debit: newMoneyAccount, credit: newCreditAccount, debitAmount: round(creditLimit*100)/100, creditAmount: round(creditLimit*100)/100, createdByUser : false, context: context)
                }
                else if balance - creditLimit == 0 {
                    if balance == 0 && creditLimit == 0 {
                        
                    }
                    else {
                        TransactionManager.addTransaction(date: datePicker.date, debit: newMoneyAccount, credit: newCreditAccount, debitAmount: round(creditLimit*100)/100, creditAmount: round(creditLimit*100)/100, createdByUser : false, context: context)
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
                    
                    TransactionManager.addTransaction(date: datePicker.date,debit: expenseBeforeAccountingPeriodSafe, credit: newMoneyAccount, debitAmount: round(round((creditLimit - balance)*100)/100 * exchangeRate*100)/100, creditAmount: round((creditLimit - balance)*100)/100, createdByUser : false, context: context)
                    TransactionManager.addTransaction(date: datePicker.date, debit: newMoneyAccount, credit: newCreditAccount, debitAmount: round(creditLimit*100)/100, creditAmount: round(creditLimit*100)/100, createdByUser : false, context: context)
                }
            }
        }
        else if parentAccount == debtorsRootAcccount {
            //Check exchange rate value
            if currency != accountingCurrency {
                if let rate : Double = Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                    exchangeRate = rate
                }
                else {
                    throw AccountWithBalanceError.emptyExchangeRate
                }
            }
            
            let newDebtorsAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency, context: context)
            
            TransactionManager.addTransaction(date: datePicker.date, debit: newDebtorsAccount, credit: capitalRootAccount, debitAmount: round(balance*100)/100, creditAmount: round(round(balance*100)/100 * exchangeRate*100)/100, createdByUser : false, context: context)
        }
        else if parentAccount == creditsRootAccount {
            //Check exchange rate value
            if currency != accountingCurrency {
                if let rate : Double = Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                    exchangeRate = rate
                }
                else {
                    throw AccountWithBalanceError.emptyExchangeRate
                }
            }
            
            try? AccountManager.createAccount(parent: expenseRootAccount, name: AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod), type: AccountType.assets.rawValue, currency: expenseRootAccount.currency, createdByUser: false, context: context)
            
            let newCreditAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency, context: context)
            
            guard let expenseBeforeAccountingPeriod : Account = AccountManager.getAccountWithPath("\(AccountsNameLocalisationManager.getLocalizedAccountName(.expense)):\(AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod))", context: context) else {
                throw AccountWithBalanceError.canNotFindBeboreAccountingPeriodAccount
            }
            
            TransactionManager.addTransaction(date: datePicker.date, debit: expenseBeforeAccountingPeriod, credit: newCreditAccount, debitAmount: (balance * exchangeRate*100)/100, creditAmount: balance, createdByUser : false, context: context)
        }
        else {
            throw AccountWithBalanceError.notSupported
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
    
    
    
    
    // MARK: - Keyboard methods -
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 40), right: 0.0)
        self.mainScrollView.contentInset = contentInsets
        self.mainScrollView.scrollIndicatorInsets = contentInsets
        
        
        // **-- Scroll when keyboard shows up
        let aRect = self.view.frame
        self.mainScrollView.contentSize = aRect.size
        
        /* if((self.activeTextField) != nil)
         {
         self.scrollView.scrollRectToVisible(self.activeTextField!.frame, animated: true)
         }*/
        
    }
    
    
    @objc func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.mainScrollView.contentInset = contentInsets
        self.mainScrollView.scrollIndicatorInsets = contentInsets
        
        // **-- Scroll when keyboard shows up
        self.mainScrollView.contentSize = self.mainView.frame.size
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField : UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func addDoneButtonOnDecimalKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        
        accountNameTextField.inputAccessoryView = doneToolbar
        accountBalanceTextField.inputAccessoryView = doneToolbar
        creditLimitTextField.inputAccessoryView = doneToolbar
        exchangeRateTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        accountNameTextField.resignFirstResponder()
        accountBalanceTextField.resignFirstResponder()
        creditLimitTextField.resignFirstResponder()
        exchangeRateTextField.resignFirstResponder()
    }
}


extension AccountEditorWithInitialBalanceViewController: CurrencyReceiverDelegate{
    func setCurrency(_ selectedCurrency: Currency) {
        self.currency = selectedCurrency
    }
}
