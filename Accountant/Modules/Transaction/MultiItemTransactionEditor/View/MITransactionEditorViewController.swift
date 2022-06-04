//
//  MITransactionEditorViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 25.05.2022.
//

import UIKit

class MITransactionEditorViewController: UIViewController, AccountNavigationDelegate {

    var output: MITransactionEditorViewOutput?

    private var mainView = MITransactionEditorView()

    private var activeTextField: UITextField?

    override func loadView() {
        view = mainView
        mainView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if output?.isNewTransaction == true {
            self.navigationItem.title = NSLocalizedString("Add transaction",
                                                          tableName: Constants.Localizable.mITransactionEditor,
                                                          comment: "")
        } else {
            self.navigationItem.title = NSLocalizedString("Edit transaction",
                                                          tableName: Constants.Localizable.mITransactionEditor,
                                                          comment: "")
        }

        output?.viewWillAppear()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        dismissKeyboard()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            output?.willMoveToParent()
        }
    }
}

// MARK: - MITransactionEditorViewDelegate
extension MITransactionEditorViewController: MITransactionEditorViewDelegate {

    func changeDate(_ date: Date) {
        output?.setDate(date)
    }

    func debitAddButtonDidClick() {
        output?.addDebitTransactionItem()
    }

    func creditAddButtonDidClick() {
        output?.addCreditTransactionItem()
    }

    func confirm() {
        output?.confirm()
    }
}

// MARK: - MITransactionEditorViewInput
extension MITransactionEditorViewController: MITransactionEditorViewInput {

    var creditAddButtonIsHidden: Bool {
        get {
            return mainView.creditAddButton.isHidden
        }
        set {
            mainView.creditAddButton.isHidden = newValue
        }
    }

    var debitAddButtonIsHidden: Bool {
        get {
            return mainView.debitAddButton.isHidden
        }
        set {
            mainView.debitAddButton.isHidden = newValue
        }
    }

    func configureView() {

        mainView.debitTableView.register(TransactionItemCell.self,
                                forCellReuseIdentifier: Constants.Cell.transactionItemTableViewCell)
        mainView.creditTableView.register(TransactionItemCell.self,
                                 forCellReuseIdentifier: Constants.Cell.transactionItemTableViewCell)

        mainView.debitTableView.delegate = self
        mainView.creditTableView.delegate = self

        mainView.debitTableView.dataSource = self
        mainView.creditTableView.dataSource = self

        mainView.commentTextField.delegate = self

        // add GestureRecognizer to dismiss keyboard by touch on screen
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func reloadData() {
        mainView.debitTableView.reloadData()
        mainView.creditTableView.reloadData()
    }

    func setDate(_ date: Date) {
        mainView.datePicker.date = date
    }

    func setComment(_ comment: String?) {
        mainView.commentTextField.text = comment
    }
}

// MARK: - TransactionItemDelegate
extension MITransactionEditorViewController: TransactionItemCellDelegate {
    func accountRequestingForTransactionItem(id: UUID) {

        output?.accountRequestingForTransactionItem(id: id)
    }

    func setAmount(forTrasactionItem id: UUID, amount: Double) {

        output?.setAmount(forTrasactionItem: id, amount: amount)
    }
}

// MARK: - UITableViewDataSource
extension MITransactionEditorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch tableView {
        case mainView.debitTableView:
            return output?.debitTransactionItems.count ?? 0
        case mainView.creditTableView:
            return output?.creditTransactionItems.count ?? 0
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = TransactionItemCell()
        guard let output = output else { return cell }
        switch tableView {
        case mainView.debitTableView:
            cell.configureCell(for: output.debitTransactionItems[indexPath.row], with: self)
        case mainView.creditTableView:
            cell.configureCell(for: output.creditTransactionItems[indexPath.row], with: self)
        default: break
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MITransactionEditorViewController: UITableViewDelegate {

    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {// swiftlint:disable:this line_length

        guard let output = self.output else {return nil}
        switch tableView {
        case mainView.debitTableView:
            if !output.canBeDeleted(id: output.debitTransactionItems[indexPath.row].id) {
                return nil
            }
        case mainView.creditTableView:
            if !output.canBeDeleted(id: output.creditTransactionItems[indexPath.row].id) {
                return nil
            }
        default: return nil
        }

        let delete = UIContextualAction(style: .normal, title: nil) { (_, _, complete) in
            switch tableView {
            case self.mainView.debitTableView:
                output.deleteTransactionItem(id: output.debitTransactionItems[indexPath.row].id)
            case self.mainView.creditTableView:
                output.deleteTransactionItem(id: output.creditTransactionItems[indexPath.row].id)
            default: return
            }
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Keyboard methods
extension MITransactionEditorViewController {
    @objc func keyboardWillShow(notification: Notification) {

        let saveDistance: CGFloat = 80
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, // swiftlint:disable:this line_length
           let activeTextField = activeTextField {
            let keyboardY = self.view.frame.size.height - keyboardSize.height - saveDistance
            var editingTextFieldY: CGFloat! = 0
            if  activeTextField.tag == 200 {  // comment
                editingTextFieldY = activeTextField.frame.origin.y
            }
            if editingTextFieldY > keyboardY - saveDistance {
                UIView.animate(withDuration: 0.25,
                               delay: 0.00,
                               options: UIView.AnimationOptions.curveEaseIn,
                               animations: {
                    self.view.frame = CGRect(x: 0,
                                             y: -(editingTextFieldY! - (keyboardY - saveDistance)),
                                             width: self.view.bounds.width,
                                             height: self.view.bounds.height)
                }, completion: nil)
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {

        UIView.animate(withDuration: 0.25, delay: 0.00, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }

    @objc func dismissKeyboard() {

        view.endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {

        activeTextField = textField
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        if textField.tag == 200, let comment = textField.text {
            output?.setComment(comment)
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    @objc func doneButtonAction() {
        
        mainView.commentTextField.resignFirstResponder()
    }
}
