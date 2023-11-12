//
//  TransactionItemCell.swift
//  Accountant
//
//  Created by Roman Topchii on 19.08.2021.
//

import UIKit
import CoreData

class TransactionItemCell: UITableViewCell {
    
    private var transactionItem: TransactionItemSimpleViewModel!
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

    private let amountInAccountingCurrencyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Amount in",
                                                  tableName: Constants.Localizable.mITransactionEditor,
                                                  comment: "")
        textField.keyboardType = .decimalPad
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = 2
        return textField
    }()

    func configureCell(for transactionItem: TransactionItemSimpleViewModel, with delegate: TransactionItemCellDelegate,
                       accountingCurrencyCode: String, isUserInteractionEnabled: Bool) {

        accountButton.isUserInteractionEnabled = isUserInteractionEnabled
        amountTextField.isUserInteractionEnabled = isUserInteractionEnabled
        amountInAccountingCurrencyTextField.isUserInteractionEnabled = isUserInteractionEnabled

        self.transactionItem = transactionItem
        self.delegate = delegate
        amountTextField.delegate = self
        amountInAccountingCurrencyTextField.delegate = self
        addDoneButtonOnDecimalKeyboard()

        accountButton.setTitle(transactionItem.path, for: .normal)
        amountTextField.text = (transactionItem.amount == 0) ? "" : String(transactionItem.amount)
        amountTextField.placeholder = transactionItem.currency
        amountInAccountingCurrencyTextField.text = (transactionItem.amountInAccountingCurrency == 0)
        ? ""
        : String(transactionItem.amountInAccountingCurrency)
        amountInAccountingCurrencyTextField.placeholder = accountingCurrencyCode

        accountButton.addTarget(self, action: #selector(TransactionItemCell.selectAccount),
                                for: .touchUpInside)

        if transactionItem.isAccountingCurrency {
            contentView.addSubview(amountTextField)
            amountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
            amountTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            amountTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true

            contentView.addSubview(accountButton)
            accountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
            accountButton.trailingAnchor.constraint(equalTo: amountTextField.leadingAnchor, constant: -5).isActive = true
            accountButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        } else {
            contentView.addSubview(amountInAccountingCurrencyTextField)
            amountInAccountingCurrencyTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
            amountInAccountingCurrencyTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            amountInAccountingCurrencyTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true

            contentView.addSubview(amountTextField)
            amountTextField.trailingAnchor.constraint(equalTo: amountInAccountingCurrencyTextField.leadingAnchor, constant: -5).isActive = true
            amountTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            amountTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true

            contentView.addSubview(accountButton)
            accountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
            accountButton.trailingAnchor.constraint(equalTo: amountTextField.leadingAnchor, constant: -5).isActive = true
            accountButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if transactionItem.isAccountingCurrency {
            amountInAccountingCurrencyTextField.text = amountTextField.text
        }

        if let amountText = amountTextField.text,
           let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
           let amountInAccountingCurrencyText = amountInAccountingCurrencyTextField.text,
           let amountInAccountingCurrency = Double(amountInAccountingCurrencyText.replacingOccurrences(of: ",", with: ".")) {

            delegate.setAmount(forTrasactionItem: transactionItem.id,
                               amount: amount,
                               amountInAccountingCurrency: amountInAccountingCurrency)
        } else  if let amountText = amountTextField.text,
                   let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
                   (amountInAccountingCurrencyTextField.text == nil || (
                    amountInAccountingCurrencyTextField.text != nil &&
                    Double(amountInAccountingCurrencyTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil)) {

            delegate.setAmount(forTrasactionItem: transactionItem.id,
                               amount: amount,
                               amountInAccountingCurrency: 0)
        } else  if let amountInAccountingCurrencyText = amountInAccountingCurrencyTextField.text,
                   let amountInAccountingCurrency = Double(amountInAccountingCurrencyText.replacingOccurrences(of: ",", with: ".")),
                    (amountTextField.text == nil || (
                        amountTextField.text != nil &&
                        Double(amountTextField.text!.replacingOccurrences(of: ",", with: ".")) == nil)) {

            delegate.setAmount(forTrasactionItem: transactionItem.id,
                               amount: 0,
                               amountInAccountingCurrency: amountInAccountingCurrency)
        } else {
            delegate.setAmount(forTrasactionItem: transactionItem.id, amount: 0, amountInAccountingCurrency: 0)
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
