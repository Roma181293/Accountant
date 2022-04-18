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

class ComplexTransactionEditorViewController: UIViewController { // swiftlint:disable:this type_body_length

    var coreDataStack = CoreDataStack.shared
    var context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext

    var mode: TransactionEditorMode = .default
    var transaction: Transaction?

    private weak var transactionItemForAccountSpecifying: TransactionItem?
    private var isNewTransaction: Bool = true

    let mainStackViewSpacing: CGFloat = 5
    var activeTextField: UITextField?

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
        label.text = NSLocalizedString("To:", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let creditLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("From:", comment: "")
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
        textField.placeholder = NSLocalizedString("Comment", comment: "")
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

    override func viewDidLoad() {
        super.viewDidLoad()
        if let transaction = transaction {
            datePicker.date = transaction.date
            commentTextField.text = transaction.comment
            isNewTransaction = false
            self.navigationItem.title = NSLocalizedString("Edit transaction", comment: "")
            if mode == .default {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""),
                                                                         style: .done,
                                                                         target: self,
                                                                         action: #selector(self.confirm(_:)))
                confirmButton.isHidden = true
            } else if mode != .default {
                confirmButton.isHidden = false
            }
        } else {
            datePicker.date = Date()
            addEmptyTransaction()
            self.navigationItem.title = NSLocalizedString("Add transaction", comment: "")
        }

        configureAddTransactionItemButtons()

        // Register cell for TableViews
        debitTableView.register(TransactionItemTableViewCell.self,
                                forCellReuseIdentifier: Constants.Cell.transactionItemTableViewCell)
        creditTableView.register(TransactionItemTableViewCell.self,
                                 forCellReuseIdentifier: Constants.Cell.transactionItemTableViewCell)

        // TableViews deledate
        debitTableView.delegate = self
        creditTableView.delegate = self

        // TableViews dataSource
        debitTableView.dataSource = self
        creditTableView.dataSource = self

        // TextField dataSource
        commentTextField.delegate = self

        addDoneButtonOnKeyboard()

        // addTarget to UI elements
        debitAddButton.addTarget(self, action: #selector(self.addDebitTransactionItem(_:)), for: .touchUpInside)
        creditAddButton.addTarget(self, action: #selector(self.addCreditTransactionItem(_:)), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.confirm(_:)), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(self.changeDate(_:)), for: .valueChanged)

        // add GestureRecognizer to dismiss keyboard by touch on screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                            action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        addMainView()
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

    func addMainView() { // swiftlint:disable:this function_body_length
        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        mainView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo:
                                                                view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        mainView.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 180).isActive = true

        view.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -89).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -40).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true

        view.addSubview(commentTextField)
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

    @objc func changeDate(_ sender: UIDatePicker) {
        transaction?.date = sender.date
    }

    @objc func addDebitTransactionItem(_ sender: UIButton) {
        print(#function)
        addEmptyTransactionItem(type: .debit)
        debitTableView.reloadData()
        configureAddTransactionItemButtons()
    }

    @objc func addCreditTransactionItem(_ sender: UIButton) {
        print(#function)
        addEmptyTransactionItem(type: .credit)
        creditTableView.reloadData()
        configureAddTransactionItemButtons()
    }

    private func configureAddTransactionItemButtons() {
        guard let transaction = transaction  else {return}
        if transaction.itemsList.filter({$0.type == .debit}).count > 1 {
            creditAddButton.isHidden = true
        } else {
            creditAddButton.isHidden = false
        }
        if transaction.itemsList.filter({$0.type == .credit}).count > 1 {
            debitAddButton.isHidden = true
        } else {
            debitAddButton.isHidden = false
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
        transaction = Transaction(context: context)
        transaction?.date = Date()
        transaction?.id = UUID()
        let createDate = Date()
        transaction?.createDate = createDate
        transaction?.modifyDate = createDate
        transaction?.createdByUser = true
        transaction?.modifiedByUser = true
        addEmptyTransactionItem(type: .debit)
        addEmptyTransactionItem(type: .credit)
    }

    @objc func confirm(_ sender: UIButton) {
        dismissKeyboard()
        guard let transaction = transaction else {return}
        if let comment = commentTextField.text {
            transaction.comment = comment
        }
        do {
            if isNewTransaction {
                try Transaction.validateTransactionDataBeforeSave(transaction)
                try coreDataStack.saveContext(context)
                self.navigationController?.popViewController(animated: true)
            } else if context.hasChanges && mode == .default {
                try Transaction.validateTransactionDataBeforeSave(transaction)
                let alert = UIAlertController(title: NSLocalizedString("Save", comment: ""),
                                              message: NSLocalizedString("Do you want to save changes?", comment: ""),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                                              style: .default, handler: {(_) in
                    do {
                        try self.coreDataStack.saveContext(self.context)
                        self.navigationController?.popViewController(animated: true)
                    } catch let error {
                        self.errorHandler(error: error)
                    }
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .destructive,
                                              handler: {(_) in
                    self.navigationController?.popViewController(animated: true)
                    self.context.rollback()
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
                self.present(alert, animated: true, completion: nil)
            } else if mode != .default {
                transaction.date = datePicker.date
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
        var title = NSLocalizedString("Error", comment: "")
        if error is AppError {
            title = NSLocalizedString("Warning", comment: "")
        }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ComplexTransactionEditorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let transaction = transaction else {return 0}
        var numberOfRows = 0
        switch tableView {
        case debitTableView:
            numberOfRows = transaction.itemsList.filter({$0.type == .debit}).count
        case creditTableView:
            numberOfRows = transaction.itemsList.filter({$0.type == .credit}).count
        default:
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                          message: NSLocalizedString("Please contact support. Cannot find external table view to count the number of rows", comment: ""), // swiftlint:disable:this line_length
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        return numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = TransactionItemTableViewCell()
        guard let transaction = transaction else {return cell}
        switch tableView {
        case debitTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.transactionItemTableViewCell, for: indexPath) as! TransactionItemTableViewCell // swiftlint:disable:this force_cast line_length
            cell.configureCell(for: transaction.itemsList.filter({$0.type == .debit})[indexPath.row], with: self)
        case creditTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.transactionItemTableViewCell, for: indexPath) as! TransactionItemTableViewCell // swiftlint:disable:this force_cast line_length
            cell.configureCell(for: transaction.itemsList.filter({$0.type == .credit})[indexPath.row], with: self)
        default:
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                          message: NSLocalizedString("Please contact support. Cannot find external table view to add cells", comment: ""), // swiftlint:disable:this line_length
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
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
        case self.debitTableView:
            transactionItemToRemove = transaction.itemsList.filter({$0.type == .debit})[indexPath.row]
            transactionItemsCount = transaction.itemsList.filter({$0.type == .debit}).count
        case self.creditTableView:
            transactionItemToRemove = transaction.itemsList.filter({$0.type == .credit})[indexPath.row]
            transactionItemsCount = transaction.itemsList.filter({$0.type == .credit}).count
        default:
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                          message: NSLocalizedString("Please contact support. Cannot find external table view to delete transaction item", comment: ""), // swiftlint:disable:this line_length
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }

        guard transactionItemsCount > 1 else {return nil}

        let delete = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Delete", comment: "")) { (_, _, complete) in
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
        if textField.tag == 200 {
            transaction?.comment = textField.text
        } else if textField.tag == 1, let transactionItemTextField = textField as? TransactionItemTextField {
            if let amount = Double(transactionItemTextField.text!.replacingOccurrences(of: ",", with: ".")) {
                setAmount(transactionItem: transactionItemTextField.transactionItem!, amount: amount)
            }
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0,
                                                                  y: 0,
                                                                  width: UIScreen.main.bounds.width,
                                                                  height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""),
                                                    style: .done,
                                                    target: self,
                                                    action: #selector(self.doneButtonAction))
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()

        //        commentTextField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        commentTextField.resignFirstResponder()
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

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let accNavTVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableVC) as? AccountNavigatorTableViewController else {return} // swiftlint:disable:this line_length
        accNavTVC.context = self.context
        accNavTVC.showHiddenAccounts = false
        accNavTVC.canModifyAccountStructure = false
        accNavTVC.accountRequestorViewController = self
        accNavTVC.account = rootAccount
        accNavTVC.excludeAccountList = usedAccountList
        self.navigationController?.pushViewController(accNavTVC, animated: true)
    }

    func setAccount(_ account: Account) {
        transactionItemForAccountSpecifying?.account = account
        transactionItemForAccountSpecifying?.modifyDate = Date()
        transactionItemForAccountSpecifying?.modifiedByUser = true

        switch transactionItemForAccountSpecifying?.type {
        case .debit:
            debitTableView.reloadData()
        case .credit:
            creditTableView.reloadData()
        default:
            return
        }
    }

    func setAmount(transactionItem: TransactionItem, amount: Double) {
        transactionItem.amount = amount
        transactionItem.modifyDate = Date()
        transactionItem.modifiedByUser = true
    }
} // swiftlint:disable:this file_length
