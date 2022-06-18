//
//  SimpleTransactionEditorView.swift
//  Accountant
//
//  Created by Roman Topchii on 27.04.2022.
//

import UIKit

class SimpleTransactionEditorView: UIView { // swiftlint:disable:this type_body_length

    private let mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let transactionTypeSegmentedControl: UISegmentedControl = {
        let items = [
            NSLocalizedString("Expense",
                              tableName: Constants.Localizable.simpleTransactionEditorVC,
                              comment: ""),
            NSLocalizedString("Income",
                              tableName: Constants.Localizable.simpleTransactionEditorVC,
                              comment: ""),
            NSLocalizedString("Transfer",
                              tableName: Constants.Localizable.simpleTransactionEditorVC,
                              comment: ""),
            NSLocalizedString("Manual",
                              tableName: Constants.Localizable.simpleTransactionEditorVC,
                              comment: "")]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    private let creditButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.Main.defaultButton
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

    private let debitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.Main.defaultButton
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

    private let commentTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 200
        textField.placeholder = NSLocalizedString("Comment",
                                                  tableName: Constants.Localizable.simpleTransactionEditorVC,
                                                  comment: "")
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

    private let useExchangeRateSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()

    private let useExchangeRateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Use exchange rate",
                                       tableName: Constants.Localizable.simpleTransactionEditorVC,
                                       comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let accountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let amountStackView: UIStackView! = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let exchangeRateControlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let exchangeRateLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let addButton: UIButton = {
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

    unowned var controller: SimpleTransactionEditorViewController

    var debitAmount: Double? {
        return Double(debitAmountTextField.text!.replacingOccurrences(of: ",", with: "."))
    }
    var creditAmount: Double? {
        return Double(creditAmountTextField.text!.replacingOccurrences(of: ",", with: "."))
    }
    var comment: String {
        return commentTextField.text ?? ""
    }
    var useExchangeRate: Bool {
        return useExchangeRateSwitch.isOn
    }
    var transactionDate: Date {
        get {
            return datePicker.date
        }
        set {
            datePicker.date = newValue
        }
    }

    required init(controller: SimpleTransactionEditorViewController) {
        self.controller = controller
        super.init(frame: CGRect.zero)
        addTargets()
        addDelegates()
        addUIComponents()
        addDoneButtonOnDecimalKeyboard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addTargets() {
        addButton.addTarget(controller,
                            action: #selector(controller.done(_:)),
                            for: .touchUpInside)
        transactionTypeSegmentedControl.addTarget(controller,
                                                  action: #selector(controller.setTransactionType(_:)),
                                                  for: .valueChanged)
        datePicker.addTarget(controller,
                             action: #selector(controller.changeDate(_:)),
                             for: .valueChanged)
        debitButton.addTarget(controller,
                              action: #selector(controller.selectDebitAccount),
                              for: .touchUpInside)
        creditButton.addTarget(controller,
                               action: #selector(controller.selectCreditAccount),
                               for: .touchUpInside)
        useExchangeRateSwitch.addTarget(controller, action: #selector(controller.setUseExchangeRate(_:)),
                                       for: .valueChanged)
        debitAmountTextField.addTarget(controller,
                                       action: #selector(controller.editingChangedAmountValue(_:)),
                                       for: .editingChanged)
        creditAmountTextField.addTarget(controller,
                                        action: #selector(controller.editingChangedAmountValue(_:)),
                                        for: .editingChanged)
    }

    private func addDelegates() {
        debitAmountTextField.delegate = controller
        creditAmountTextField.delegate = controller
        commentTextField.delegate = controller
    }

    private func addUIComponents() {
        controller.view.backgroundColor = .systemBackground

        controller.view.addSubview(mainScrollView)
        mainScrollView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        mainScrollView.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 8).isActive = true
        mainView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -8).isActive = true
        mainView.topAnchor.constraint(equalTo: mainScrollView.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor).isActive = true
        mainView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -16).isActive = true
        mainView.heightAnchor.constraint(equalTo: mainScrollView.heightAnchor).isActive = true

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
        exchangeRateControlStackView.addArrangedSubview(useExchangeRateSwitch)
        exchangeRateControlStackView.addArrangedSubview(useExchangeRateLabel)

        mainStackView.addArrangedSubview(exchangeRateLabelsStackView)
        exchangeRateLabelsStackView.addArrangedSubview(crToDebExchRateLabel)
        exchangeRateLabelsStackView.addArrangedSubview(debToCrExchRateLabel)

        mainView.addSubview(addButton)
        addButton.bottomAnchor.constraint(equalTo: mainView.bottomAnchor,
                                          constant: -89).isActive = true
        addButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor,
                                            constant: -40+8).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
    }

    func setAccountNameToButtons() {
        if let credit = controller.credit {
            let title = NSLocalizedString("From:",
                                          tableName: Constants.Localizable.simpleTransactionEditorVC,
                                          comment: "") + " \(credit.path)"
            creditButton.setTitle(title, for: .normal)
        } else {
            creditButton.setTitle(NSLocalizedString("From: Account",
                                                    tableName: Constants.Localizable.simpleTransactionEditorVC,
                                                    comment: ""),
                                  for: .normal)
        }
        if let debit = controller.debit {
            let title = NSLocalizedString("To:",
                                          tableName: Constants.Localizable.simpleTransactionEditorVC,
                                          comment: "") + " \(debit.path)"
            debitButton.setTitle(title, for: .normal)
        } else {
            debitButton.setTitle(NSLocalizedString("To: Account",
                                                   tableName: Constants.Localizable.simpleTransactionEditorVC,
                                                   comment: ""),
                                 for: .normal)
        }
    }

    func configureUI() { // swiftlint:disable:this function_body_length
        creditAmountTextField.placeholder = ""
        creditAmountTextField.text = ""

        if let credit = controller.credit, let debit = controller.debit {
            if debit.currency == nil
                || (controller.debit?.type.isConsolidation == true
                    && controller.debit != AccountHelper.getAccountWithPath(LocalisationManager.getLocalizedName(.capital), context: CoreDataStack.shared.persistentContainer.viewContext)) // swiftlint:disable:this line_length
                || controller.credit?.currency == nil
                || (controller.credit?.type.isConsolidation == true
                    && controller.credit != AccountHelper.getAccountWithPath(LocalisationManager.getLocalizedName(.capital), context: CoreDataStack.shared.persistentContainer.viewContext)) {  // swiftlint:disable:this line_length
                debitAmountTextField.placeholder = ""
                debitAmountTextField.isHidden = false
                debitAmountTextField.text = ""
                amountStackView.isHidden = true

                crToDebExchRateLabel.isHidden = true
                debToCrExchRateLabel.isHidden = true

                useExchangeRateSwitch.isHidden = true
                useExchangeRateLabel.isHidden = true
            } else if controller.credit?.currency == controller.debit?.currency {
                debitAmountTextField.placeholder = debit.currency!.code
                creditAmountTextField.isHidden = true
                amountStackView.isHidden = false
                debitAmountTextField.isHidden = false
                crToDebExchRateLabel.isHidden = true
                debToCrExchRateLabel.isHidden = true
                useExchangeRateSwitch.isHidden = true
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
                useExchangeRateSwitch.isHidden = false
                useExchangeRateLabel.isHidden = false
                setExchangeRateToLabel()
            }
        } else if controller.debit == nil
                    || controller.credit == nil
                    || controller.debit?.currency == nil
                    || controller.credit?.currency == nil {
            amountStackView.isHidden = true
            creditAmountTextField.isHidden = true
            debitAmountTextField.isHidden = true
            crToDebExchRateLabel.isHidden = true
            debToCrExchRateLabel.isHidden = true
            debitAmountTextField.placeholder = ""
            debitAmountTextField.text = ""
            useExchangeRateSwitch.isHidden = true
            useExchangeRateLabel.isHidden = true
        }
        setAccountNameToButtons()
    }

    func setUseExchangeRate(_ useRate: Bool) {
        debToCrExchRateLabel.isHidden = !useRate
        crToDebExchRateLabel.isHidden = !useRate
    }

    func setExchangeRateToLabel() {
        guard let debitCurrency = controller.debit?.currency?.code,
              let creditCurrency = controller.credit?.currency?.code,
              debitCurrency != creditCurrency,
              let rateCreditToDebit = controller.selectedRateCreditToDebit
        else {return}
            crToDebExchRateLabel.text = "\(creditCurrency)/\(debitCurrency): \(round(rateCreditToDebit * 10000)/10000)"
            debToCrExchRateLabel.text = "\(debitCurrency)/\(creditCurrency): \(round(1.0/rateCreditToDebit * 10000)/10000)"
    }

    func fillUIForExistingTransaction() {
        transactionTypeSegmentedControl.isHidden = true
        transactionTypeSegmentedControl.selectedSegmentIndex = 3
        guard let transaction = controller.transaction else {return}

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

        addButton.isHidden = true
        datePicker.date = transaction.date

        if controller.debit?.currency != controller.credit?.currency {
            debitAmountTextField.text = "\(debitAmount)"
            creditAmountTextField.text = "\(creditAmount)"

            useExchangeRateSwitch.isOn = false

            crToDebExchRateLabel.text = "\(creditAccount.currency!.code)/\(debitAccount.currency!.code): \(round(creditAmount/debitAmount*10000)/10000)"  // swiftlint:disable:this line_length
            debToCrExchRateLabel.text = "\(debitAccount.currency!.code)/\(creditAccount.currency!.code): \(round(debitAmount/creditAmount*10000)/10000)"  // swiftlint:disable:this line_length
        } else {
            debitAmountTextField.text = "\(debitAmount)"
        }

        if let comment = transaction.comment {
            commentTextField.text = comment
        }
    }

    private func addDoneButtonOnDecimalKeyboard() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let title = NSLocalizedString("Done",
                                      tableName: Constants.Localizable.simpleTransactionEditorVC,
                                      comment: "")
        let done: UIBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self,
                                                    action: #selector(self.doneButtonAction))
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0,
                                                                  width: UIScreen.main.bounds.width,
                                                                  height: 50))
        doneToolbar.barStyle = .default
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

    func scrollContent(contentInset: UIEdgeInsets) {
        mainScrollView.contentInset = contentInset
        mainScrollView.scrollIndicatorInsets = contentInset
        mainScrollView.contentSize = mainScrollView.frame.size
    }

    func clearExhangeRateData() {
        if useExchangeRate {
            crToDebExchRateLabel.text = ""
            debToCrExchRateLabel.text = ""
        }
    }
}
