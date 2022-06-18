//
//  AccountEditorView.swift
//  Accountant
//
//  Created by Roman Topchii on 26.04.2022.
//

import UIKit

class AccountEditorView1: UIView { // swiftlint:disable:this type_body_length

    unowned var controller: AccountEditorViewController1

    let mainScrollView: UIScrollView = {
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

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let consolidatedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let leadingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let trailingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let accountSubTypeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Type", tableName: Constants.Localizable.accountEditorVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let accountSubTypeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Currency", tableName: Constants.Localizable.accountEditorVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let currencyButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let dateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let balanceOnDateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Balance on", tableName: Constants.Localizable.accountEditorVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Name", tableName: Constants.Localizable.accountEditorVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let keeperLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Keeper", tableName: Constants.Localizable.accountEditorVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let keeperButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let holderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Holder", tableName: Constants.Localizable.accountEditorVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let holderButton: UIButton = {
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
        textField.placeholder = NSLocalizedString("Example: John BankName salary", tableName: Constants.Localizable.accountEditorVC, comment: "")
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

    private let creditLimitLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Credit limit", tableName: Constants.Localizable.accountEditorVC, comment: "")
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

    private let exchangeRateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let exchangeRateLabel: UILabel = {
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

    private var confirmButton: UIButton = {
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

    var rate: Double? {
       return Double(exchangeRateTextField.text!.replacingOccurrences(of: ",", with: "."))
    }

    var balance: Double? {
        return Double(accountBalanceTextField.text!.replacingOccurrences(of: ",", with: "."))
    }

    var creditLimit: Double? {
        return Double(creditLimitTextField.text!.replacingOccurrences(of: ",", with: "."))
    }

    var name: String {
        return accountNameTextField.text ?? ""
    }

    var date: Date {
        datePicker.date
    }

    required init(controller: AccountEditorViewController1) {
        self.controller = controller
        super.init(frame: CGRect.zero)
        addTargets()
        addDelegates()
        addUIConponents()
        addDoneButtonOnDecimalKeyboard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addTargets() {
        confirmButton.addTarget(controller, action: #selector(controller.confirmCreation(_:)), for: .touchUpInside)
        currencyButton.addTarget(controller, action: #selector(controller.selectCurrency), for: .touchUpInside)
        keeperButton.addTarget(controller, action: #selector(controller.selectkeeper), for: .touchUpInside)
        holderButton.addTarget(controller, action: #selector(controller.selectHolder), for: .touchUpInside)
        accountSubTypeButton.addTarget(controller,
                                       action: #selector(controller.changeAccountSubType),
                                       for: .touchUpInside)
        accountNameTextField.addTarget(controller, action: #selector(controller.checkName(_:)), for: .editingChanged)
    }

    private func addDelegates() {
        accountNameTextField.delegate = controller
        accountBalanceTextField.delegate = controller
        creditLimitTextField.delegate = controller
        exchangeRateTextField.delegate = controller

        mainScrollView.delegate = controller
    }

    private func addUIConponents() {

        controller.view.backgroundColor = .systemBackground

        // Main Scroll View
        controller.view.addSubview(mainScrollView)
        mainScrollView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
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
        controller.view.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor, constant: -89).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor, constant: -40).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
    }

    func configureUIForNewAccount() {
        guard controller.account == nil else {return}
        if controller.parentAccount == controller.moneyRoot {
            keeperLabel.text = NSLocalizedString("Bank", tableName: Constants.Localizable.accountEditorVC, comment: "")
            accountSubTypeButton.isHidden = false
            accountSubTypeLabel.isHidden = false
        } else if controller.parentAccount == controller.debtorsRoot {
            keeperLabel.text = NSLocalizedString("Borrower",
                                                 tableName: Constants.Localizable.accountEditorVC,
                                                 comment: "")
            accountSubTypeButton.isHidden = true
            accountSubTypeLabel.isHidden = true
        } else if controller.parentAccount == controller.creditsRoot {
            keeperLabel.text = NSLocalizedString("Creditor",
                                                 tableName: Constants.Localizable.accountEditorVC,
                                                 comment: "")
            accountSubTypeButton.isHidden = true
            accountSubTypeLabel.isHidden = true
        } else {
            accountSubTypeButton.isHidden = true
            accountSubTypeLabel.isHidden = true
        }

        setKeeper()
        setHolder()
        setAccountSubType()
        setCurrency()
    }

    func configureUIForEditAccount() {
        guard let account = controller.account else {return}
        accountNameTextField.text = account.name

//        if controller.accountSubType == .cash {
//            keeperButton.isHidden = true
//            keeperLabel.isHidden = true
//        }

        setKeeper()
        setHolder()

        if controller.parentAccount == controller.moneyRoot {
            keeperLabel.text = NSLocalizedString("Bank",
                                                 tableName: Constants.Localizable.accountEditorVC,
                                                 comment: "")
        } else if controller.parentAccount == controller.debtorsRoot {
            keeperLabel.text = NSLocalizedString("Borrower",
                                                 tableName: Constants.Localizable.accountEditorVC,
                                                 comment: "")
        } else if controller.parentAccount == controller.creditsRoot {
            keeperLabel.text = NSLocalizedString("Creditor",
                                                 tableName: Constants.Localizable.accountEditorVC,
                                                 comment: "")
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

    func setAccountSubType() {

        creditLimitLabel.isHidden = true
        creditLimitTextField.isHidden = true

//        guard let accountSubType = controller.accountSubType else {return}
//        switch accountSubType {
//        case .debitCard:
//            accountSubTypeButton.setImage(UIImage(systemName: "creditcard"), for: .normal)
//            accountSubTypeButton.setTitle("Debit", for: .normal)
//            keeperLabel.isHidden = false
//            keeperButton.isHidden = false
//            creditLimitLabel.isHidden = true
//            creditLimitTextField.isHidden = true
//        case .cash:
//            accountSubTypeButton.setImage(UIImage(systemName: "keepernote"), for: .normal)
//            accountSubTypeButton.setTitle("Cash", for: .normal)
//            keeperLabel.isHidden = true
//            keeperButton.isHidden = true
//            creditLimitLabel.isHidden = true
//            creditLimitTextField.isHidden = true
//        case .creditCard:
//            accountSubTypeButton.setImage(UIImage(systemName: "creditcard.fill"), for: .normal)
//            accountSubTypeButton.setTitle("Credit", for: .normal)
//            keeperLabel.isHidden = false
//            keeperButton.isHidden = false
//            creditLimitLabel.isHidden = false
//            creditLimitTextField.isHidden = false
//        default:
//            break
//        }
    }

    func setCurrency() {
        currencyButton.setTitle(controller.currency.code, for: .normal)
        if controller.currency == controller.accountingCurrency {
            exchangeRateLabel.isHidden = true
            exchangeRateTextField.isHidden = true
            exchangeRateLabel.text = ""
            exchangeRateTextField.text = ""
        } else {
            exchangeRateLabel.isHidden = false
            exchangeRateTextField.isHidden = false
            exchangeRateLabel.text = NSLocalizedString("Exchange rate", tableName: Constants.Localizable.accountEditorVC, comment: "") + " \(controller.accountingCurrency.code)/\(controller.currency.code)" // swiftlint:disable:this line_length
        }
    }

    func setHolder() {
        if let holder = controller.holder {
            holderButton.setTitle(holder.icon + "-" + holder.name, for: .normal)
        } else {
            holderButton.setTitle("", for: .normal)
        }
    }

    func setKeeper() {
        if let keeper = controller.keeper {
            keeperButton.setTitle(keeper.name, for: .normal)
        } else {
            keeperButton.setTitle("", for: .normal)
        }
    }

    func setNameBackgroundColor() {
        if controller.isFreeNewAccountName {
            accountNameTextField.backgroundColor = .systemBackground
        } else {
            accountNameTextField.backgroundColor = UIColor(red: 255/255, green: 179/255, blue: 195/255, alpha: 1)
        }
    }

    private func addDoneButtonOnDecimalKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0,
                                                                  width: UIScreen.main.bounds.width,
                                                                  height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: NSLocalizedString("Done",
                                                            tableName: Constants.Localizable.accountEditorVC,
                                                            comment: ""),
                                   style: .done, target: controller,
                                   action: #selector(controller.doneButtonAction))
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        accountNameTextField.inputAccessoryView = doneToolbar
        accountBalanceTextField.inputAccessoryView = doneToolbar
        creditLimitTextField.inputAccessoryView = doneToolbar
        exchangeRateTextField.inputAccessoryView = doneToolbar
    }
}
