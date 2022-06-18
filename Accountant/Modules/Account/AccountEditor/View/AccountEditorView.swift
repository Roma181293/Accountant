//
//  AccountEditorView.swift
//  Accountant
//
//  Created by Roman Topchii on 08.06.2022.
//  
//

import UIKit

class AccountEditorView: UIView {

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

    let typeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Type", tableName: Constants.Localizable.accountEditorVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let typeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Currency", tableName: Constants.Localizable.accountEditorVC, comment: "")
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
        label.text = NSLocalizedString("Balance on", tableName: Constants.Localizable.accountEditorVC, comment: "")
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
        label.text = NSLocalizedString("Name", tableName: Constants.Localizable.accountEditorVC, comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let keeperLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Keeper", tableName: Constants.Localizable.accountEditorVC, comment: "")
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
        label.text = NSLocalizedString("Holder", tableName: Constants.Localizable.accountEditorVC, comment: "")
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

    let nameTextField: UITextField = {
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

    let balanceTextField: UITextField = {
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

    var date: Date {
        datePicker.date
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .systemBackground

        // Main Scroll View
        addSubview(mainScrollView)
        mainScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
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
        leadingStackView.addArrangedSubview(typeLabel)
        leadingStackView.addArrangedSubview(currencyLabel)
        leadingStackView.addArrangedSubview(holderLabel)
        leadingStackView.addArrangedSubview(keeperLabel)
        leadingStackView.addArrangedSubview(nameLabel)
        currencyLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        typeLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        holderLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        keeperLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        // Trailing Stack View
        consolidatedStackView.addArrangedSubview(trailingStackView)
        trailingStackView.addArrangedSubview(typeButton)
        trailingStackView.addArrangedSubview(currencyButton)
        trailingStackView.addArrangedSubview(holderButton)
        trailingStackView.addArrangedSubview(keeperButton)
        trailingStackView.addArrangedSubview(nameTextField)
        currencyButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        typeButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        holderButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        keeperButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        // Date Stack View
        mainStackView.addArrangedSubview(dateStackView)
        dateStackView.addArrangedSubview(balanceOnDateLabel)
        dateStackView.addArrangedSubview(datePicker)
        mainStackView.setCustomSpacing(8, after: dateStackView)
        // Account Balance Text Field
        mainStackView.addArrangedSubview(balanceTextField)
        balanceTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
        mainStackView.setCustomSpacing(20, after: balanceTextField)
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
        self.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -89).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
