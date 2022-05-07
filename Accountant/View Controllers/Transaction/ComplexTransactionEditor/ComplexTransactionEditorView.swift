//
//  ComplexTransactionEditorView.swift
//  Accountant
//
//  Created by Roman Topchii on 03.05.2022.
//

import UIKit

class ComplexTransactionEditorView: UIView {

    private unowned var controller: ComplexTransactionEditorViewController

    private let mainStackViewSpacing: CGFloat = 5

    let mainView: UIView = {
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        return mainView
    }()

    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let debitStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2.0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.systemBlue.cgColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let creditStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2.0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.systemBlue.cgColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let debitTitleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let creditTitleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let debitLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("To:",
                                       tableName: Constants.Localizable.complexTransactionEditorVC,
                                       comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let creditLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("From:",
                                       tableName: Constants.Localizable.complexTransactionEditorVC,
                                       comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let debitAddButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let creditAddButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let debitTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let creditTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 200
        textField.placeholder = NSLocalizedString("Comment",
                                                  tableName: Constants.Localizable.complexTransactionEditorVC,
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

    let confirmButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.backgroundColor = Colors.Main.confirmButton
        button.layer.cornerRadius = 34
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3
        button.layer.masksToBounds =  false
        return button
    }()

    required init(controller: ComplexTransactionEditorViewController) {
        self.controller = controller
        super.init(frame: CGRect.zero)
        addTargets()
        addUIComponents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addTargets() {
        debitAddButton.addTarget(controller,
                                 action: #selector(controller.addDebitTransactionItem(_:)),
                                 for: .touchUpInside)
        creditAddButton.addTarget(controller,
                                  action: #selector(controller.addCreditTransactionItem(_:)),
                                  for: .touchUpInside)
        confirmButton.addTarget(controller,
                                action: #selector(controller.confirm(_:)),
                                for: .touchUpInside)
        datePicker.addTarget(controller,
                             action: #selector(controller.changeDate(_:)),
                             for: .valueChanged)
    }

    private func addUIComponents() {

        controller.view.backgroundColor = .systemBackground

        controller.view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor, constant: 8).isActive = true
        mainView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor, constant: -8).isActive = true
        mainView.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        mainView.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 180).isActive = true

        mainView.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -89).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -40+8).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true

        mainView.addSubview(commentTextField)
        commentTextField.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20).isActive = true
        commentTextField.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        commentTextField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        commentTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true

        mainView.addSubview(mainStackView)
        mainStackView.spacing = mainStackViewSpacing
        mainStackView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: commentTextField.topAnchor, constant: -20).isActive = true

        mainStackView.addArrangedSubview(creditStackView)
        creditStackView.addArrangedSubview(creditTitleView)

        creditTitleView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        creditTitleView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        creditTitleView.addSubview(creditLabel)
        creditLabel.leadingAnchor.constraint(equalTo: creditTitleView.leadingAnchor, constant: 10).isActive = true
        creditLabel.centerYAnchor.constraint(equalTo: creditTitleView.centerYAnchor).isActive = true

        creditTitleView.addSubview(creditAddButton)
        creditAddButton.trailingAnchor.constraint(equalTo: creditTitleView.trailingAnchor).isActive = true
        creditAddButton.centerYAnchor.constraint(equalTo: creditTitleView.centerYAnchor).isActive = true
        creditAddButton.widthAnchor.constraint(equalTo: creditTitleView.heightAnchor).isActive = true
        creditAddButton.heightAnchor.constraint(equalTo: creditTitleView.heightAnchor).isActive = true

        creditStackView.addArrangedSubview(creditTableView)
        creditTableView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        creditTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5,
                                                constant: -30 - mainStackViewSpacing).isActive = true

        mainStackView.addArrangedSubview(debitStackView)
        debitStackView.addArrangedSubview(debitTitleView)

        debitTitleView.widthAnchor.constraint(equalToConstant: mainStackView.frame.width).isActive = true
        debitTitleView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        debitTitleView.addSubview(debitLabel)
        debitLabel.leadingAnchor.constraint(equalTo: debitTitleView.leadingAnchor, constant: 10).isActive = true
        debitLabel.centerYAnchor.constraint(equalTo: debitTitleView.centerYAnchor).isActive = true

        debitTitleView.addSubview(debitAddButton)
        debitAddButton.trailingAnchor.constraint(equalTo: debitTitleView.trailingAnchor).isActive = true
        debitAddButton.centerYAnchor.constraint(equalTo: debitTitleView.centerYAnchor).isActive = true
        debitAddButton.widthAnchor.constraint(equalTo: debitTitleView.heightAnchor).isActive = true
        debitAddButton.heightAnchor.constraint(equalTo: debitTitleView.heightAnchor).isActive = true

        debitStackView.addArrangedSubview(debitTableView)
        debitTableView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        debitTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5,
                                               constant: -30 - mainStackViewSpacing).isActive = true
    }
}
