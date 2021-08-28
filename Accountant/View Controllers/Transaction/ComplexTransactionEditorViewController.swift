//
//  ComplexTransactionEditorViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.08.2021.
//

import UIKit
import CoreData

class ComplexTransactionEditorViewController: UIViewController{
    
    var coreDataStack = CoreDataStack.shared
    var context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
    
    var transaction : Transaction?
    private weak var transactionItemForAccountSpecifying: TransactionItem?
    private var isNewTransaction: Bool = true
    
    //UI element declaration
    let mainStackViewSpacing: CGFloat = 5
    var activeTextField : UITextField!
    let mainView : UIView = {
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        return mainView
    }()
    
    let datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    let mainStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let debitStackView : UIStackView = {
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
    
    let creditStackView : UIStackView = {
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
    
    let debitTitleView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let creditTitleView : UIView = {
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
    
    let commentTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Comment", comment: "")
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.tag = 200
        return textField
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 243/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 34
        if let image = UIImage(systemName: "checkmark") {
            button.setImage(image, for: .normal)
        }
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let transaction = transaction {
            datePicker.date = transaction.date!
            commentTextField.text = transaction.comment
            isNewTransaction = false
            self.navigationItem.title = NSLocalizedString("Edit transaction", comment: "")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(self.confirm(_:)))
            confirmButton.isHidden = true
        }
        else {
            datePicker.date = Date()
            addEmptyTransaction()
            self.navigationItem.title = NSLocalizedString("Add transaction", comment: "")
        }
        
        configureAddTransactionItemButtons()
        
        
        //MARK:- Register cell for TableViews
        debitTableView.register(TransactionItemTableViewCell.self, forCellReuseIdentifier: TransactionItemTableViewCell.cellId)
        creditTableView.register(TransactionItemTableViewCell.self, forCellReuseIdentifier: TransactionItemTableViewCell.cellId)
        
        //MARK:- TableViews deledate
        debitTableView.delegate = self
        creditTableView.delegate = self
        
        //MARK:- TableViews dataSource
        debitTableView.dataSource = self
        creditTableView.dataSource = self
        
        //MARK:- TextField dataSource
        commentTextField.delegate = self as! UITextFieldDelegate
        
        addDoneButtonOnKeyboard()
        
        //MARK:- addTarget to UI elements
        debitAddButton.addTarget(self, action: #selector(self.addDebitTransactionItem(_:)), for: .touchUpInside)
        creditAddButton.addTarget(self, action: #selector(self.addCreditTransactionItem(_:)), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.confirm(_:)), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(self.changeDate(_:)), for: .valueChanged)
        
        //MARK:- add GestureRecognizer to dismiss keyboard by touch on screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //MARK:- addMainView
        addMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //MARK:- add keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        dismissKeyboard()
        
        //MARK:- remove keyboard observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            if transaction != nil && context.hasChanges { //to avoid transactionItems with no account
            context.rollback()
            }
        }
    }
    
    deinit {
        context.rollback()
    }
    
    func addMainView() {
        //MARK:- Main View
        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        //MARK:- Date Picker
        mainView.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        //MARK:- Confirm button
        view.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -89).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
        
        //MARK:- Comment Text Field
        view.addSubview(commentTextField)
        commentTextField.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20).isActive = true
        commentTextField.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20).isActive = true
        commentTextField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20).isActive = true
        commentTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        //MARK:- Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.spacing = mainStackViewSpacing
        mainStackView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: commentTextField.topAnchor, constant: -20).isActive = true
        
        
        //MARK:- Credit Stack View -
        mainStackView.addArrangedSubview(creditStackView)
        creditStackView.addArrangedSubview(creditTitleView)
        
        //MARK:- Credit Title View
        creditTitleView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        creditTitleView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        //MARK:- Credit Label
        creditTitleView.addSubview(creditLabel)
        creditLabel.leadingAnchor.constraint(equalTo: creditTitleView.leadingAnchor, constant: 10).isActive = true
        creditLabel.centerYAnchor.constraint(equalTo: creditTitleView.centerYAnchor).isActive = true
        
        //MARK:- Credit Add Button
        creditTitleView.addSubview(creditAddButton)
        creditAddButton.trailingAnchor.constraint(equalTo: creditTitleView.trailingAnchor).isActive = true
        creditAddButton.centerYAnchor.constraint(equalTo: creditTitleView.centerYAnchor).isActive = true
        creditAddButton.widthAnchor.constraint(equalTo: creditTitleView.heightAnchor).isActive = true
        creditAddButton.heightAnchor.constraint(equalTo: creditTitleView.heightAnchor).isActive = true
        
        //MARK:- Credit Table View
        creditStackView.addArrangedSubview(creditTableView)
        creditTableView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        creditTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5, constant: -30 - mainStackViewSpacing).isActive = true
        
        
        //MARK:- Debit Stack View -
        mainStackView.addArrangedSubview(debitStackView)
        debitStackView.addArrangedSubview(debitTitleView)
        
        //MARK:- Debit Title View
        debitTitleView.widthAnchor.constraint(equalToConstant: mainStackView.frame.width).isActive = true
        debitTitleView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        //MARK:- Debit Label
        debitTitleView.addSubview(debitLabel)
        debitLabel.leadingAnchor.constraint(equalTo: debitTitleView.leadingAnchor, constant: 10).isActive = true
        debitLabel.centerYAnchor.constraint(equalTo: debitTitleView.centerYAnchor).isActive = true
        
        //MARK:- Debit Add Button
        debitTitleView.addSubview(debitAddButton)
        debitAddButton.trailingAnchor.constraint(equalTo: debitTitleView.trailingAnchor).isActive = true
        debitAddButton.centerYAnchor.constraint(equalTo: debitTitleView.centerYAnchor).isActive = true
        debitAddButton.widthAnchor.constraint(equalTo: debitTitleView.heightAnchor).isActive = true
        debitAddButton.heightAnchor.constraint(equalTo: debitTitleView.heightAnchor).isActive = true
        
        //MARK:- Debit Table View
        debitStackView.addArrangedSubview(debitTableView)
        debitTableView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        debitTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5, constant: -30 - mainStackViewSpacing).isActive = true
    }
    
    @objc func changeDate(_ sender: UIDatePicker){
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
        guard let transaction = transaction, let items = transaction.items?.allObjects as? [TransactionItem] else {return}
        
        if items.filter({$0.type == AccounttingMethod.debit.rawValue}).count > 1 {
            creditAddButton.isHidden = true
        }
        else {
            creditAddButton.isHidden = false
        }
        if items.filter({$0.type == AccounttingMethod.credit.rawValue}).count > 1 {
            debitAddButton.isHidden = true
        }
        else {
            debitAddButton.isHidden = false
        }
    }
    
    private func addEmptyTransactionItem(type: AccounttingMethod){
        let transactionItem = TransactionItem(context: context)
        let date = Date()
        transactionItem.createDate = date
        transactionItem.modifyDate = date
        transactionItem.createdByUser = true
        transactionItem.modifiedByUser = true
        transactionItem.amount = 0
        transactionItem.type = type.rawValue
        transaction?.addToItems(transactionItem)
    }
    
    private func addEmptyTransaction() {
        transaction = Transaction(context: context)
        transaction?.date = Date()
        let createDate = Date()
        transaction?.createDate = createDate
        transaction?.modifyDate = createDate
        transaction?.createdByUser = true
        transaction?.modifiedByUser = true
        addEmptyTransactionItem(type: .debit)
        addEmptyTransactionItem(type: .credit)
    }
    
    @objc func confirm(_ sender: UIButton) {
        guard let transaction = transaction else {return}
        
        do {
            if isNewTransaction {
                try TransactionManager.validateTransactionDataBeforeSave(transaction)
                try coreDataStack.saveContext(context)
                self.navigationController?.popViewController(animated: true)
            }
            else if context.hasChanges {
                try TransactionManager.validateTransactionDataBeforeSave(transaction)
                let alert = UIAlertController(title: NSLocalizedString("Save changes",comment: ""), message: NSLocalizedString("Do you really want to save changes?", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .default, handler: {(_) in
                    do {
                        try self.coreDataStack.saveContext(self.context)
                        self.navigationController?.popViewController(animated: true)
                    }
                    catch let error{
                        self.errorHandler(error: error)
                    }
                }
                ))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .destructive, handler: {(_) in
                    self.navigationController?.popViewController(animated: true)
                    self.context.rollback()
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        catch let error{
            errorHandler(error: error)
        }
       
    }
    
    func errorHandler(error: Error) {
        var title = NSLocalizedString("Error", comment: "")
        if error is TransactionError{
            title = NSLocalizedString("Warning", comment: "")
        }
        
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ComplexTransactionEditorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let transaction = transaction, let items = transaction.items?.allObjects as? [TransactionItem] else {return 0}
        var numberOfRows = 0
        
        switch tableView {
        case debitTableView:
            numberOfRows = items.filter({$0.type == AccounttingMethod.debit.rawValue}).count
        case creditTableView:
            numberOfRows = items.filter({$0.type == AccounttingMethod.credit.rawValue}).count
        default:
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please contact to support. Can not find external table view to count number of rows", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = TransactionItemTableViewCell()
        guard let transaction = transaction, let items = transaction.items?.allObjects as? [TransactionItem] else {return cell}
        
        switch tableView {
        case debitTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: TransactionItemTableViewCell.cellId, for: indexPath) as! TransactionItemTableViewCell
            cell.configureCell(for: items.filter({$0.type == AccounttingMethod.debit.rawValue})[indexPath.row], with: self)
        case creditTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: TransactionItemTableViewCell.cellId, for: indexPath) as! TransactionItemTableViewCell
            cell.configureCell(for: items.filter({$0.type == AccounttingMethod.credit.rawValue})[indexPath.row], with: self)
        default:
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please contact to support. Can not find external table view to add cells", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        return cell
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let transaction = transaction, let items = transaction.items?.allObjects as? [TransactionItem] else {return nil}
        var transactionItemToRemove: TransactionItem?
        var transactionItemsCount: Int = 0
        switch tableView {
        case self.debitTableView:
            transactionItemToRemove = items.filter({$0.type == AccounttingMethod.debit.rawValue})[indexPath.row]
            transactionItemsCount = items.filter({$0.type == AccounttingMethod.debit.rawValue}).count
        case self.creditTableView:
            transactionItemToRemove = items.filter({$0.type == AccounttingMethod.credit.rawValue})[indexPath.row]
            transactionItemsCount = items.filter({$0.type == AccounttingMethod.credit.rawValue}).count
        default:
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please contact to support. Can not find external table view to remove transaction item", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        
        guard transactionItemsCount > 1 else {return nil}
        
        let delete = UIContextualAction(style: .normal, title: NSLocalizedString("Remove",comment: "")) { (contAct, view, complete) in
            guard let transactionItemToRemove = transactionItemToRemove else {return}
            self.transaction?.removeFromItems(transactionItemToRemove)
            tableView.reloadData()
            self.configureAddTransactionItemButtons()
            complete(true)
        }
        
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")
        
        let configuration : UISwipeActionsConfiguration? = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }
}


// MARK:- Keyboard methods
extension ComplexTransactionEditorViewController{
    
    @objc func keyboardWillShow(notification: Notification) {
        let saveDistance: CGFloat = 80
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, let activeTextField = activeTextField {
            let keyboardY = self.view.frame.size.height - keyboardSize.height - saveDistance
            
            var editingTextFieldY : CGFloat! = 0
            
            if  activeTextField.tag == 200 {  //comment
                editingTextFieldY = activeTextField.frame.origin.y
            }
//            else { //amounts
//                editingTextFieldY = self.outertStackView.frame.origin.y + self.accountStackView.frame.origin.y + self.amountStackView.frame.origin.y + activeTextField.frame.origin.y
//            }
            
            if editingTextFieldY > keyboardY - saveDistance {
                UIView.animate(withDuration: 0.25, delay: 0.00, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.view.frame = CGRect(x: 0, y: -(editingTextFieldY! - (keyboardY - saveDistance)), width: self.view.bounds.width, height: self.view.bounds.height)
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
    
    func textFieldDidBeginEditing(_ textField : UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 200 {
            transaction?.comment = textField.text
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField : UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
//        commentTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        commentTextField.resignFirstResponder()
    }
}


//MARK:- Manage transactionItem
extension ComplexTransactionEditorViewController {
    func accountRequestingForTransactionItem(_ transactionItem: TransactionItem) {

        transactionItemForAccountSpecifying = transactionItem

        guard let transaction = transaction,
              let transactionItems = transaction.items?.allObjects as? [TransactionItem] else {return}

        weak var rootAccount: Account?

        let filledTransactionItems = transactionItems.filter({$0.type == transactionItem.type && $0.account != nil})
        if (filledTransactionItems.count == 1 && filledTransactionItems[0] != transactionItem)
        || filledTransactionItems.count > 1 {
            rootAccount = AccountManager.getRootAccountFor(filledTransactionItems[0].account!)
        }

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableViewController) as! AccountNavigatorTableViewController
        vc.context = self.context
        vc.showHiddenAccounts = false
        vc.complexTransactionEditorVC = self
        vc.account = rootAccount
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func setAccount(_ account:Account) {
        transactionItemForAccountSpecifying?.account = account
        transactionItemForAccountSpecifying?.modifyDate = Date()
        transactionItemForAccountSpecifying?.modifiedByUser = true

        switch transactionItemForAccountSpecifying?.type {
        case AccounttingMethod.debit.rawValue:
            debitTableView.reloadData()
        case AccounttingMethod.credit.rawValue:
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
}
