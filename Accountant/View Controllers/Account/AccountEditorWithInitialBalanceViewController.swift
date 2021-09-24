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
    var moneyAccountType: AccountSubType? {
        didSet {
            guard let moneyAccountType = moneyAccountType else {return}
            
            switch moneyAccountType {
            case .debitCard:
                accountSubTypeButton.setImage(UIImage(systemName: "creditcard"), for: .normal)
                accountSubTypeButton.setTitle("Debit", for: .normal)
                creditLimitTextField.isHidden = true
            case .cash:
                accountSubTypeButton.setImage(UIImage(systemName: "banknote"), for: .normal)
                accountSubTypeButton.setTitle("Cash", for: .normal)
                creditLimitTextField.isHidden = true
            case .creditCard:
                accountSubTypeButton.setImage(UIImage(systemName: "creditcard.fill"), for: .normal)
                accountSubTypeButton.setTitle("Credit", for: .normal)
                if segmentedControl.selectedSegmentIndex == 1 {
                    creditLimitTextField.isHidden = false
                }
            default:
                break
            }
        }
    }
    
    weak var delegate : UIViewController?
    
    var accountingCurrency : Currency!
    var currency : Currency! {
        didSet{
            currencyButton.setTitle(currency.code!, for: .normal)
            if currency == accountingCurrency || segmentedControl.selectedSegmentIndex == 0{
                exchangeRateLabel.isHidden = true
                exchangeRateTextField.isHidden = true
                exchangeRateLabel.text = ""
                exchangeRateTextField.text = ""
            }
            else {
                exchangeRateLabel.isHidden = false
                exchangeRateTextField.isHidden = false
                exchangeRateLabel.text = "\(accountingCurrency.code!)/\(currency.code!)"
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
    
    
    let mainView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [NSLocalizedString("New",comment: ""),NSLocalizedString("Existing",comment: "")])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    let stepLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Step: 1", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Balance on:", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    let accountNameTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 100
        textField.placeholder = NSLocalizedString("Name", comment: "")
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
        textField.placeholder = NSLocalizedString("Balance", comment: "")
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
    
    let creditLimitTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 0
        textField.keyboardType = .decimalPad
        textField.placeholder = NSLocalizedString("Credit limit", comment: "")
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
        button.layer.cornerRadius = 34
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.Main.confirmButton
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
            
            preConfigureUI()
            if UserProfile.isAppLaunchedBefore() || coreDataStack.activeEnviroment() == .test {
                configureUIForNewAccount()
            }
            else {
                segmentedControl.selectedSegmentIndex = 1
                segmentedControl.isHidden = true
                configureUIForExistingAccount()
            }
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
    
    func addMainView() {
        
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
        
        //MARK:- Segmented Control
        mainView.addSubview(segmentedControl)
        segmentedControl.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true
        
        //MARK:- Step Label
        mainView.addSubview(stepLabel)
        stepLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        stepLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 25).isActive = true
        stepLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        //MARK:- Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 30).isActive = true
        //        mainStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        
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
        
        //MARK: - Date Stack View
        mainStackView.addArrangedSubview(dateStackView)
        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(datePicker)
        
        
        //MARK:- Account Name Text Field
        mainStackView.addArrangedSubview(accountNameTextField)
        accountNameTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        //MARK:- Account Balance Text Field
        mainStackView.addArrangedSubview(accountBalanceTextField)
        accountBalanceTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        //MARK:- Credit Limit Text Field
        mainStackView.addArrangedSubview(creditLimitTextField)
        creditLimitTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        
        //MARK:- Exchange Rate Stack View
        mainStackView.addArrangedSubview(exchangeRateStackView)
        //MARK:- Exchange Rate Label
        exchangeRateStackView.addArrangedSubview(exchangeRateLabel)
        //MARK:- Exchange Rate Text Field
        exchangeRateStackView.addArrangedSubview(exchangeRateTextField)
        exchangeRateTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        exchangeRateTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        
        
        
        //MARK:- Confirm Button
        view.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -89).isActive = true //49- tabbar heigth
        confirmButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -40).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
        
        
        confirmButton.addTarget(self, action: #selector(self.confirmCreation(_:)), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(self.selectNewOrExistingAccount(_:)), for: .valueChanged)
        currencyButton.addTarget(self, action: #selector(self.selectCurrency(_:)), for: .touchUpInside)
        accountSubTypeButton.addTarget(self, action: #selector(self.changeAccountSubType(_:)), for: .touchUpInside)
        accountNameTextField.addTarget(self, action: #selector(self.checkName(_:)), for: .editingChanged)
        
    }
    
    @objc func selectNewOrExistingAccount(_ sender: UISegmentedControl) {
        configureUIForNewAccount()
        configureUIForExistingAccount()
    }
    
    @objc func changeAccountSubType(_ sender: Any) {
        switch moneyAccountType {
        case .debitCard:
            moneyAccountType = .cash
        case .cash:
            moneyAccountType = .creditCard
        case .creditCard:
            moneyAccountType = .debitCard
        default:
            break
        }
    }
    
    @objc func selectCurrency(_ sender: Any) {
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
    
    @objc func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            }
            else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
            }
        }
    }
    
    func showPurchaseOfferVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func confirmCreation(_ sender: UIButton) {
        do{
            if accountNameTextField.text! == "" {
                let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please enter account name", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
                
            }
            else {
                guard isFreeNewAccountName else {return}
                if segmentedControl.selectedSegmentIndex == 0 { //new
                    context.rollback()
                    try createNewAccount()
                }
                else if segmentedControl.selectedSegmentIndex == 1 { //existing
                    context.rollback()
                    try createExistingAccountsAndTransactions()
                    try coreDataStack.saveContext(context)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        catch let error{
            self.errorHandler(error: error)
        }
    }
    
    func getRootAccounts() throws {
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
    
    func preConfigureUI() {
        currencyButton.backgroundColor = .systemGray5
        accountSubTypeButton.backgroundColor = .systemGray5
        datePicker.preferredDatePickerStyle = .compact
        exchangeRateLabel.isHidden = true
        exchangeRateTextField.isHidden = true
        exchangeRateLabel.text = ""
        exchangeRateTextField.text = ""
        
        self.navigationItem.title = NSLocalizedString("Add account", comment: "")
        
        if parentAccount == moneyRootAccount {
            moneyAccountType = .debitCard
            accountSubTypeButton.isHidden = false
            accountSubTypeLabel.isHidden = false
        }
        else {
            accountSubTypeButton.isHidden = true
            accountSubTypeLabel.isHidden = true
        }
    }
    
    func configureUIForNewAccount() {
        guard segmentedControl.selectedSegmentIndex == 0 else {return}
        datePicker.date = Date()
        datePicker.isUserInteractionEnabled = true
        stepLabel.isHidden = false
        dateStackView.isHidden = true
        accountBalanceTextField.isHidden = true
        creditLimitTextField.isHidden = true
        exchangeRateLabel.isHidden = true
        exchangeRateTextField.isHidden = true
        confirmButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
    }
    
    func configureUIForExistingAccount() {
        guard segmentedControl.selectedSegmentIndex == 1, let accountingStartDate = UserProfile.getAccountingStartDate() else {return}
        datePicker.date = accountingStartDate
        datePicker.isUserInteractionEnabled = true
        stepLabel.isHidden = true
        dateStackView.isHidden = false
        accountBalanceTextField.isHidden = false
        if accountingCurrency != currency {
            exchangeRateLabel.isHidden = false
            exchangeRateLabel.text = "\(accountingCurrency.code!)/\(currency.code!)"
            exchangeRateTextField.isHidden = false
        }
        else {
            exchangeRateLabel.isHidden = true
            exchangeRateTextField.isHidden = true
        }
        
        confirmButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        
        guard let moneyAccountType = moneyAccountType else {return}
        if moneyAccountType == .creditCard {
            creditLimitTextField.isHidden = false
        }
        else {
            creditLimitTextField.isHidden = true
        }
    }
    
    
    @objc func checkName(_ sender: UITextField){
        if sender.text! == "" {
            isFreeNewAccountName = false
        }
        else{
            if parentAccount == moneyRootAccount && moneyAccountType == .creditCard {
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
    
    func createNewAccount() throws {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let transactionEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.simpleTransactionEditorViewController) as! SimpleTransactionEditorViewController
        
        if let moneyAccountType = moneyAccountType {
            switch moneyAccountType {
            case .creditCard:
                if AccountManager.isFreeAccountName(parent: creditsRootAccount, name: accountNameTextField.text!, context: context) == false {
                    throw AccountError.creditAccountAlreadyExist(accountNameTextField.text!)
                }
                let newMoneyAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency, subType: moneyAccountType.rawValue, context: context)
                
                let newCreditAccount = try AccountManager.createAndGetAccount(parent: creditsRootAccount, name: accountNameTextField.text!, type: creditsRootAccount.type, currency: currency, context: context)
                newMoneyAccount.linkedAccount = newCreditAccount
                transactionEditorVC.tmpDebit = newMoneyAccount
                transactionEditorVC.tmpCredit = newCreditAccount
            default:
                let newAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency, subType: moneyAccountType.rawValue, context: context)
                transactionEditorVC.tmpDebit = newAccount
            }
        }
        else {
            let newAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency,context: context)
            if newAccount.type == AccountType.assets.rawValue {
                transactionEditorVC.tmpDebit = newAccount
            }
            else {
                transactionEditorVC.tmpCredit = newAccount
            }
        }
        transactionEditorVC.delegate = delegate
        self.navigationController?.pushViewController(transactionEditorVC, animated: true)
    }
    
    
    
    func createExistingAccountsAndTransactions() throws {
        var exchangeRate : Double = 1
        if currency != accountingCurrency, let rate : Double = Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: ".")) {
            exchangeRate = rate
        }
        else {
            throw AccountWithBalanceError.emptyExchangeRate
        }
        
        guard let balance : Double = Double(accountBalanceTextField.text!.replacingOccurrences(of: ",", with: ".")) else {return}
        
        if parentAccount == moneyRootAccount, let moneyAccountType = moneyAccountType {
            if moneyAccountType == .cash || moneyAccountType == .debitCard {
                guard moneyValidation(moneyAccount: parentAccount) else {return}
                let moneyAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency, subType: moneyAccountType.rawValue, context: context)
                TransactionManager.addTransaction(date: datePicker.date, debit: moneyAccount, credit: capitalRootAccount, debitAmount: round(balance*100)/100, creditAmount: round(round(balance*100)/100 * exchangeRate*100)/100, createdByUser : false, context: context)
            }
            else if moneyAccountType == .creditCard {
                guard moneyValidation(moneyAccount: parentAccount),
                      creditValidation(creditAccount: creditsRootAccount),
                      let creditLimit : Double = Double(creditLimitTextField.text!.replacingOccurrences(of: ",", with: "."))
                else {return}
                
                let newMoneyAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency, subType: moneyAccountType.rawValue, context: context)
                let newCreditAccount = try AccountManager.createAndGetAccount(parent: creditsRootAccount, name: accountNameTextField.text!, type: creditsRootAccount.type, currency: currency, context: context)
                
                newMoneyAccount.linkedAccount = newCreditAccount
                
                if balance - creditLimit > 0 {
                    TransactionManager.addTransaction(date: datePicker.date, debit: newMoneyAccount, credit: capitalRootAccount, debitAmount: round((balance - creditLimit)*100)/100, creditAmount: round(round((balance - creditLimit)*100)/100 * exchangeRate*100)/100, createdByUser : false, context: context)
                    TransactionManager.addTransaction(date: datePicker.date, debit: newMoneyAccount, credit: newCreditAccount, debitAmount: round(creditLimit*100)/100, creditAmount: round(creditLimit*100)/100, createdByUser : false, context: context)
                }
                else if balance - creditLimit == 0 {
                    TransactionManager.addTransaction(date: datePicker.date, debit: newMoneyAccount, credit: newCreditAccount, debitAmount: round(creditLimit*100)/100, creditAmount: round(creditLimit*100)/100, createdByUser : false, context: context)
                }
                else {
                    var expenseBeforeAccountingPeriod : Account? = AccountManager.getSubAccountWith(name: AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod), in: expenseRootAccount)
                    
                    if expenseBeforeAccountingPeriod == nil {
                        expenseBeforeAccountingPeriod = try? AccountManager.createAndGetAccount(parent: expenseRootAccount, name: AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod), type: expenseRootAccount.type, currency: expenseRootAccount.currency, createdByUser: false, context: context)
                    }
                    guard let expenseBeforeAccountingPeriodSafe = expenseBeforeAccountingPeriod else {return}
                    
                    TransactionManager.addTransaction(date: datePicker.date,debit: expenseBeforeAccountingPeriodSafe, credit: newMoneyAccount, debitAmount: round(round((creditLimit - balance)*100)/100 * exchangeRate*100)/100, creditAmount: round((creditLimit - balance)*100)/100, createdByUser : false, context: context)
                    TransactionManager.addTransaction(date: datePicker.date, debit: newMoneyAccount, credit: newCreditAccount, debitAmount: round(creditLimit*100)/100, creditAmount: round(creditLimit*100)/100, createdByUser : false, context: context)
                }
            }
        }
        else if parentAccount == debtorsRootAcccount && moneyValidation(moneyAccount: parentAccount) {
            let newDebtorsAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency, context: context)
            
            TransactionManager.addTransaction(date: datePicker.date, debit: newDebtorsAccount, credit: capitalRootAccount, debitAmount: round(balance*100)/100, creditAmount: round(round(balance*100)/100 * exchangeRate*100)/100, createdByUser : false, context: context)
        }
        else if parentAccount == creditsRootAccount && moneyValidation(moneyAccount: parentAccount) {
            try? AccountManager.createAccount(parent: expenseRootAccount, name: AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod), type: AccountType.assets.rawValue, currency: expenseRootAccount.currency, createdByUser: false, context: context)
            let newCreditAccount = try AccountManager.createAndGetAccount(parent: parentAccount, name: accountNameTextField.text!, type: parentAccount.type, currency: currency, context: context)
            guard let expenseBeforeAccountingPeriod : Account = AccountManager.getAccountWithPath("\(AccountsNameLocalisationManager.getLocalizedAccountName(.expense)):\(AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod))", context: context) else {return}
            TransactionManager.addTransaction(date: datePicker.date, debit: expenseBeforeAccountingPeriod, credit: newCreditAccount, debitAmount: (balance * exchangeRate*100)/100, creditAmount: balance, createdByUser : false, context: context)
        }
        
    }
    
    
    private func moneyValidation(moneyAccount: Account) -> Bool {
        if accountNameTextField.text == nil || accountNameTextField.text == "" {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please enter correct account name", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if AccountManager.isFreeAccountName(parent: moneyAccount, name: accountNameTextField.text!, context: context) == false {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("This account name is already exist", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if Double(accountBalanceTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please check the balance value", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    
    private func creditValidation(creditAccount: Account) -> Bool {
        if AccountManager.isFreeAccountName(parent: creditAccount, name: accountNameTextField.text!, context: context) == false {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: String(format: NSLocalizedString("With credit card we also create associated credit account and this account \"%@\" is already exist",comment: ""), creditAccount.name! + accountNameTextField.text!), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if Double(creditLimitTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please check the credit limit value", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    
    private func editValidation() -> Bool {
        if Double(creditLimitTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please check the credit limit value", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        //FIXME: - remove code below. user cannot enter value less then zero
        else if let creditLimit = Double(creditLimitTextField.text!.replacingOccurrences(of: ",", with: ".")), creditLimit < 0{
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Credit limit value can't be less than 0", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
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
    
    
    
    
    // MARK: - Keyboard methods
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




