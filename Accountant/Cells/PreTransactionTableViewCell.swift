//
//  PreTransactionTableViewCell.swift
//  Accounting
//
//  Created by Roman Topchii on 23.10.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class PreTransactionTableViewCell: UITableViewCell{

    @IBOutlet weak var datePicker : UIDatePicker!
    @IBOutlet weak var debitButton : UIButton!
    @IBOutlet weak var creditButton : UIButton!
    @IBOutlet weak var debitAmountTextField : UITextField!
    @IBOutlet weak var creditAmountTextField : UITextField!
    @IBOutlet weak var memoTextField : UITextField!
    
    var delegate: ImportTransactionViewController!
    var preTransaction : PreTransaction! {
        didSet{
            updateCell()
        }
    }
    
    @IBAction func selectAccount(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AccountNavigatorTVC_ID") as! AccountNavigatorTableViewController
        vc.importTransactionTableViewController = delegate
        vc.preTransactionTableViewCell = self
        if sender.tag == 1 {
            vc.typeOfAccountingMethod = .credit
        }
        else {
            vc.typeOfAccountingMethod = .debit
        }
        delegate?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func editingDidEnd(_ sender: UITextField) {
        if sender.tag == 1 {
            if let amountText = sender.text, let amount = Double(amountText) {
                preTransaction.creditAmount = amount
            }
            else {
                preTransaction.creditAmount = nil
            }
            updateCell()
        }
        else if sender.tag == 2 {
            if let amountText = sender.text, let amount = Double(amountText) {
                preTransaction.debitAmount = amount
            }
            else {
                preTransaction.debitAmount = nil
            }
            updateCell()
        }
        else if sender.tag == 3 {
            if let memo = sender.text,memo != ""  {
                preTransaction.memo = memo
            }
            else {
                preTransaction.memo = nil
            }
        }
    }
    
    @IBAction func editingChangedAmountValue(_ sender: UITextField) {
        if let amountText = sender.text, let _ = Double(amountText) {
            sender.backgroundColor = .green
        }
        else {
            sender.backgroundColor = .red
        }
    }
    
    
    func configureCell(preTransaction: PreTransaction, tableView: ImportTransactionViewController) {
        self.delegate = tableView
        self.preTransaction = preTransaction
        datePicker.preferredDatePickerStyle = .compact
        debitAmountTextField.delegate = self
        creditAmountTextField.delegate = self
        addDoneButtonOnDecimalKeyboard()
    }
    
    
    
    
    private func addDoneButtonOnDecimalKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        debitAmountTextField.inputAccessoryView = doneToolbar
        creditAmountTextField.inputAccessoryView = doneToolbar
        memoTextField.inputAccessoryView = doneToolbar
    }
    
    
    @objc func doneButtonAction(){
        delegate.view.endEditing(true)
    }
    
    func updateCell() {
        if let date = preTransaction.date {
            datePicker.date = date
            datePicker.backgroundColor = .green
        }
        else {
            datePicker.backgroundColor = .red
        }
        
        updateButtons()
        
        if let creditAmount = preTransaction.creditAmount {
            creditAmountTextField.text = String(creditAmount)
            creditAmountTextField.backgroundColor = .green
        }
        else {
            creditAmountTextField.text = ""
            creditAmountTextField.backgroundColor = .red
        }
        if let debitAmount = preTransaction.debitAmount {
            debitAmountTextField.text = String(debitAmount)
            debitAmountTextField.backgroundColor = .green
        }
        else {
            debitAmountTextField.text = ""
            debitAmountTextField.backgroundColor = .red
        }
        if let memo = preTransaction.memo {
            memoTextField.text = memo
            memoTextField.backgroundColor = .green
        }
        
    }
    
    
    func updateButtons() {
        if let credit = preTransaction.credit {
            creditButton.setTitle(credit.path!, for: .normal)
            creditButton.backgroundColor = .green
        }
        else {
            creditButton.setTitle("Select account", for: .normal)
            creditButton.backgroundColor = .red
        }
        if let debit = preTransaction.debit {
            debitButton.setTitle(debit.path!, for: .normal)
            debitButton.backgroundColor = .green
        }
        else {
            debitButton.setTitle("Select account", for: .normal)
            debitButton.backgroundColor = .red
        }
        if let memo = preTransaction.memo {
            memoTextField.text = memo
        }
        else {
            memoTextField.text = ""
        }
//        delegate.isReadyToImport
    }
    
    
}
