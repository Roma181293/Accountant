//
//  TransactionItemTableViewCell.swift
//  Accountant
//
//  Created by Roman Topchii on 19.08.2021.
//

import UIKit
import CoreData

class TransactionItemTableViewCell: UITableViewCell {
    
    unowned var transactionItem: TransactionItem!
    unowned var delegate: ComplexTransactionEditorViewController!
    
    let accountButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 243/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    
    let amountTextField : TransactionItemTextField = {
        let textField = TransactionItemTextField()
        textField.placeholder = NSLocalizedString("Amount", comment: "")
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
        amountTextField.delegate = delegate //as! UITextFieldDelegate
        addDoneButtonOnDecimalKeyboard()
        amountTextField.transactionItem = transactionItem
        
        if let account = transactionItem.account {
            accountButton.setTitle(account.path!, for: .normal)
            amountTextField.text = String(transactionItem.amount)
        }
        else {
            accountButton.setTitle(NSLocalizedString("Account", comment: ""), for: .normal)
            if transactionItem.amount != 0 {
                amountTextField.text = String(transactionItem.amount)
            }
            else {
                amountTextField.text = ""
            }
        }
        addMainView()
    }
    
    
    private func addMainView() {
        //MARK:- Adding Targets
        accountButton.addTarget(self, action: #selector(TransactionItemTableViewCell.selectAccount(_:)), for: .touchUpInside)
        
        //MARK:- Adding constraints
        contentView.addSubview(amountTextField)
        amountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
        amountTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        amountTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        contentView.addSubview(accountButton)
        accountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        accountButton.trailingAnchor.constraint(equalTo: amountTextField.leadingAnchor, constant: -5).isActive = true
        accountButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    
    @objc func selectAccount(_ sender: UIButton) {
        delegate.accountRequestingForTransactionItem(transactionItem)
    }
    
    
    func addDoneButtonOnDecimalKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        amountTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
//        if let amount = Double(amountTextField.text!.replacingOccurrences(of: ",", with: ".")) {
//            delegate.setAmount(transactionItem: transactionItem, amount: amount)
//        }
        amountTextField.resignFirstResponder()
    }
}
