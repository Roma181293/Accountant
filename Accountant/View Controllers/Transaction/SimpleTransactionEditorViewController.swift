//  TransactionEditorViewControllerOld.swift
//  Accounting
//
//  Created by Roman Topchii on 15.03.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData
import Purchases

class SimpleTransactionEditorViewController: UIViewController { // swiftlint:disable:this type_body_length

    let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext

    var isUserHasPaidAccess = false

    weak var delegate: UIViewController?
    weak var transaction: Transaction?
    var debit: Account? {
        didSet {
            configureUI()
        }
    }
    var credit: Account? {
        didSet {
            configureUI()
        }
    }

    var currencyHistoricalData: CurrencyHistoricalDataProtocol? {
        didSet {
            setExchangeRateToLabel()
        }
    }
    var selectedRateCreditToDebit: Double?

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

    let transactionTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [NSLocalizedString("Expense", comment: ""),
                                                          NSLocalizedString("Income1", comment: ""),
                                                          NSLocalizedString("Transfer", comment: ""),
                                                          NSLocalizedString("Manual", comment: "")])
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

    let creditAmountTextField: UITextField = {
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

    let debitAmountTextField: UITextField = {
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

    let crToDebExchRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let debToCrExchRateLabel: UILabel = {
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
        transactionTypeSegmentedControl.addTarget(self,
                                                  action: #selector(self.transactionTypeDidChange(_:)),
                                                  for: .valueChanged)
        datePicker.addTarget(self, action: #selector(self.changeDate(_:)), for: .valueChanged)
        debitButton.addTarget(self, action: #selector(self.selectDebitAccount), for: .touchUpInside)
        creditButton.addTarget(self, action: #selector(self.selectCreditAccount), for: .touchUpInside)
        useExchangeRateSwich.addTarget(self, action: #selector(self.isUseExchangeRate(_:)), for: .valueChanged)
        debitAmountTextField.addTarget(self,
                                                 action: #selector(self.editingChangedAmountValue(_:)),
                                                 for: .editingChanged)
        creditAmountTextField.addTarget(self,
                                                  action: #selector(self.editingChangedAmountValue(_:)),
                                                  for: .editingChanged)

        debitAmountTextField.delegate = self
        creditAmountTextField.delegate = self
        commentTextField.delegate = self

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        reloadProAccessData()
        showPreContent()
        initialConfigureUI()
        addDoneButtonOnDecimalKeyboard()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setAccountNameToButtons()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    func setAccountNameToButtons() {
        if let credit = credit {
            creditButton.setTitle("\(NSLocalizedString("From:", comment: "")) \(credit.path)", for: .normal)
        } else {
            creditButton.setTitle(NSLocalizedString("From: Account", comment: ""), for: .normal)
        }
        if let debit = debit {
            debitButton.setTitle("\(NSLocalizedString("To:", comment: "")) \(debit.path)", for: .normal)
        } else {
            debitButton.setTitle(NSLocalizedString("To: Account", comment: ""), for: .normal)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        dismissKeyboard()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
        context.rollback()
    }

    private func addMainView() { // swiftlint:disable:this function_body_length
        // MARK: - Main Scroll View
        view.addSubview(mainScrollView)
        mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        // MARK: - Main View
        mainScrollView.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 10).isActive = true
        mainView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -10).isActive = true
        mainView.topAnchor.constraint(equalTo: mainScrollView.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor).isActive = true
        mainView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -20).isActive = true
        mainView.heightAnchor.constraint(equalTo: mainScrollView.heightAnchor).isActive = true

        // Outert Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 25).isActive = true

        mainStackView.addArrangedSubview(transactionTypeSegmentedControl)
        mainStackView.addArrangedSubview(datePicker)
        mainStackView.addArrangedSubview(accountStackView)
        accountStackView.addArrangedSubview(buttonStackView)
        buttonStackView.addArrangedSubview(creditButton)
        buttonStackView.addArrangedSubview(debitButton)

        accountStackView.addArrangedSubview(amountStackView)
        amountStackView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        amountStackView.addArrangedSubview(creditAmountTextField)
        amountStackView.addArrangedSubview(debitAmountTextField)

        mainStackView.addArrangedSubview(commentTextField)
        commentTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true

        mainStackView.addArrangedSubview(exchangeRateControlStackView)
        exchangeRateControlStackView.addArrangedSubview(useExchangeRateSwich)
        exchangeRateControlStackView.addArrangedSubview(useExchangeRateLabel)

        mainStackView.addArrangedSubview(exchangeRateLabelsStackView)
        exchangeRateLabelsStackView.addArrangedSubview(crToDebExchRateLabel)
        exchangeRateLabelsStackView.addArrangedSubview(debToCrExchRateLabel)

        mainView.addSubview(addButton)
        addButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor,
                                          constant: -89).isActive = true
        addButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor,
                                            constant: -40).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
    }

    @objc func transactionTypeDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Expense")
            debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.expense),
                                               context: context)
            credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money),
                                                context: context)
        case 1:
            print("Income")
            debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money),
                                               context: context)
            credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.income),
                                                context: context)
        case 2:
            print("Transfer")
            debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money),
                                               context: context)
            credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money),
                                                context: context)
        default:
            print("Manual")
            debit = nil
            credit = nil
        }
    }

    @objc func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            } else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
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
            let alert = UIAlertController(title: NSLocalizedString("Save",
                                                                   comment: ""),
                                          message: NSLocalizedString("Do you want to save changes?",
                                                                     comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                                          style: .default,
                                          handler: { [] (_) in
                transaction.delete()
                self.addNewTransaction()
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
        } else if transaction == nil {
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
            if sender.tag == 1 {
                if let amount = Double(sender.text!.replacingOccurrences(of: ",", with: ".")) {
                    debitAmountTextField.text = String(round(amount/selectedRate*100)/100)
                } else {
                    debitAmountTextField.text = ""
                }
            }
            if sender.tag == 2 {
                if let amount = Double(sender.text!.replacingOccurrences(of: ",", with: ".")) {
                    creditAmountTextField.text = String(round(amount*selectedRate*100)/100)
                } else {
                    creditAmountTextField.text = ""
                }
            }
        } else {
            if let creditAmount = Double(creditAmountTextField.text!.replacingOccurrences(of: ",", with: ".")),
               let debitAmount = Double(debitAmountTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                crToDebExchRateLabel.text = "\(creditCurrency.code)/\(debitCurrency.code): \(round(creditAmount/debitAmount*10000)/10000)" // swiftlint:disable:this line_length
                debToCrExchRateLabel.text = "\(debitCurrency.code)/\(creditCurrency.code): \(round(debitAmount/creditAmount*10000)/10000)" // swiftlint:disable:this line_length
            } else {
                crToDebExchRateLabel.text = "\(creditCurrency.code)/\(debitCurrency.code): "
                debToCrExchRateLabel.text = "\(debitCurrency.code)/\(creditCurrency.code): "
            }
        }
    }

    @objc func isUseExchangeRate(_ sender: UISwitch) {
        if sender.isOn {
            debToCrExchRateLabel.isHidden = false
            crToDebExchRateLabel.isHidden = false
            getExhangeRate()
        } else {
            debToCrExchRateLabel.isHidden = true
            crToDebExchRateLabel.isHidden = true
        }
    }

    func showPreContent() {
        if isUserHasPaidAccess == false {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 25), execute: {
                switch UserProfile.whatPreContentShowInView(.transactionEditor) {
                case .add:
                    break
                case .offer:
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let purchaseOfferVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferVC) as? PurchaseOfferViewController else {return} // swiftlint:disable:this line_length
                    self.navigationController?.present(purchaseOfferVC, animated: true, completion: nil)
                default:
                    return
                }
            })
        }
    }

    func initialConfigureUI() {
        debitButton.backgroundColor = Colors.Main.defaultButton
        creditButton.backgroundColor = Colors.Main.defaultButton

        if transaction == nil {
            self.navigationItem.title = NSLocalizedString("Add transaction", comment: "")
            self.navigationItem.rightBarButtonItem = nil
            getExhangeRate()
            if debit == nil && credit == nil {
                switch transactionTypeSegmentedControl.selectedSegmentIndex {
                case 0:
                    print("Expense")
                    debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.expense), // swiftlint:disable:this line_length
                                                       context: context)
                    credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money),
                                                        context: context)
                case 1:
                    print("Income")
                    debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money),
                                                       context: context)
                    credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.income), // swiftlint:disable:this line_length
                                                        context: context)
                case 2:
                    print("Transfer")
                    debit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money),
                                                       context: context)
                    credit = Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money),
                                                        context: context)
                default:
                    print("Manual")
                    debit = nil
                    credit = nil
                }
            } else {
                transactionTypeSegmentedControl.isHidden = true
                transactionTypeSegmentedControl.selectedSegmentIndex = 3
            }
        } else {
            fillUIForExistingTransaction()
        }
    }

    private func configureUI() { // swiftlint:disable:this function_body_length
        creditAmountTextField.placeholder = ""
        creditAmountTextField.text = ""

        if let credit = credit, let debit = debit {
            if debit.currency == nil
                || (debit.parent == nil
                        && debit != Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.capital), context: context)) // swiftlint:disable:this line_length
                || credit.currency == nil
                || (credit.parent == nil
                        && credit != Account.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.capital), context: context)) {  // swiftlint:disable:this line_length
                debitAmountTextField.placeholder = ""
                debitAmountTextField.isHidden = false
                debitAmountTextField.text = ""
                amountStackView.isHidden = true

                crToDebExchRateLabel.isHidden = true
                debToCrExchRateLabel.isHidden = true

                useExchangeRateSwich.isHidden = true
                useExchangeRateLabel.isHidden = true
            } else if credit.currency == debit.currency {
                debitAmountTextField.placeholder = debit.currency!.code
                creditAmountTextField.isHidden = true
                amountStackView.isHidden = false
                debitAmountTextField.isHidden = false
                crToDebExchRateLabel.isHidden = true
                debToCrExchRateLabel.isHidden = true
                useExchangeRateSwich.isHidden = true
                useExchangeRateLabel.isHidden = true
            } else {
                creditAmountTextField.placeholder = credit.currency!.code
                debitAmountTextField.placeholder = debit.currency!.code
                amountStackView.isHidden = false
                creditAmountTextField.isHidden = false
                debitAmountTextField.isHidden = false
                crToDebExchRateLabel.isHidden = false
                debToCrExchRateLabel.isHidden = false
                debitAmountTextField.text = ""
                useExchangeRateSwich.isHidden = false
                useExchangeRateLabel.isHidden = false
                setExchangeRateToLabel()
            }
        } else if debit == nil || credit == nil || debit?.currency == nil || credit?.currency == nil {
            amountStackView.isHidden = true
            creditAmountTextField.isHidden = true
            debitAmountTextField.isHidden = true
            crToDebExchRateLabel.isHidden = true
            debToCrExchRateLabel.isHidden = true
            debitAmountTextField.placeholder = ""
            debitAmountTextField.text = ""
            useExchangeRateSwich.isHidden = true
            useExchangeRateLabel.isHidden = true
        }
        setAccountNameToButtons()
    }

    private func setExchangeRateToLabel() {
        guard let debit = debit,
                let debitCurrency = debit.currency,
                let credit = credit,
                let creditCurrency = credit.currency,
                debitCurrency != creditCurrency
        else {return}

        if useExchangeRateSwich.isOn {
            guard let currencyHistoricalData = currencyHistoricalData,
                    let rate = currencyHistoricalData.exchangeRate(pay: creditCurrency.code, forOne: debitCurrency.code) else {return}  // swiftlint:disable:this line_length
            selectedRateCreditToDebit = rate
            crToDebExchRateLabel.text = "\(creditCurrency.code)/\(debitCurrency.code): \(round(rate*10000)/10000)"
            debToCrExchRateLabel.text = "\(debitCurrency.code)/\(creditCurrency.code): \(round(1.0/rate*10000)/10000)"
        } else if let amountInCreditCurrency = Double(creditAmountTextField.text!.replacingOccurrences(of: ",", with: ".")),  // swiftlint:disable:this line_length
                let amountInDebitCurrency = Double(debitAmountTextField.text!.replacingOccurrences(of: ",", with: ".")) { // swiftlint:disable:this line_length
            selectedRateCreditToDebit = amountInCreditCurrency/amountInDebitCurrency
            crToDebExchRateLabel.text = "\(creditCurrency.code)/\(debitCurrency.code): \(round(selectedRateCreditToDebit!*10000)/10000)"  // swiftlint:disable:this line_length
            debToCrExchRateLabel.text = "\(debitCurrency.code)/\(creditCurrency.code): \(round(1.0/selectedRateCreditToDebit!*10000)/10000)"  // swiftlint:disable:this line_length
        }
    }

    /**
     This method load currencyHistoricalData from the internet
     */
    private func getExhangeRate() {
        if useExchangeRateSwich.isOn {
            crToDebExchRateLabel.text = ""
            debToCrExchRateLabel.text = ""
            selectedRateCreditToDebit = nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let storedCurrencyHistoricalData = UserProfile.getLastExchangeRate(),
            storedCurrencyHistoricalData.exchangeDateStringFormat() == dateFormatter.string(from: datePicker.date) {
            currencyHistoricalData = storedCurrencyHistoricalData
        } else {
            currencyHistoricalData = nil
            NetworkServices.loadCurrency(date: datePicker.date) { (currencyHistoricalData, _) in
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

        var comment: String?
        if commentTextField.text?.isEmpty == false {
            comment = commentTextField.text
        }

        if debit.currency == credit.currency {
            if let debitAmount = Double(debitAmountTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                Transaction.addTransactionWith2TranItems(date: datePicker.date,
                                                         debit: debit,
                                                         credit: credit,
                                                         debitAmount: debitAmount,
                                                         creditAmount: debitAmount,
                                                         comment: comment,
                                                         context: context)
            }
        } else {
            if let debitAmount = Double(debitAmountTextField.text!.replacingOccurrences(of: ",", with: ".")),
               let creditAmount = Double(creditAmountTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                Transaction.addTransactionWith2TranItems(date: datePicker.date,
                                                         debit: debit,
                                                         credit: credit,
                                                         debitAmount: debitAmount,
                                                         creditAmount: creditAmount,
                                                         comment: comment,
                                                         context: context)
            }
        }

        if context.hasChanges {
            do {
                try coreDataStack.saveContext(context)
            } catch let error {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    @objc func selectDebitAccount() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let accNavTVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableVC) as? AccountNavigatorTableViewController else {return}  // swiftlint:disable:this line_length
        accNavTVC.simpleTransactionEditorVC = self
        accNavTVC.showHiddenAccounts = false
        accNavTVC.searchBarIsHidden = false
        accNavTVC.transactionItemType = .debit
        accNavTVC.isUserHasPaidAccess = isUserHasPaidAccess
        if let debit = debit, transactionTypeSegmentedControl.selectedSegmentIndex != 3 {
            accNavTVC.account = debit.rootAccount
        }
        doneButtonAction()
        self.navigationController?.pushViewController(accNavTVC, animated: true)
    }

    @objc func selectCreditAccount() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let accNavTVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableVC) as? AccountNavigatorTableViewController else {return}  // swiftlint:disable:this line_length
        accNavTVC.simpleTransactionEditorVC = self
        accNavTVC.showHiddenAccounts = false
        accNavTVC.searchBarIsHidden = false
        accNavTVC.transactionItemType = .credit
        accNavTVC.isUserHasPaidAccess = isUserHasPaidAccess
        if let credit = credit, transactionTypeSegmentedControl.selectedSegmentIndex != 3 {
            accNavTVC.account = credit.rootAccount
        }
        doneButtonAction()
        self.navigationController?.pushViewController(accNavTVC, animated: true)
    }

    private func fillUIForExistingTransaction() {
        transactionTypeSegmentedControl.isHidden = true
        transactionTypeSegmentedControl.selectedSegmentIndex = 3
        guard let transaction = transaction else {return}

        var debitAcc: Account?
        var creditAcc: Account?
        var debitAmnt: Double?
        var creditAmnt: Double?

        for item in transaction.itemsList {
            if item.type == .debit {
                debitAcc = item.account
                debitAmnt = item.amount
            } else if item.type == .credit {
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

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(done))
        addButton.isHidden = true
        datePicker.date = transaction.date

        debit = debitAccount
        credit = creditAccount

        if debit?.currency != credit?.currency {
            debitAmountTextField.text = "\(debitAmount)"
            creditAmountTextField.text = "\(creditAmount)"

            useExchangeRateSwich.isOn = false

            selectedRateCreditToDebit = creditAmount/debitAmount

            crToDebExchRateLabel.text = "\(creditAccount.currency!.code)/\(debitAccount.currency!.code): \(round(creditAmount/debitAmount*10000)/10000)"  // swiftlint:disable:this line_length
            debToCrExchRateLabel.text = "\(debitAccount.currency!.code)/\(creditAccount.currency!.code): \(round(debitAmount/creditAmount*10000)/10000)"  // swiftlint:disable:this line_length
        } else {
            debitAmountTextField.text = "\(debitAmount)"
        }

        if let comment = transaction.comment {
            self.commentTextField.text = comment
        }
    }

    private func validation() -> Bool {  // swiftlint:disable:this function_body_length
        if credit?.parent == nil
            && credit?.name != AccountsNameLocalisationManager.getLocalizedAccountName(.capital) {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                          message: NSLocalizedString("Please select \"From:\" account/category",
                                                                     comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                          style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        } else if debit?.parent == nil
                    && debit?.name != AccountsNameLocalisationManager.getLocalizedAccountName(.capital) {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                          message: NSLocalizedString("Please select \"To:\" account/category",
                                                                     comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                          style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        } else if debit != nil && credit != nil && debit!.currency == credit!.currency
                    &&  Double(debitAmountTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                          message: NSLocalizedString("Please check the amount value", comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        } else if Double(creditAmountTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil
                    && debit?.currency != credit?.currency {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                          message: NSLocalizedString("Please check the \"From:\" amount value",
                                                                     comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
            return false
        } else if Double(debitAmountTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                          message: NSLocalizedString("Please check the \"To:\" amount value",
                                                                     comment: ""),
                                          preferredStyle: .alert)
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
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil,
                                        action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""),
                                                    style: .done,
                                                    target: self,
                                                    action: #selector(self.doneButtonAction))
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()

        debitAmountTextField.inputAccessoryView = doneToolbar
        creditAmountTextField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        debitAmountTextField.resignFirstResponder()
        creditAmountTextField.resignFirstResponder()
        commentTextField.resignFirstResponder()
    }
}
