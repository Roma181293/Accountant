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
    var isNewTransaction: Bool = true
    
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
        stackView.spacing = 5.0
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
        textField.translatesAutoresizingMaskIntoConstraints = false
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
            isNewTransaction = false
            self.navigationItem.title = NSLocalizedString("Edit transaction", comment: "")
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(self.confirm(_:)))
        }
        else {
            datePicker.date = Date()
            addEmptyTransaction()
            self.navigationItem.title = NSLocalizedString("Add transaction", comment: "")
        }
        configureAddTransactionItemButtons()
        addMainView() 
    }
    
    deinit {
        context.rollback()
    }
    
    func addMainView() {
        debitTableView.register(TransactionItemTableViewCell.self, forCellReuseIdentifier: TransactionItemTableViewCell.cellId)
        debitTableView.delegate = self
        debitTableView.dataSource = self
        
        creditTableView.register(TransactionItemTableViewCell.self, forCellReuseIdentifier: TransactionItemTableViewCell.cellId)
        creditTableView.delegate = self
        creditTableView.dataSource = self
        
        debitAddButton.addTarget(self, action: #selector(self.addDebitTransactionItem(_:)), for: .touchUpInside)
        creditAddButton.addTarget(self, action: #selector(self.addCreditTransactionItem(_:)), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.confirm(_:)), for: .touchUpInside)
        
        
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
        creditTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5, constant: -30).isActive = true
        
        
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
        debitTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5, constant: -30).isActive = true
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
        context = transaction!.managedObjectContext!
        let transactionItem = TransactionItem(context: context)
        let date = Date()
        transactionItem.createDate = date
        transactionItem.modifyDate = date
        transactionItem.createdByUser = true
        transactionItem.modifiedByUser = true
        transactionItem.amount = 0
        transactionItem.type = type.rawValue
        transactionItem.transaction = transaction
//        transaction?.addToItems(transactionItem)
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
            cell.delegate = self
            cell.configureCell(items.filter({$0.type == AccounttingMethod.debit.rawValue})[indexPath.row])
        case creditTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: TransactionItemTableViewCell.cellId, for: indexPath) as! TransactionItemTableViewCell
            cell.delegate = self
            cell.configureCell(items.filter({$0.type == AccounttingMethod.credit.rawValue})[indexPath.row])
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
