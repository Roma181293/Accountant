//
//  ComplexTransactionEditorViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.08.2021.
//

import UIKit
import CoreData

enum TransactionEditorMode {
    case `default`
    case editDraft // use only for transaction.applied == false
    case editPreDraft  // use only for import transactions
}

class ComplexTransactionEditorViewController: UIViewController {

    private var coreDataStack = CoreDataStack.shared
    private var context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext

    var mode: TransactionEditorMode = .default
    var transaction: Transaction?

    private weak var transactionItemForAccountSpecifying: TransactionItem?
    private var isNewTransaction: Bool = true

    private var activeTextField: UITextField?
    private lazy var mainView: ComplexTransactionEditorView = {return ComplexTransactionEditorView(controller: self)}()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let transaction = transaction {
            mainView.datePicker.date = transaction.date
            mainView.commentTextField.text = transaction.comment
            isNewTransaction = false
            self.navigationItem.title = NSLocalizedString("Edit transaction",
                                                          tableName: Constants.Localizable.complexTransactionEditorVC,
                                                          comment: "")
            if mode == .default {
                let title = NSLocalizedString("Save", tableName: Constants.Localizable.complexTransactionEditorVC,
                                              comment: "")
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self,
                                                                         action: #selector(self.confirm(_:)))
                mainView.confirmButton.isHidden = true
            } else if mode != .default {
                mainView.confirmButton.isHidden = false
            }
        } else {
            mainView.datePicker.date = Date()
            addEmptyTransaction()
            self.navigationItem.title = NSLocalizedString("Add transaction",
                                                          tableName: Constants.Localizable.complexTransactionEditorVC,
                                                          comment: "")
        }

        configureAddTransactionItemButtons()

        // Register cell for TableViews
        mainView.debitTableView.register(TransactionItemTableViewCell.self,
                                forCellReuseIdentifier: Constants.Cell.transactionItemTableViewCell)
        mainView.creditTableView.register(TransactionItemTableViewCell.self,
                                 forCellReuseIdentifier: Constants.Cell.transactionItemTableViewCell)

        // TableViews deledate
        mainView.debitTableView.delegate = self
        mainView.creditTableView.delegate = self

        // TableViews dataSource
        mainView.debitTableView.dataSource = self
        mainView.creditTableView.dataSource = self

        // TextField dataSource
        mainView.commentTextField.delegate = self

        // add GestureRecognizer to dismiss keyboard by touch on screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                            action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
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
            if transaction != nil && context.hasChanges && mode == .default {
                // to avoid transactionItems with no account
                context.rollback()
            }
        }
    }

    deinit {
        if  mode == .default || mode == .editDraft {
            context.rollback()
        } else {
            print("No need to rolling back")
        }
    }

    @objc func changeDate(_ sender: UIDatePicker) {
        transaction?.date = sender.date
    }

    @objc func addDebitTransactionItem(_ sender: UIButton) {
        print(#function)
        addEmptyTransactionItem(type: .debit)
        mainView.debitTableView.reloadData()
        configureAddTransactionItemButtons()
    }

    @objc func addCreditTransactionItem(_ sender: UIButton) {
        print(#function)
        addEmptyTransactionItem(type: .credit)
        mainView.creditTableView.reloadData()
        configureAddTransactionItemButtons()
    }

    private func configureAddTransactionItemButtons() {
        guard let transaction = transaction  else {return}
        if transaction.itemsList.filter({$0.type == .debit}).count > 1 {
            mainView.creditAddButton.isHidden = true
        } else {
            mainView.creditAddButton.isHidden = false
        }
        if transaction.itemsList.filter({$0.type == .credit}).count > 1 {
            mainView.debitAddButton.isHidden = true
        } else {
            mainView.debitAddButton.isHidden = false
        }
    }

    private func addEmptyTransactionItem(type: TransactionItem.TypeEnum) {
        let transactionItem = TransactionItem(context: context)
        let date = Date()
        transactionItem.id = UUID()
        transactionItem.createDate = date
        transactionItem.modifyDate = date
        transactionItem.createdByUser = true
        transactionItem.modifiedByUser = true
        transactionItem.type = type
        if let transaction = transaction, transaction.itemsList.count == 1 {
            transactionItem.amount = transaction.itemsList.first!.amount
        } else {
            transactionItem.amount = 0
        }
        transactionItem.transaction = transaction
    }

    private func addEmptyTransaction() {
        transaction = Transaction(date: Date(), context: context)
        addEmptyTransactionItem(type: .debit)
        addEmptyTransactionItem(type: .credit)
    }

    @objc func confirm(_ sender: UIButton) {
        dismissKeyboard()
        guard let transaction = transaction else {return}
        if let comment = mainView.commentTextField.text {
            transaction.comment = comment
        }
        do {
            if isNewTransaction {
                try Transaction.validateTransactionDataBeforeSave(transaction)
                try coreDataStack.saveContext(context)
                self.navigationController?.popViewController(animated: true)
            } else if context.hasChanges && mode == .default {
                try Transaction.validateTransactionDataBeforeSave(transaction)
                let saveTitle = NSLocalizedString("Save", tableName: Constants.Localizable.complexTransactionEditorVC,
                                                  comment: "")
                let message = NSLocalizedString("Do you want to save changes?",
                                                tableName: Constants.Localizable.complexTransactionEditorVC,
                                                comment: "")
                let alert = UIAlertController(title: saveTitle,
                                              message: message,
                                              preferredStyle: .alert)
                let yesTitle = NSLocalizedString("Yes", tableName: Constants.Localizable.complexTransactionEditorVC,
                                                 comment: "")
                alert.addAction(UIAlertAction(title: yesTitle,
                                              style: .default, handler: {(_) in
                    do {
                        try self.coreDataStack.saveContext(self.context)
                        self.navigationController?.popViewController(animated: true)
                    } catch let error {
                        self.errorHandler(error: error)
                    }
                }))
                let cancelTitle = NSLocalizedString("Cancel",
                                                    tableName: Constants.Localizable.complexTransactionEditorVC,
                                                    comment: "")
                alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
                self.present(alert, animated: true, completion: nil)
            } else if mode != .default {
                transaction.date = mainView.datePicker.date
                transaction.applied = true
                try Transaction.validateTransactionDataBeforeSave(transaction)
                try self.coreDataStack.saveContext(self.context)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        } catch let error {
            errorHandler(error: error)
        }
    }

    func errorHandler(error: Error) {
        var title = NSLocalizedString("Error",
                                      tableName: Constants.Localizable.complexTransactionEditorVC,
                                      comment: "")
        if error is AppError {
            title = NSLocalizedString("Warning",
                                      tableName: Constants.Localizable.complexTransactionEditorVC,
                                      comment: "")
        }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        let okTitle = NSLocalizedString("OK", tableName: Constants.Localizable.complexTransactionEditorVC, comment: "")
        alert.addAction(UIAlertAction(title: okTitle, style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ComplexTransactionEditorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let transaction = transaction else {return 0}
        var numberOfRows = 0
        switch tableView {
        case mainView.debitTableView:
            numberOfRows = transaction.itemsList.filter({$0.type == .debit}).count
        case mainView.creditTableView:
            numberOfRows = transaction.itemsList.filter({$0.type == .credit}).count
        default: return 0
        }
        return numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = TransactionItemTableViewCell()
        guard let transaction = transaction else {return cell}
        switch tableView {
        case mainView.debitTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.transactionItemTableViewCell, for: indexPath) as! TransactionItemTableViewCell // swiftlint:disable:this force_cast line_length
            cell.configureCell(for: transaction.itemsList.filter({$0.type == .debit})[indexPath.row], with: self)
        case mainView.creditTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.transactionItemTableViewCell, for: indexPath) as! TransactionItemTableViewCell // swiftlint:disable:this force_cast line_length
            cell.configureCell(for: transaction.itemsList.filter({$0.type == .credit})[indexPath.row], with: self)
        default: break
        }
        return cell
    }

    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {// swiftlint:disable:this line_length
        guard let transaction = transaction else {return nil}
        var transactionItemToRemove: TransactionItem?
        var transactionItemsCount: Int = 0
        switch tableView {
        case mainView.debitTableView:
            transactionItemToRemove = transaction.itemsList.filter({$0.type == .debit})[indexPath.row]
            transactionItemsCount = transaction.itemsList.filter({$0.type == .debit}).count
        case mainView.creditTableView:
            transactionItemToRemove = transaction.itemsList.filter({$0.type == .credit})[indexPath.row]
            transactionItemsCount = transaction.itemsList.filter({$0.type == .credit}).count
        default: return nil
        }

        guard transactionItemsCount > 1 else {return nil}
        let deleteTitle = NSLocalizedString("Delete", tableName: Constants.Localizable.complexTransactionEditorVC,
                                            comment: "")
        let delete = UIContextualAction(style: .normal, title: deleteTitle) { (_, _, complete) in
            guard let transactionItemToRemove = transactionItemToRemove else {return}
            transactionItemToRemove.transaction = nil
            transactionItemToRemove.managedObjectContext?.delete(transactionItemToRemove)
            tableView.reloadData()
            self.configureAddTransactionItemButtons()
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")
        let configuration: UISwipeActionsConfiguration? = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }
}

// MARK: - Keyboard methods
extension ComplexTransactionEditorViewController {
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
            if !comment.isEmpty {
                transaction?.comment = comment
            } else {
                transaction?.comment = nil
            }
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

// MARK: - Manage transactionItem
extension ComplexTransactionEditorViewController: AccountRequestor {
    func accountRequestingForTransactionItem(_ transactionItem: TransactionItem) {

        transactionItemForAccountSpecifying = transactionItem

        guard let transaction = transaction else {return}

        weak var rootAccount: Account?

        let filledTranItems = transaction.itemsList.filter({$0.type == transactionItem.type && $0.account != nil})
        if (filledTranItems.count == 1 && filledTranItems[0] != transactionItem)
            || filledTranItems.count > 1 {
            rootAccount = filledTranItems[0].account!.rootAccount
        }

        var usedAccountList: [Account] = []
        for item in transaction.itemsList {
            if let account = item.account {
                usedAccountList.append(account)
            }
        }

        let accountNavVC = AccountNavigationViewController()
        accountNavVC.parentAccount = rootAccount
        accountNavVC.delegate = self
        accountNavVC.showHiddenAccounts = false
        accountNavVC.searchBarIsHidden = false
        accountNavVC.canModifyAccountStructure = false
        accountNavVC.excludeAccountList = usedAccountList
        self.navigationController?.pushViewController(accountNavVC, animated: true)
    }

    func setAccount(_ account: Account) {
        transactionItemForAccountSpecifying?.account = account
        transactionItemForAccountSpecifying?.modifyDate = Date()
        transactionItemForAccountSpecifying?.modifiedByUser = true

        switch transactionItemForAccountSpecifying?.type {
        case .debit: mainView.debitTableView.reloadData()
        case .credit: mainView.creditTableView.reloadData()
        default: return
        }
    }

    func setAmount(for transactionItem: TransactionItem, amount: Double) {
        transactionItem.amount = amount
        transactionItem.modifyDate = Date()
        transactionItem.modifiedByUser = true
    }
}
