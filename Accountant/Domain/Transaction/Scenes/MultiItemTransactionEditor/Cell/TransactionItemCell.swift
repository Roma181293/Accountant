//
//  TransactionItemCell.swift
//  Accountant
//
//  Created by Roman Topchii on 19.08.2021.
//

import UIKit
import CoreData

class TransactionItemCell: UITableViewCell {

    var transactionItem: TransactionItemSimpleViewModel!
    private unowned var delegate: TransactionItemCellDelegate!

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
                                                  tableName: Constants.Localizable.mITransactionEditor,
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

    func configureCell(for transactionItem: TransactionItemSimpleViewModel, with delegate: TransactionItemCellDelegate) {
        self.transactionItem = transactionItem
        self.delegate = delegate
        amountTextField.delegate = self
        addDoneButtonOnDecimalKeyboard()

        accountButton.setTitle(transactionItem.path, for: .normal)
        amountTextField.text = (transactionItem.amount == 0) ? "" : String(transactionItem.amount)

        accountButton.addTarget(self, action: #selector(TransactionItemCell.selectAccount),
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1, let text = textField.text,
           let amount = Double(text.replacingOccurrences(of: ",", with: ".")) {
            delegate.setAmount(forTrasactionItem: transactionItem.id, amount: amount)
        }
    }

    @objc private func selectAccount() {
        delegate.accountRequestingForTransactionItem(id: transactionItem.id)
    }

    private func addDoneButtonOnDecimalKeyboard() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let title = NSLocalizedString("Done",
                                      tableName: Constants.Localizable.mITransactionEditor,
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
