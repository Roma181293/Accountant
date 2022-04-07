//  TransactionEditorViewControllerOld.swift
//  Accounting
//
//  Created by Roman Topchii on 15.03.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData
//import GoogleMobileAds
import Purchases

class SimpleTransactionEditorViewController: UIViewController {//}, GADFullScreenContentDelegate {
    
    weak var delegate : UIViewController?
    
    //    var interstitial: GADInterstitialAd?
    
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
    
    var currencyHistoricalData : CurrencyHistoricalDataProtocol? {
        didSet{
            setExchangeRateToLabel()
        }
    }
    
    var selectedRateCreditToDebit : Double?
    
    
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
    
    let transactionTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [NSLocalizedString("Expense",comment: ""),
                                                          NSLocalizedString("Income1",comment: ""),
                                                          NSLocalizedString("Transfer",comment: ""),
                                                          NSLocalizedString("Manual",comment: "")])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    let creditButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let amountInCreditCurrencyTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 1
        textField.textAlignment = .right
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
    
    let debitButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let amountInDebitCurrencyTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 2
        textField.textAlignment = .right
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
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 200
        textField.placeholder = NSLocalizedString("Comment", comment: "")
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
    
    let creditToDebitExchangeRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let debitToCreditExchangeRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let useExchangeRateSwich: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    let useExchangeRateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Use exchange rate", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let accountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let amountStackView: UIStackView! = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let exchangeRateControlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let exchangeRateLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let addButton: UIButton = {
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
        addMainView()
        
        addButton.addTarget(self, action: #selector(self.done(_:)), for: .touchUpInside)
        transactionTypeSegmentedControl.addTarget(self, action: #selector(self.transactionTypeDidChange(_:)), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(self.changeDate(_:)), for: .valueChanged)
        debitButton.addTarget(self, action: #selector(self.selectDebitAccount), for: .touchUpInside)
        creditButton.addTarget(self, action: #selector(self.selectCreditAccount), for: .touchUpInside)
        useExchangeRateSwich.addTarget(self, action: #selector(self.isUseExchangeRate(_:)), for: .valueChanged)
        amountInDebitCurrencyTextField.addTarget(self, action: #selector(self.editingChangedAmountValue(_:)), for: .editingChanged)
        amountInCreditCurrencyTextField.addTarget(self, action: #selector(self.editingChangedAmountValue(_:)), for: .editingChanged)
        
        
        amountInDebitCurrencyTextField.delegate = self
        amountInCreditCurrencyTextField.delegate = self
        commentTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        reloadProAccessData()
        //        interstitial?.fullScreenContentDelegate = self
        
        showPreContent()
        initialConfigureUI()
        
        // keyboard
        addDoneButtonOnDecimalKeyboard()
        
        //MARK:- adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData), name: .receivedProAccessData, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setAccountNameToButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func setAccountNameToButtons() {
        if let credit = credit {
            creditButton.setTitle("\(NSLocalizedString("From:", comment: "")) \(credit.path)", for: .normal)
        }
        else {
            creditButton.setTitle(NSLocalizedString("From: Account", comment: ""), for: .normal)
        }
        if let debit = debit {
            debitButton.setTitle("\(NSLocalizedString("To:", comment: "")) \(debit.path)", for: .normal)
        }
        else {
            debitButton.setTitle(NSLocalizedString("To: Account", comment: ""), for: .normal)
        }
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
        
    
        //MARK:- Outert Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 25).isActive = true
        
        //MARK:- Transaction Type Segmented Control
        mainStackView.addArrangedSubview(transactionTypeSegmentedControl)
        
        //MARK:- Date Picker
        mainStackView.addArrangedSubview(datePicker)
        
        //MARK:- Account Stack View
        mainStackView.addArrangedSubview(accountStackView)
        
        //MARK:- Button Stack View
        accountStackView.addArrangedSubview(buttonStackView)
        
        //MARK:- Credit Button
        buttonStackView.addArrangedSubview(creditButton)
        
        //MARK:- Debit Button
        buttonStackView.addArrangedSubview(debitButton)
        
        
        //MARK:- Amount Stack View
        accountStackView.addArrangedSubview(amountStackView)
        amountStackView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        amountStackView.addArrangedSubview(amountInCreditCurrencyTextField)
        amountStackView.addArrangedSubview(amountInDebitCurrencyTextField)
        
        mainStackView.addArrangedSubview(commentTextField)
        commentTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        mainStackView.addArrangedSubview(exchangeRateControlStackView)
        exchangeRateControlStackView.addArrangedSubview(useExchangeRateSwich)
        exchangeRateControlStackView.addArrangedSubview(useExchangeRateLabel)
        
        mainStackView.addArrangedSubview(exchangeRateLabelsStackView)
        exchangeRateLabelsStackView.addArrangedSubview(creditToDebitExchangeRateLabel)
        exchangeRateLabelsStackView.addArrangedSubview(debitToCreditExchangeRateLabel)
        
        //MARK:- Confirm Button
        mainView.addSubview(addButton)
        addButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -89).isActive = true //49- tabbar heigth
        addButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -40).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
    }
    
    @objc func transactionTypeDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Expense")
            debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.expense), context: context)
            credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
        case 1:
            print("Income")
            debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
            credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.income), context: context)
        case 2:
            print("Transfer")
            debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
            credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
        default:
            print("Manual")
            //            tmpDebit = nil
            //            tmpCredit = nil
            debit = nil
            credit = nil
        }
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
    
    @objc func changeDate(_ sender: UIDatePicker) {
        getExhangeRate()
    }
    
    
    @objc func done(_ sender: UIButton) {
        guard validation() == true else {return}
        if let transaction = transaction {
            //, (datePicker.date != transaction.date || Double(amountInDebitCurrencyTextField.text!) != transaction.amountInDebitCurrency || Double(amountInCreditCurrencyTextField.text!) != transaction.amountInCreditCurrency || debit != transaction.debitAccount || credit != transaction.creditAccount){ //check for changing
            
            let alert = UIAlertController(title: NSLocalizedString("Save", comment: ""), message: NSLocalizedString("Do you want to save changes?", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { [] (_) in
                transaction.delete(context: self.context)
                self.addNewTransaction()
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
        else if transaction == nil {
            addNewTransaction()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @objc func editingChangedAmountValue(_ sender: UITextField) {
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
                creditToDebitExchangeRateLabel.text = "\(creditCurrency.code)/\(debitCurrency.code): \(round(amountInCreditCurrency/amountInDebitCurrency*10000)/10000)"
                debitToCreditExchangeRateLabel.text = "\(debitCurrency.code)/\(creditCurrency.code): \(round(amountInDebitCurrency/amountInCreditCurrency*10000)/10000)"
            }
            else {
                creditToDebitExchangeRateLabel.text = "\(creditCurrency.code)/\(debitCurrency.code): "
                debitToCreditExchangeRateLabel.text = "\(debitCurrency.code)/\(creditCurrency.code): "
            }
        }
    }
    
    
    @objc func isUseExchangeRate(_ sender: UISwitch) {
        if sender.isOn {
            debitToCreditExchangeRateLabel.isHidden = false
            creditToDebitExchangeRateLabel.isHidden = false
            getExhangeRate()
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
                    break
                //                    if let interstitial = self.interstitial {
                //                        interstitial.present(fromRootViewController: self)
                //                    }
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
        debitButton.backgroundColor = Colors.Main.defaultButton
        creditButton.backgroundColor = Colors.Main.defaultButton
        
        if transaction == nil{
            
            self.navigationItem.title = NSLocalizedString("Add transaction", comment: "")
            self.navigationItem.rightBarButtonItem = nil
            getExhangeRate()
            if debit == nil && credit == nil {
                switch transactionTypeSegmentedControl.selectedSegmentIndex {
                case 0:
                    print("Expense")
                    debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.expense), context: context)
                    credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
                case 1:
                    print("Income")
                    debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
                    credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.income), context: context)
                case 2:
                    print("Transfer")
                    debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
                    credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
                default:
                    print("Manual")
                    debit = nil
                    credit = nil
                }
            }
            else {
                transactionTypeSegmentedControl.isHidden = true
                transactionTypeSegmentedControl.selectedSegmentIndex = 3
            }
        }
        else {
            fillUIForExistingTransaction()
        }
    }
    
    
    private func configureUI(){
        amountInCreditCurrencyTextField.placeholder = ""
        amountInCreditCurrencyTextField.text = ""
        
        if let credit = credit, let debit = debit {
            if debit.currency == nil
                || (debit.parent == nil
                        && debit != Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.capital), context: context))
                || credit.currency == nil
                || (credit.parent == nil
                        && credit != Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.capital), context: context)) {
                amountInDebitCurrencyTextField.placeholder = ""
                amountInDebitCurrencyTextField.isHidden = false
                amountInDebitCurrencyTextField.text = ""
                amountStackView.isHidden = true
                
                creditToDebitExchangeRateLabel.isHidden = true
                debitToCreditExchangeRateLabel.isHidden = true
                
                useExchangeRateSwich.isHidden = true
                useExchangeRateLabel.isHidden = true
            }
            else if credit.currency == debit.currency {
                amountInDebitCurrencyTextField.placeholder = debit.currency!.code
                amountInCreditCurrencyTextField.isHidden = true
                amountStackView.isHidden = false
                amountInDebitCurrencyTextField.isHidden = false
                creditToDebitExchangeRateLabel.isHidden = true
                debitToCreditExchangeRateLabel.isHidden = true
                useExchangeRateSwich.isHidden = true
                useExchangeRateLabel.isHidden = true
            }
            else {
                amountInCreditCurrencyTextField.placeholder = credit.currency!.code
                amountInDebitCurrencyTextField.placeholder = debit.currency!.code
                amountStackView.isHidden = false
                amountInCreditCurrencyTextField.isHidden = false
                amountInDebitCurrencyTextField.isHidden = false
                creditToDebitExchangeRateLabel.isHidden = false
                debitToCreditExchangeRateLabel.isHidden = false
                amountInDebitCurrencyTextField.text = ""
                useExchangeRateSwich.isHidden = false
                useExchangeRateLabel.isHidden = false
                setExchangeRateToLabel()
            }
        }
        else if debit == nil || credit == nil || debit?.currency == nil || credit?.currency == nil {
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
        setAccountNameToButtons()
    }
    
    
    private func setExchangeRateToLabel() {
        guard let debit = debit, let debitCurrency = debit.currency, let credit = credit, let creditCurrency = credit.currency, debitCurrency != creditCurrency
        else {return}
        
        if useExchangeRateSwich.isOn {
            guard let currencyHistoricalData = currencyHistoricalData, let rate = currencyHistoricalData.exchangeRate(pay: creditCurrency.code, forOne: debitCurrency.code) else {return}
            print(rate)
            selectedRateCreditToDebit = rate
            creditToDebitExchangeRateLabel.text = "\(creditCurrency.code)/\(debitCurrency.code): \(round(rate*10000)/10000)"
            debitToCreditExchangeRateLabel.text = "\(debitCurrency.code)/\(creditCurrency.code): \(round(1.0/rate*10000)/10000)"
        }
        else if let amountInCreditCurrency = Double(amountInCreditCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")),
                let amountInDebitCurrency = Double(amountInDebitCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) {
            selectedRateCreditToDebit = amountInCreditCurrency/amountInDebitCurrency
            creditToDebitExchangeRateLabel.text = "\(creditCurrency.code)/\(debitCurrency.code): \(round(selectedRateCreditToDebit!*10000)/10000)"
            debitToCreditExchangeRateLabel.text = "\(debitCurrency.code)/\(creditCurrency.code): \(round(1.0/selectedRateCreditToDebit!*10000)/10000)"
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
        
        var comment : String?
        if commentTextField.text?.isEmpty == false {
            comment = commentTextField.text
        }
        
        if debit.currency == credit.currency {
            if let amountInDebitCurrency = Double(amountInDebitCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                Transaction.addTransactionWith2TranItems(date: datePicker.date, debit: debit, credit: credit, debitAmount: amountInDebitCurrency, creditAmount: amountInDebitCurrency, comment: comment, context: context)
            }
        }
        else {
            if let amountInDebitCurrency = Double(amountInDebitCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")),
               let amountInCreditCurrency = Double(amountInCreditCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                Transaction.addTransactionWith2TranItems(date: datePicker.date, debit: debit, credit: credit, debitAmount: amountInDebitCurrency, creditAmount: amountInCreditCurrency, comment: comment, context: context)
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
    
    
    @objc func selectDebitAccount() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableViewController) as! AccountNavigatorTableViewController
        vc.simpleTransactionEditorVC = self
        vc.showHiddenAccounts = false
        vc.searchBarIsHidden = false
        vc.typeOfAccountingMethod = .debit
        vc.isUserHasPaidAccess = isUserHasPaidAccess
        if let debit = debit, transactionTypeSegmentedControl.selectedSegmentIndex != 3 {
            vc.account = debit.rootAccount
        }
        doneButtonAction()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectCreditAccount() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableViewController) as! AccountNavigatorTableViewController
        vc.simpleTransactionEditorVC = self
        vc.showHiddenAccounts = false
        vc.searchBarIsHidden = false
        vc.typeOfAccountingMethod = .credit
        vc.isUserHasPaidAccess = isUserHasPaidAccess
        if let credit = credit, transactionTypeSegmentedControl.selectedSegmentIndex != 3 {
            vc.account = credit.rootAccount
        }
        doneButtonAction()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func fillUIForExistingTransaction() {
        transactionTypeSegmentedControl.isHidden = true
        transactionTypeSegmentedControl.selectedSegmentIndex = 3
        
        guard let transaction = transaction,
              let date = transaction.date,
              let items = transaction.items?.allObjects as? [TransactionItem]
        else {return}
        
        var debitAcc: Account?
        var creditAcc: Account?
        var debitAmnt: Double?
        var creditAmnt: Double?
        
        for item in items {
            if item.type == AccountingMethod.debit.rawValue {
                debitAcc = item.account
                debitAmnt = item.amount
            }
            else if item.type == AccountingMethod.credit.rawValue {
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
            
            creditToDebitExchangeRateLabel.text = "\(creditAccount.currency!.code)/\(debitAccount.currency!.code): \(round(creditAmount/debitAmount*10000)/10000)"
            debitToCreditExchangeRateLabel.text = "\(debitAccount.currency!.code)/\(creditAccount.currency!.code): \(round(debitAmount/creditAmount*10000)/10000)"
        }
        else {
            amountInDebitCurrencyTextField.text = "\(debitAmount)"
        }
        
        if let comment = transaction.comment {
            self.commentTextField.text = comment
        }
    }
    
    
    private func validation() -> Bool {
        if credit?.parent == nil
            && credit?.name != AccountsNameLocalisationManager.getLocalizedAccountName(.capital) {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please select \"From:\" account/category", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if debit?.parent == nil
                    && debit?.name != AccountsNameLocalisationManager.getLocalizedAccountName(.capital) {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please select \"To:\" account/category", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if debit != nil && credit != nil && debit!.currency == credit!.currency &&  Double(amountInDebitCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil  {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please check the amount value", comment: ""), preferredStyle: .alert)
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
        else if Double(amountInDebitCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Please check the \"To:\" amount value", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    
    // MARK: - Keyboard methods
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 40), right: 0.0)
        self.mainScrollView.contentInset = contentInsets
        self.mainScrollView.scrollIndicatorInsets = contentInsets
        
        
        // **-- Scroll when keyboard shows up
        let aRect           = self.view.frame
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
        
        amountInDebitCurrencyTextField.inputAccessoryView = doneToolbar
        amountInCreditCurrencyTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        amountInDebitCurrencyTextField.resignFirstResponder()
        amountInCreditCurrencyTextField.resignFirstResponder()
        commentTextField.resignFirstResponder()
    }
}
