//
//  AccountNavigatorTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 22.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData

class AccountNavigatorTableViewController: UITableViewController {
    
    var resultSearchController = UISearchController()
    var isSwipeAvailable: Bool = true
    
    weak var transactionEditorVC : TransactionEditorViewController?
//    weak var budgetEditorVC : BudgetEditorViewController?
    var preTransactionTableViewCell : PreTransactionTableViewCell?
    var importTransactionTableViewController : ImportTransactionViewController?
    weak var account : Account?
    
    var typeOfAccountingMethod : AccounttingMethod?
    
    let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    lazy var fetchedResultsController : NSFetchedResultsController<Account> = {
        let fetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: "Account")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "path", ascending: true)]
        
        guard let account = account else {
            self.navigationController?.title = NSLocalizedString("Accounts", comment: "")
            self.navigationItem.title = NSLocalizedString("Accounts", comment: "")
            fetchRequest.predicate = NSPredicate(format: "parent = nil && isHidden = false")
            return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        }
        self.navigationItem.title = "\(account.name!)"
        fetchRequest.predicate = NSPredicate(format: "parent.path = %@ && isHidden = false", account.path!)
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.obscuresBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        resultSearchController.dismiss(animated: true, completion: nil)
    }
    
    
    func fetchData() {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        }
        catch {
            errorHandlerMethod(error: error)
        }
    }
    
    
    //MARK: - @IBActions
    
    @IBAction func addAction() {
        guard let account = self.account else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "AddAccountVC_ID") as! AddAccountViewController
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let accountType = account.type

        if let accountCurrency = account.currency {
            let alert = UIAlertController(title: NSLocalizedString("Add account",comment: ""), message: NSLocalizedString("Enter account name",comment: ""), preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.tag = 100
                textField.delegate = alert as! UITextFieldDelegate
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Add",comment: ""), style: .default, handler: { [weak alert] (_) in
                
                do {
                    guard let alert = alert,
                          let textFields = alert.textFields,
                          let textField = textFields.first,
                          AccountManager.isFreeAccountName(parent: account, name: textField.text!, context: self.context)
                    else {throw AccountError.accontWithThisNameAlreadyExists}
                    
                    try AccountManager.createAccount(parent: account, name: textField.text!, type: accountType, currency: accountCurrency, context: self.context)
                    try self.coreDataStack.saveContext(self.context)
                    try self.fetchedResultsController.performFetch()
                    self.tableView.reloadData()
                }
                catch let error{
                    print("Error",error)
                    self.errorHandlerMethod(error: error)
                }
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let transactionEditorVC = storyBoard.instantiateViewController(withIdentifier: "AccountEditorWithInitialBalanceVC_ID") as! AccountEditorWithInitialBalanceViewController
            transactionEditorVC.parentAccount = account
            transactionEditorVC.delegate = self
            self.navigationController?.pushViewController(transactionEditorVC, animated: true)
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountNavigatorCell_ID", for: indexPath)
        let account  = fetchedResultsController.object(at: indexPath) as Account
        
        if let children = account.children, (children.allObjects as! [Account]).filter({$0.isHidden == false}).count > 0 {
            cell.accessoryType = .disclosureIndicator
        }
        else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.text = account.name
        
        if let parent = account.parent, parent.currency == nil {
            cell.detailTextLabel?.text = "\(round(AccountManager.balanceForDateLessThenSelected(date: Date(), accounts: [account])*100)/100) \(account.currency!.code!)"
        }
        else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedAccount = fetchedResultsController.object(at: indexPath) as Account
        
        if let children = selectedAccount.children, (children.allObjects as! [Account]).filter({$0.isHidden == false}).count > 0 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "AccountNavigatorTVC_ID") as! AccountNavigatorTableViewController
            vc.account = selectedAccount
            vc.transactionEditorVC = transactionEditorVC
//            vc.budgetEditorVC = budgetEditorVC
            vc.preTransactionTableViewCell = preTransactionTableViewCell
            vc.importTransactionTableViewController = importTransactionTableViewController
            vc.typeOfAccountingMethod = typeOfAccountingMethod
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            if let addTransactionVC = transactionEditorVC {
                if typeOfAccountingMethod == .debit {
                    addTransactionVC.debit = selectedAccount
                }
                else if typeOfAccountingMethod == .credit {
                    addTransactionVC.credit = selectedAccount
                }
                self.navigationController?.popToViewController(addTransactionVC, animated: true)
            }
            if let preTransactionTableViewCell = preTransactionTableViewCell, let importTransactionTableViewController = importTransactionTableViewController {
                if typeOfAccountingMethod == .debit {
                    preTransactionTableViewCell.preTransaction?.debit = selectedAccount
                    preTransactionTableViewCell.updateButtons()                }
                else if typeOfAccountingMethod == .credit {
                    preTransactionTableViewCell.preTransaction?.credit = selectedAccount
                    preTransactionTableViewCell.updateButtons()
                }
                self.navigationController?.popToViewController(importTransactionTableViewController, animated: true)
            }
//            if let budgetEditorViewController = budgetEditorVC {
//                budgetEditorViewController.account = selectedAccount
//                self.navigationController?.popToViewController(budgetEditorViewController, animated: true)
//            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let hideAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Hide",comment: "")) { _, _, complete in
            let selectedAccount = self.fetchedResultsController.object(at: indexPath) as Account
            if selectedAccount.parent?.currency == nil {
                if AccountManager.balance(of : [selectedAccount]) == 0 {
                    let alert = UIAlertController(title: NSLocalizedString("Hide",comment: ""), message: NSLocalizedString("Do you really want hide account?",comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .destructive, handler: {(_) in
                        
                        do {
                            AccountManager.changeAccountIsHiddenStatus(selectedAccount)
                            try self.coreDataStack.saveContext(self.context)
                            try self.fetchedResultsController.performFetch()
                        }
                        catch {
                            print(error)
                        }
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: NSLocalizedString("Warning",comment: ""), message: NSLocalizedString("You cannot hide account with money.\n1. Please transfer all your money to any other account.\n2. Hide account",comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                let alert = UIAlertController(title: NSLocalizedString("Hide",comment: ""), message: NSLocalizedString("Do you really want hide account?",comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .destructive, handler: {(_) in
                    
                    do {
                        AccountManager.changeAccountIsHiddenStatus(selectedAccount)
                        try self.coreDataStack.saveContext(self.context)
                        try self.fetchedResultsController.performFetch()
                    }
                    catch let error{
                        print("Error",error)
                        self.errorHandlerMethod(error: error)
                    }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
            complete(true)
        }
        
        
        let removeAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Hide",comment: "")) { _, _, complete in
            let selectedAccount = self.fetchedResultsController.object(at: indexPath) as Account
            
            let accountListUsingInTransactions = AccountManager.accountListUsingInTransactions(account: selectedAccount)
            if accountListUsingInTransactions.isEmpty {
                
                let alert = UIAlertController(title: NSLocalizedString("Remove",comment: ""), message: NSLocalizedString("Do you really want remove account and all clidren accounts?",comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .destructive, handler: {(_) in
                    
                    do {
                        try AccountManager.removeAccount(selectedAccount, context: self.context)
                        try self.coreDataStack.saveContext(self.context)
                        try self.fetchedResultsController.performFetch()
                    }
                    catch let error{
                        print("Error",error)
                        self.errorHandlerMethod(error: error)
                    }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .cancel))
                self.present(alert, animated: true, completion: nil)
                
                
            }
            else {
                
                var accountListString : String = ""
                accountListUsingInTransactions.forEach({
                    accountListString += "\n" + $0.path!
                })
                
                let alert = UIAlertController(title: NSLocalizedString("Warning",comment: ""), message: NSLocalizedString("Please move transactions from accounts below:",comment: "") + accountListString, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            
            
            
            complete(true)
        }
        
        
        
        let rename = UIContextualAction(style: .normal, title: NSLocalizedString("Rename",comment: "")) { (contAct, view, complete) in
            let selectedAccount = self.fetchedResultsController.object(at: indexPath) as Account
            
            let alert = UIAlertController(title: NSLocalizedString("Rename account",comment: ""), message: NSLocalizedString("Enter new account name", comment: ""), preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = selectedAccount.name
                textField.tag = 100
                textField.delegate = alert as! UITextFieldDelegate
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .destructive, handler: { [weak alert] (_) in
                guard let textField = alert?.textFields![0] else {return}
                
                do {
                    try AccountManager.renameAccount(selectedAccount, to: textField.text!, context: self.context)
                    try self.coreDataStack.saveContext(self.context)
                    try self.fetchedResultsController.performFetch()
                    tableView.reloadData()
                }
                catch let error{
                    print("Error",error)
                    self.errorHandlerMethod(error: error)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            
            complete(true)
        }
        
        let addSubCategory = UIContextualAction(style: .normal, title: NSLocalizedString("Add subaccount",comment: "")) { _, _, complete in
            let selectedAccount = self.fetchedResultsController.object(at: indexPath) as Account
            
            if selectedAccount.currency == nil {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let transactionEditorVC = storyBoard.instantiateViewController(withIdentifier: "AccountEditorWithInitialBalanceVC_ID") as! AccountEditorWithInitialBalanceViewController
                transactionEditorVC.parentAccount = selectedAccount
                transactionEditorVC.delegate = self
                self.navigationController?.pushViewController(transactionEditorVC, animated: true)
            }
            else {
                
                let alert = UIAlertController(title: NSLocalizedString("Add subaccount",comment: ""), message: NSLocalizedString("Enter subaccount name",comment: ""), preferredStyle: .alert)
                
                alert.addTextField { (textField) in
                    textField.tag = 100
                    textField.delegate = alert as! UITextFieldDelegate
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("Add",comment: ""), style: .default, handler: { [weak alert] (_) in
                    
                    do {
                        guard let alert = alert,
                              let textFields = alert.textFields,
                              let textField = textFields.first,
                              AccountManager.isFreeAccountName(parent: selectedAccount, name: textField.text!, context: self.context)
                        else {throw AccountError.accontWithThisNameAlreadyExists}
                        
                        if !AccountManager.isFreeFromTransactionItems(account: selectedAccount) {
                            
                            
                            
                            let alert1 = UIAlertController(title: NSLocalizedString("Attention",comment: ""), message:  String(format: NSLocalizedString("Account \"%@\" has transactions. All this thansactions will be automatically moved to new child account \"%@\".",comment: ""), selectedAccount.name!,AccountsNameLocalisationManager.getLocalizedAccountName(.other1)), preferredStyle: .alert)                            
                            alert1.addAction(UIAlertAction(title: NSLocalizedString("Create and Move",comment: ""), style: .default, handler: { [weak alert1] (_) in
                                do {
                                    try AccountManager.createAccount(parent: selectedAccount, name: textField.text!, type: selectedAccount.type, currency: selectedAccount.currency!, context: self.context)
                                    try self.coreDataStack.saveContext(self.context)
                                    try self.fetchedResultsController.performFetch()
                                    self.tableView.reloadData()
                                }
                                catch let error{
                                    print("Error",error)
                                    self.errorHandlerMethod(error: error)
                                }
                                
                            }))
                            
                            alert1.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
                            self.present(alert1, animated: true, completion: nil)
                            
                        }
                        else {
                            
                            try AccountManager.createAccount(parent: selectedAccount, name: textField.text!, type: selectedAccount.type, currency: selectedAccount.currency!, context: self.context)
                            try self.coreDataStack.saveContext(self.context)
                            try self.fetchedResultsController.performFetch()
                            self.tableView.reloadData()
                        }
                    }
                    catch let error{
                        print("Error",error)
                        self.errorHandlerMethod(error: error)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
            complete(true)
        }
        
        let selectedAccount = fetchedResultsController.object(at: indexPath) as Account
        
        rename.backgroundColor = .systemBlue
        hideAction.backgroundColor = .systemGray
        addSubCategory.backgroundColor = .systemGreen
        removeAction.image = UIImage(systemName: "trash")
        rename.image = UIImage(systemName: "pencil")
        hideAction.image = UIImage(systemName: "eye.slash")
        addSubCategory.image = UIImage(systemName: "plus")
        
        if isSwipeAvailable {
            var tmpConfiguration: [UIContextualAction] = []
            
            if let parent = selectedAccount.parent, (
                parent.name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) //can have only one lvl od subAccounts
                    || parent.name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) //can have only one lvl od subAccounts
                    || parent.name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors) //can have only one lvl od subAccounts
                    || selectedAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.other1) //can not have subAccount
                    || selectedAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod) //coz it used in system generated transactions
            )
            //FIXME:  remove this line if it is not affect functionality
            //AccountManager.canBeRenamed(account: selectedAccount),
            
            {
                
            }
            else if selectedAccount.parent == nil
                        && selectedAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.capital) {
                //can not have subAccount, coz it used in system generated transactions
                //TODO:- create method in AccountManager that can get Account:Other if it exist otherwise Account
                
            }
            else {
                tmpConfiguration.append(addSubCategory)
            }
            
           
            if AccountManager.canBeRenamed(account: selectedAccount) {
                tmpConfiguration.append(rename)
                tmpConfiguration.append(removeAction)
            }
            if selectedAccount.parent != nil {
                tmpConfiguration.append(hideAction)
            }
            return UISwipeActionsConfiguration(actions: tmpConfiguration)
        }
        return nil
    }
    
    
    func errorHandlerMethod(error : Error) {
        if let error = error as? AccountError{
            if error == .accontWithThisNameAlreadyExists {
                let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Account with this name already exists. Please try another name.", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            else if error == .reservedAccountName {
                let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("This is reserved account name. Please use another name.",comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            else if error == .accountOrChildrenUsedInTransactionItem {
                let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("This account or at least one of the children account used in transactions.",comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


extension AccountNavigatorTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count != 0 {
            if let account = account {
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "path CONTAINS[c] %@ && name CONTAINS[c] %@ && isHidden = false", argumentArray: [account.path!,searchController.searchBar.text!])
            }
            else {
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@ && isHidden = false", argumentArray: [searchController.searchBar.text!])
            }
            isSwipeAvailable = false
        }
        else {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "parent = %@ && isHidden = false",argumentArray: [account])
            isSwipeAvailable = true
        }
        fetchData()
    }
}

