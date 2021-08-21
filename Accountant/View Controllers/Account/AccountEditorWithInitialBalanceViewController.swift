//
//  AccountEditorWithInitialBalanceViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 10.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class AccountEditorWithInitialBalanceViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var moneyAccountTypeLabel: UILabel!
    @IBOutlet weak var moneyAccountTypeButton: UIButton!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var accountBalanceTextField: UITextField!
    @IBOutlet weak var creditLimitTextField: UITextField!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var exchangeRateTextField: UITextField!
    var confirmButton: UIButton!
    weak var delegate : UIViewController?
    weak var activeTextField: UITextField!
    
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
                moneyAccountTypeButton.setImage(UIImage(systemName: "creditcard"), for: .normal)
                moneyAccountTypeButton.setTitle("Debit", for: .normal)
                creditLimitTextField.isHidden = true
            case .cash:
                moneyAccountTypeButton.setImage(UIImage(systemName: "bitcoinsign.circle"), for: .normal)
                moneyAccountTypeButton.setTitle("Cash", for: .normal)
                creditLimitTextField.isHidden = true
            case .creditCard:
                moneyAccountTypeButton.setImage(UIImage(systemName: "creditcard.fill"), for: .normal)
                moneyAccountTypeButton.setTitle("Credit", for: .normal)
                if segmentedControl.selectedSegmentIndex == 1 {
                    creditLimitTextField.isHidden = false
                }
            default:
                break
            }
        }
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try getRootAccounts()
            
            accountingCurrency = CurrencyManager.getAccountingCurrency(context: context)!
            currency = CurrencyManager.getAccountingCurrency(context: context)!
            
            addDoneButtonOnDecimalKeyboard()
            addButtonToViewController()
            
            accountNameTextField.delegate = self as! UITextFieldDelegate
            accountBalanceTextField.delegate = self as! UITextFieldDelegate
            creditLimitTextField.delegate = self as! UITextFieldDelegate
            exchangeRateTextField.delegate = self as! UITextFieldDelegate
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
            
            preConfigureUI()
            configureUIForNewAccount()
        }
        catch let error{
            errorHandler(error: error)
        }
    }
    
    
    deinit{
        print(#function)
        context.rollback()
    }
    
    @IBAction func selectNewOrExistingAccount(_ sender: UISegmentedControl) {
        configureUIForNewAccount()
        configureUIForExistingAccount()
    }
    
    @IBAction func changeMoneyAccountType(_ sender: Any) {
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
    
    @IBAction func selectCurrency(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let currencyTableViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.currencyTableViewController) as! CurrencyTableViewController
        currencyTableViewController.delegate = self
        currencyTableViewController.currency = currency
        self.navigationController?.pushViewController(currencyTableViewController, animated: true)
    }
    
    @objc func confirmCreation(_ sender: UIButton) {
        do{
            if accountNameTextField.text! == "" {
                let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Prease enter account name", comment: ""), preferredStyle: .alert)
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
        datePicker.preferredDatePickerStyle = .compact
        exchangeRateLabel.isHidden = true
        exchangeRateTextField.isHidden = true
        exchangeRateLabel.text = ""
        exchangeRateTextField.text = ""
        
        self.navigationItem.title = NSLocalizedString("Add account", comment: "")
        
        if parentAccount == moneyRootAccount {
            moneyAccountType = .debitCard
            moneyAccountTypeButton.isHidden = false
            moneyAccountTypeLabel.isHidden = false
        }
        else {
            moneyAccountTypeButton.isHidden = true
            moneyAccountTypeLabel.isHidden = true
        }
    }
    
    func configureUIForNewAccount() {
        guard segmentedControl.selectedSegmentIndex == 0 else {return}
        datePicker.date = Date()
        datePicker.isUserInteractionEnabled = true
        stepLabel.isHidden = false
        datePicker.isHidden = true
        accountBalanceTextField.isHidden = true
        creditLimitTextField.isHidden = true
        exchangeRateLabel.isHidden = true
        exchangeRateTextField.isHidden = true
        confirmButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
    }
    
    func configureUIForExistingAccount() {
        guard segmentedControl.selectedSegmentIndex == 1, let accountingStartDate = UserProfile.getAccountingStartDate() else {return}
        datePicker.date = accountingStartDate
        datePicker.isUserInteractionEnabled = false
        stepLabel.isHidden = true
        datePicker.isHidden = false
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
    
    
    @IBAction func checkName(_ sender: UITextField){
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
                    
                    let newCreditAccount = try AccountManager.createAndGetAccount(parent: creditsRootAccount, name: accountNameTextField.text!, type: creditsRootAccount.type, currency: currency, subType: moneyAccountType.rawValue, context: context)
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
                        expenseBeforeAccountingPeriod = try? AccountManager.createAndGetAccount(parent: expenseRootAccount, name: AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod), type: expenseRootAccount.type, currency: currency, createdByUser: false, context: context)
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
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: String(format: NSLocalizedString("With credit card we also create associated credit account and this account %@ is already exist",comment: ""), creditAccount.name! + accountNameTextField.text!), preferredStyle: .alert)
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
    
    
    func exchangeRateValidation() -> Bool {
        if currency != accountingCurrency && (exchangeRateTextField.text == "" || Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil){  //case when no internet
            let alert = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: String(format: NSLocalizedString("Bad internet connection. Please enter exchange rate %@/%@",comment: ""), accountingCurrency.code!,currency.code!), preferredStyle: .alert)
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
        else if let creditLimit = Double(creditLimitTextField.text!.replacingOccurrences(of: ",", with: ".")), creditLimit < 0{
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Credit limit value can't be less than 0", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    
    func errorHandler(error : Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { [self](_) in
                  self.navigationController?.popViewController(animated: true)
              }))
              self.present(alert, animated: true, completion: nil)
    }
    
    
    
    private func addButtonToViewController() {
        confirmButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70 , y: self.view.frame.height - 150), size: CGSize(width: 68, height: 68)))
        confirmButton.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 243/255, alpha: 1)
        view.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -89), //49- tabbar heigth
            confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            confirmButton.heightAnchor.constraint(equalToConstant: 68),
            confirmButton.widthAnchor.constraint(equalToConstant: 68)
          ])
        
        confirmButton.layer.cornerRadius = 34
        if let image = UIImage(systemName: "checkmark") {
            confirmButton.setImage(image, for: .normal)
        }
        confirmButton.addTarget(self, action: #selector(AccountEditorWithInitialBalanceViewController.confirmCreation(_:)), for: .touchUpInside)
    }
    
    
    // MARK: - Keyboard methods
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardY = self.view.frame.size.height - keyboardSize.height - 60
            let editingTextFieldY : CGFloat = self.stackView.frame.origin.y + self.activeTextField!.frame.origin.y
            
            if editingTextFieldY > keyboardY - 60 {
                UIView.animate(withDuration: 0.25, delay: 0.00, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.view.frame = CGRect(x: 0, y: -(editingTextFieldY - (keyboardY - 60)), width: self.view.bounds.width, height: self.view.bounds.height)
                }, completion: nil)
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0.00, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField : UITextField) {
        activeTextField = textField
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
