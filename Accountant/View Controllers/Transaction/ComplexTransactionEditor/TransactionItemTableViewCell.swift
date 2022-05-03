//
//  TransactionItemTableViewCell.swift
//  Accountant
//
//  Created by Roman Topchii on 19.08.2021.
//

import UIKit
import CoreData

class TransactionItemTableViewCell: UITableViewCell {

    private unowned var transactionItem: TransactionItem!
    private unowned var delegate: ComplexTransactionEditorViewController!

    private let accountButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 243/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()

    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Amount",
                                                  tableName: Constants.Localizable.complexTransactionEditorVC,
                                                  comment: "")
        textField.keyboardType = .decimalPad
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = 1
        return textField
    }()

    func configureCell(for transactionItem: TransactionItem, with delegate: ComplexTransactionEditorViewController) {
        self.transactionItem = transactionItem
        self.delegate = delegate
        amountTextField.delegate = self
        addDoneButtonOnDecimalKeyboard()

        if let account = transactionItem.account {
            accountButton.setTitle(account.path, for: .normal)
        } else {
            accountButton.setTitle(NSLocalizedString("Account/Category",
                                                     tableName: Constants.Localizable.complexTransactionEditorVC,
                                                     comment: ""),
                                   for: .normal)
        }
        if transactionItem.amount > 0 {
            amountTextField.text = String(transactionItem.amount)
        } else {
            amountTextField.text = ""
        }

        accountButton.addTarget(self, action: #selector(TransactionItemTableViewCell.selectAccount),
                                for: .touchUpInside)

        contentView.addSubview(amountTextField)
        amountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
        amountTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        amountTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true

        contentView.addSubview(accountButton)
        accountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        accountButton.trailingAnchor.constraint(equalTo: amountTextField.leadingAnchor, constant: -5).isActive = true
        accountButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1, let text = textField.text,
            let amount = Double(text.replacingOccurrences(of: ",", with: ".")) {
            delegate.setAmount(for: self.transactionItem, amount: amount)
        }
        return true
    }

    @objc private func selectAccount() {
        delegate.accountRequestingForTransactionItem(transactionItem)
    }

    private func addDoneButtonOnDecimalKeyboard() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let title = NSLocalizedString("Done",
                                      tableName: Constants.Localizable.complexTransactionEditorVC,
                                      comment: "")
        let done: UIBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self,
                                                    action: #selector(self.doneButtonAction))
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0,
                                                                  width: UIScreen.main.bounds.width,
                                                                  height: 50))
        doneToolbar.barStyle = .default
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        amountTextField.inputAccessoryView = doneToolbar
    }

    @objc private func doneButtonAction() {
        amountTextField.resignFirstResponder()
    }
}
