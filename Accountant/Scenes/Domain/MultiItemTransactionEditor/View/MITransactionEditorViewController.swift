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

    private var isUserInteractionEnabled: Bool = true

    override func loadView() {
        view = mainView
        mainView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.title = output?.isNewTransaction == true
        ? NSLocalizedString("Add transaction",
                            tableName: Constants.Localizable.mITransactionEditor,
                            comment: "")
        : NSLocalizedString("Edit transaction",
                            tableName: Constants.Localizable.mITransactionEditor,
                            comment: "")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save",
                                                                                          tableName: Constants.Localizable.mITransactionEditor,
                                                                                          comment: ""),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.confirm))

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

    @objc func confirm() {
        output?.confirm()
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
                                forCellReuseIdentifier: Constants.Cell.transactionItemCell)
        mainView.creditTableView.register(TransactionItemCell.self,
                                 forCellReuseIdentifier: Constants.Cell.transactionItemCell)

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

    func setMinDate(_ date: Date?) {
        mainView.datePicker.minimumDate = date
    }

    func setComment(_ comment: String?) {
        mainView.commentTextField.text = comment
    }

    func disableUserInteractionForUI() {
        isUserInteractionEnabled = false
        self.navigationItem.title = NSLocalizedString("View transaction",
                                                      tableName: Constants.Localizable.mITransactionEditor,
                                                      comment: "")

        mainView.datePicker.isUserInteractionEnabled = isUserInteractionEnabled
        mainView.commentTextField.isUserInteractionEnabled = isUserInteractionEnabled
        mainView.debitAddButton.isHidden = true
        mainView.creditAddButton.isHidden = true
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
}

// MARK: - TransactionItemDelegate
extension MITransactionEditorViewController: TransactionItemCellDelegate {
    func accountRequestingForTransactionItem(id: UUID) {

        output?.accountRequestingForTransactionItem(id: id)
    }

    func setAmount(forTrasactionItem id: UUID, amount: Double, amountInAccountingCurrency: Double) {

        output?.setAmount(forTrasactionItem: id, amount: amount, amountInAccountingCurrency: amountInAccountingCurrency)
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
            cell.configureCell(for: output.debitTransactionItems[indexPath.row],
                               with: self,
                               accountingCurrencyCode: output.accountingCurrencyCode,
                               isUserInteractionEnabled: isUserInteractionEnabled)
        case mainView.creditTableView:
            cell.configureCell(for: output.creditTransactionItems[indexPath.row],
                               with: self,
                               accountingCurrencyCode: output.accountingCurrencyCode,
                               isUserInteractionEnabled: isUserInteractionEnabled)
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
        guard let userInfo = notification.userInfo,
        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {return}

        let keyboardViewEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardViewEndFrame.height, right: 0.0)

        mainView.scrollContent(contentInset: contentInsets)
    }

    @objc func keyboardWillHide(notification: Notification) {
        mainView.scrollContent(contentInset: UIEdgeInsets.zero)
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
