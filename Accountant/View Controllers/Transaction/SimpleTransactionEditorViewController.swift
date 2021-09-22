//  TransactionEditorViewControllerOld.swift
//  Accounting
//
//  Created by Roman Topchii on 15.03.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import Purchases

class SimpleTransactionEditorViewController: UIViewController, GADFullScreenContentDelegate {
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var creditButton: UIButton!
    @IBOutlet weak var amountInCreditCurrencyTextField: UITextField!
    @IBOutlet weak var debitButton: UIButton!
    @IBOutlet weak var amountInDebitCurrencyTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var creditToDebitExchangeRateLabel: UILabel!
    @IBOutlet weak var debitToCreditExchangeRateLabel: UILabel!
    @IBOutlet weak var useExchangeRateSwich: UISwitch!
    @IBOutlet weak var useExchangeRateLabel: UILabel!
    @IBOutlet weak var outertStackView: UIStackView!
    @IBOutlet weak var accountStackView: UIStackView!
    @IBOutlet weak var amountStackView: UIStackView!
    var addButton: UIButton!
    weak var delegate : UIViewController?
    
    var activeTextField : UITextField!
    
    var interstitial: GADInterstitialAd?
    
    var isUserHasPaidAccess = false
    
    let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    weak var transaction : Transaction?
    
    var debit : Account? {
        didSet {
            configureUI()
        }
    }
    var credit : Account? {
        didSet {
            configureUI()
        }
    }
    
    var tmpDebit: Account?
    var tmpCredit: Account?
    
    var currencyHistoricalData : CurrencyHistoricalDataProtocol? {
        didSet{
            setExchangeRateToLabel()
        }
    }
    var selectedRateCreditToDebit : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK:- adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData), name: .receivedProAccessData, object: nil)
        reloadProAccessData()
        interstitial?.fullScreenContentDelegate = self
        showPreContent()
        initialConfigureUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let credit = credit, let name = credit.path{
            creditButton.setTitle("\(NSLocalizedString("From:", comment: "")) \(name)", for: .normal)
        }
        else {
            creditButton.setTitle(NSLocalizedString("From: Account", comment: ""), for: .normal)
        }
        if let debit = debit, let name = debit.path {
            debitButton.setTitle("\(NSLocalizedString("To:", comment: "")) \(name)", for: .normal)
        }
        else {
            debitButton.setTitle(NSLocalizedString("To: Account", comment: ""), for: .normal)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        dismissKeyboard()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
        context.rollback()
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
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        getExhangeRate()
    }
    
    
    @objc func done(_ sender: UIButton) {
        guard validation() == true else {return}
        if let transaction = transaction{
            //, (datePicker.date != transaction.date || Double(amountInDebitCurrencyTextField.text!) != transaction.amountInDebitCurrency || Double(amountInCreditCurrencyTextField.text!) != transaction.amountInCreditCurrency || debit != transaction.debitAccount || credit != transaction.creditAccount){ //check for changing
            
            let alert = UIAlertController(title: NSLocalizedString("Save", comment: ""), message: NSLocalizedString("Do you want to save changes?", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { [] (_) in
                TransactionManager.deleteTransaction(transaction, context: self.context)
                self.addNewTransaction()
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
        else if transaction == nil {
            addNewTransaction()
            if let delegate = delegate {
                self.navigationController?.popToViewController(delegate, animated: true)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func editingChangedAmountValue(_ sender: UITextField) {
        guard let credit = credit,
              let debit = debit,
              let creditCurrency = credit.currency,
              let debitCurrency = debit.currency,
              creditCurrency != debitCurrency,
              let selectedRate = selectedRateCreditToDebit,
              selectedRate != 0
        else {return}
        
        if useExchangeRateSwich.isOn {
            if sender.tag == 1{
                if let amount = Double(sender.text!.replacingOccurrences(of: ",", with: ".")){
                    amountInDebitCurrencyTextField.text = String(round(amount/selectedRate*100)/100)
                }
                else {
                    amountInDebitCurrencyTextField.text = ""
                }
            }
            if sender.tag == 2{
                if let amount = Double(sender.text!.replacingOccurrences(of: ",", with: ".")) {
                    amountInCreditCurrencyTextField.text = String(round(amount*selectedRate*100)/100)
                }
                else {
                    amountInCreditCurrencyTextField.text = ""
                }
            }
        }
        else {
            if let amountInCreditCurrency = Double(amountInCreditCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")),
               let amountInDebitCurrency = Double(amountInDebitCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")){
                creditToDebitExchangeRateLabel.text = "\(creditCurrency.code!)/\(debitCurrency.code!): \(round(amountInCreditCurrency/amountInDebitCurrency*10000)/10000)"
                debitToCreditExchangeRateLabel.text = "\(debitCurrency.code!)/\(creditCurrency.code!): \(round(amountInDebitCurrency/amountInCreditCurrency*10000)/10000)"
            }
            else {
                creditToDebitExchangeRateLabel.text = "\(creditCurrency.code!)/\(debitCurrency.code!): "
                debitToCreditExchangeRateLabel.text = "\(debitCurrency.code!)/\(creditCurrency.code!): "
            }
        }
    }
    
    
    @IBAction func isUseExchangeRate(_ sender: UISwitch) {
        if sender.isOn {
            debitToCreditExchangeRateLabel.isHidden = false
            creditToDebitExchangeRateLabel.isHidden = false
            getExhangeRate()
//            setExchangeRateToLabel()
        }
        else {
            debitToCreditExchangeRateLabel.isHidden = true
            creditToDebitExchangeRateLabel.isHidden = true
        }
    }
    
    func showPreContent() {
        if isUserHasPaidAccess == false {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 25), execute:{
                switch UserProfile.whatPreContentShowInView(.transactionEditor) {
                case .add:
                    if let interstitial = self.interstitial {
                        interstitial.present(fromRootViewController: self)
                    }
                case .offer:
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
                    self.navigationController?.present(vc, animated: true, completion: nil)
                default:
                    return
                }
            })
        }
    }
    
    func initialConfigureUI() {
        debitButton.backgroundColor = .systemGray5
        creditButton.backgroundColor = .systemGray5
        
//        if let startyAccountingDate = UserProfile.getAccountingStartDate() {
//            datePicker.minimumDate = startyAccountingDate
//        }
        addDoneButtonToViewController()
        if transaction == nil && tmpDebit == nil && tmpCredit == nil{
            getExhangeRate()
            self.navigationItem.title = NSLocalizedString("Add transaction", comment: "")
            self.navigationItem.rightBarButtonItem = nil
            debit = nil
            credit = nil
            stepLabel.isHidden = true
        }
        else if tmpCredit != nil || tmpDebit != nil {
            if tmpCredit != nil {
                creditButton.isUserInteractionEnabled = false
            }
            if tmpDebit != nil {
                debitButton.isUserInteractionEnabled = false
            }
            self.navigationItem.title = NSLocalizedString("Add transaction", comment: "")
            self.navigationItem.rightBarButtonItem = nil
            getExhangeRate()
            credit = tmpCredit
            debit = tmpDebit
        }
        else {
            fillUIForExistingTransaction()
            stepLabel.isHidden = true
        }
        
        // keyboard
        addDoneButtonOnDecimalKeyboard()
        
        amountInDebitCurrencyTextField.delegate = self as! UITextFieldDelegate
        amountInCreditCurrencyTextField.delegate = self as! UITextFieldDelegate
        memoTextField.delegate = self as! UITextFieldDelegate
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    private func configureUI(){
        amountInCreditCurrencyTextField.placeholder = ""
        
        amountInCreditCurrencyTextField.text = ""
        
        
        if let credit = credit, let debit = debit {
            if debit.currency == nil || credit.currency == nil {
                amountInDebitCurrencyTextField.placeholder = ""
                amountInCreditCurrencyTextField.isHidden = true
                amountStackView.isHidden = false
                amountInDebitCurrencyTextField.isHidden = false
                creditToDebitExchangeRateLabel.isHidden = true
                debitToCreditExchangeRateLabel.isHidden = true
                amountInDebitCurrencyTextField.placeholder = ""
                amountInDebitCurrencyTextField.text = ""
                useExchangeRateSwich.isHidden = true
                useExchangeRateLabel.isHidden = true
            }
            else if credit.currency == debit.currency {
                amountInDebitCurrencyTextField.placeholder = debit.currency!.code!
                amountInCreditCurrencyTextField.isHidden = true
                amountStackView.isHidden = false
                amountInDebitCurrencyTextField.isHidden = false
                creditToDebitExchangeRateLabel.isHidden = true
                debitToCreditExchangeRateLabel.isHidden = true
                useExchangeRateSwich.isHidden = true
                useExchangeRateLabel.isHidden = true
            }
            else {
                amountInCreditCurrencyTextField.placeholder = credit.currency!.code!
                amountInDebitCurrencyTextField.placeholder = debit.currency!.code!
                amountStackView.isHidden = false
                amountInCreditCurrencyTextField.isHidden = false
                amountInDebitCurrencyTextField.isHidden = false
                creditToDebitExchangeRateLabel.isHidden = false
                debitToCreditExchangeRateLabel.isHidden = false
//                amountInDebitCurrencyTextField.placeholder = ""
                amountInDebitCurrencyTextField.text = ""
                useExchangeRateSwich.isHidden = false
                useExchangeRateLabel.isHidden = false
                setExchangeRateToLabel()
            }
        }
        else if debit == nil || credit == nil {
            amountStackView.isHidden = true
            amountInCreditCurrencyTextField.isHidden = true
            amountInDebitCurrencyTextField.isHidden = true
            creditToDebitExchangeRateLabel.isHidden = true
            debitToCreditExchangeRateLabel.isHidden = true
            amountInDebitCurrencyTextField.placeholder = ""
            amountInDebitCurrencyTextField.text = ""
            useExchangeRateSwich.isHidden = true
            useExchangeRateLabel.isHidden = true
        }
    }
    
    
    private func setExchangeRateToLabel() {
        guard let debit = debit, let debitCurrency = debit.currency, let credit = credit, let creditCurrency = credit.currency, debitCurrency != creditCurrency
        else {return}
        
        if useExchangeRateSwich.isOn {
        guard let currencyHistoricalData = currencyHistoricalData, let rate = currencyHistoricalData.exchangeRate(curr: creditCurrency.code!, to: debitCurrency.code!) else {return}
        print(rate)
        selectedRateCreditToDebit = rate
        creditToDebitExchangeRateLabel.text = "\(creditCurrency.code!)/\(debitCurrency.code!): \(round(rate*10000)/10000)"
        debitToCreditExchangeRateLabel.text = "\(debitCurrency.code!)/\(creditCurrency.code!): \(round(1.0/rate*10000)/10000)"
        }
        else if let amountInCreditCurrency = Double(amountInCreditCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")),
                let amountInDebitCurrency = Double(amountInDebitCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) {
            selectedRateCreditToDebit = amountInCreditCurrency/amountInDebitCurrency
            creditToDebitExchangeRateLabel.text = "\(creditCurrency.code!)/\(debitCurrency.code!): \(round(selectedRateCreditToDebit!*10000)/10000)"
            debitToCreditExchangeRateLabel.text = "\(debitCurrency.code!)/\(creditCurrency.code!): \(round(1.0/selectedRateCreditToDebit!*10000)/10000)"
        }
        
    }
    
    
    /**
     This method load currencyHistoricalData from the internet
     */
    private func getExhangeRate() {
        if useExchangeRateSwich.isOn {
            creditToDebitExchangeRateLabel.text = ""
            debitToCreditExchangeRateLabel.text = ""
            selectedRateCreditToDebit = nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        if let storedCurrencyHistoricalData = UserProfile.getLastExchangeRate(), storedCurrencyHistoricalData.exchangeDateStringFormat() == dateFormatter.string(from:datePicker.date) {
            currencyHistoricalData = storedCurrencyHistoricalData
        }
        else {
            currencyHistoricalData = nil
            NetworkServices.loadCurrency(date: datePicker.date) { (currencyHistoricalData, error) in
                if let currencyHistoricalData = currencyHistoricalData {
                    DispatchQueue.main.async {
                        self.currencyHistoricalData = currencyHistoricalData
                    }
                }
            }
        }
    }
    
    
    private func addNewTransaction() {
        guard let debit = debit, let credit = credit else {return}
        
        if debit.currency == credit.currency {
            if let amountInDebitCurrency = Double(amountInDebitCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                TransactionManager.addTransaction(date: datePicker.date, debit: debit, credit: credit, debitAmount: amountInDebitCurrency, creditAmount: amountInDebitCurrency, comment: memoTextField.text, context: context)
            }
        }
        else {
            if let amountInDebitCurrency = Double(amountInDebitCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")),
               let amountInCreditCurrency = Double(amountInCreditCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                TransactionManager.addTransaction(date: datePicker.date, debit: debit, credit: credit, debitAmount: amountInDebitCurrency, creditAmount: amountInCreditCurrency, comment: memoTextField.text, context: context)
            }
        }
        
        if context.hasChanges {
            do {
                try coreDataStack.saveContext(context)
            } catch let error {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    private func fillUIForExistingTransaction() {
        guard let transaction = transaction,
              let date = transaction.date,
              let items = transaction.items?.allObjects as? [TransactionItem]
        else {return}
        
        var debitAcc: Account?
        var creditAcc: Account?
        var debitAmnt: Double?
        var creditAmnt: Double?
        
        for item in items {
            if item.type == AccounttingMethod.debit.rawValue {
                debitAcc = item.account
                debitAmnt = item.amount
            }
            else if item.type == AccounttingMethod.credit.rawValue {
                creditAcc = item.account
                creditAmnt = item.amount
            }
        }
        
        guard let debitAccount = debitAcc,
              let creditAccount = creditAcc,
              let debitAmount = debitAmnt,
              let creditAmount = creditAmnt
        else {return}
        
        self.navigationItem.title = NSLocalizedString("Edit transaction", comment: "")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(done))
        addButton.isHidden = true
        
        datePicker.date = date
        
        debit = debitAccount
        credit = creditAccount
        
        if debit?.currency != credit?.currency {
            amountInDebitCurrencyTextField.text = "\(debitAmount)"
            amountInCreditCurrencyTextField.text = "\(creditAmount)"
            
            useExchangeRateSwich.isOn = false
            
            selectedRateCreditToDebit = creditAmount/debitAmount
            
            creditToDebitExchangeRateLabel.text = "\(creditAccount.currency!.code!)/\(debitAccount.currency!.code!): \(round(creditAmount/debitAmount*10000)/10000)"
            debitToCreditExchangeRateLabel.text = "\(debitAccount.currency!.code!)/\(creditAccount.currency!.code!): \(round(debitAmount/creditAmount*10000)/10000)"
        }
        else {
            amountInDebitCurrencyTextField.text = "\(debitAmount)"
        }
        
        if let comment = transaction.comment {
            self.memoTextField.text = comment
        }
    }
    
    
    private func validation() -> Bool {
        if credit?.parent == nil && credit?.name != AccountsNameLocalisationManager.getLocalizedAccountName(.capital) {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please select \"From:\" category", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if debit?.parent == nil  && debit?.name != AccountsNameLocalisationManager.getLocalizedAccountName(.capital) {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please select \"To:\" category", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if Double(amountInDebitCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please check the \"To:\" amount value", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if Double(amountInCreditCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil && debit?.currency != credit?.currency {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please check the \"From:\" amount value", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    private func addDoneButtonToViewController() {
        addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70 , y: self.view.frame.height - 150), size: CGSize(width: 68, height: 68)))
        addButton.backgroundColor = .systemGray5
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -89),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            addButton.heightAnchor.constraint(equalToConstant: 68),
            addButton.widthAnchor.constraint(equalToConstant: 68),
        ])
        
        addButton.layer.cornerRadius = 34
        if let image = UIImage(systemName: "checkmark") {
            addButton.setImage(image, for: .normal)
        }
        addButton.addTarget(self, action: #selector(SimpleTransactionEditorViewController.done(_:)), for: .touchUpInside)
    }
    
    // MARK:- Keyboard methods
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, let activeTextField = activeTextField {
            let keyboardY = self.view.frame.size.height - keyboardSize.height - 60
            
            var editingTextFieldY : CGFloat! = 0
            if  activeTextField.tag == 200 {  //memo
                editingTextFieldY = self.outertStackView.frame.origin.y + activeTextField.frame.origin.y
            }
            else { //amounts
                editingTextFieldY = self.outertStackView.frame.origin.y + self.accountStackView.frame.origin.y + self.amountStackView.frame.origin.y + activeTextField.frame.origin.y
            }
            
            if editingTextFieldY > keyboardY - 60 {
                UIView.animate(withDuration: 0.25, delay: 0.00, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.view.frame = CGRect(x: 0, y: -(editingTextFieldY! - (keyboardY - 60)), width: self.view.bounds.width, height: self.view.bounds.height)
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
    
    func addDoneButtonOnDecimalKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        amountInDebitCurrencyTextField.inputAccessoryView = doneToolbar
        amountInCreditCurrencyTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        amountInDebitCurrencyTextField.resignFirstResponder()
        amountInCreditCurrencyTextField.resignFirstResponder()
        memoTextField.resignFirstResponder()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.debitToAccountNavigator {
            let vc = segue.destination as! AccountNavigatorTableViewController
            vc.simpleTransactionEditorVC = self
            vc.showHiddenAccounts = false
            vc.searchBarIsHidden = false
            vc.typeOfAccountingMethod = .debit
            vc.isUserHasPaidAccess = isUserHasPaidAccess
            doneButtonAction()
        }
        if segue.identifier == Constants.Segue.creditToAccountNavigator {
            let vc = segue.destination as! AccountNavigatorTableViewController
            vc.simpleTransactionEditorVC = self
            vc.showHiddenAccounts = false
            vc.searchBarIsHidden = false
            vc.typeOfAccountingMethod = .credit
            vc.isUserHasPaidAccess = isUserHasPaidAccess
            doneButtonAction()
        }
    }
}
