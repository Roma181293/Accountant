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
    
    let coreDataStack = CoreDataStack.shared
    var context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
    
    var resultSearchController = UISearchController()
    
    var canModifyAccountStructure: Bool = true
    var isSwipeAvailable: Bool = true {
        didSet {
            if isSwipeAvailable  && canModifyAccountStructure{
                let newBackButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.addAccount(sender:)))
                newBackButton.image = UIImage(systemName: "plus")
                self.navigationItem.rightBarButtonItem = newBackButton
            }
            else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    //TRANSPORT VARIABLES
    weak var simpleTransactionEditorVC : SimpleTransactionEditorViewController?
    var typeOfAccountingMethod : AccounttingMethod?
//    weak var budgetEditorVC : BudgetEditorViewController?
    var preTransactionTableViewCell : PreTransactionTableViewCell?
    var importTransactionTableViewController : ImportTransactionViewController?
   
    var accountRequestorViewController: AccountRequestor?
    //TRANSPORT VARIABLES
    
    weak var account : Account?
   
    var showHiddenAccounts = true
    
    lazy var fetchedResultsController : NSFetchedResultsController<Account> = {
        let fetchRequest : NSFetchRequest<Account> = NSFetchRequest<Account>(entityName: "Account")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "path", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "parent = %@ && (isHidden = false || isHidden = %@)", argumentArray: [account, showHiddenAccounts])
            return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isSwipeAvailable = true //need assign to show add button
        
        if let account = account {
            self.navigationItem.title = "\(account.name!)"
        }
        else {
            if showHiddenAccounts {
                self.navigationController?.title = NSLocalizedString("Accounts manager", comment: "")
                self.navigationItem.title = NSLocalizedString("Accounts manager", comment: "")
            }
            else {
                self.navigationController?.title = NSLocalizedString("Accounts", comment: "")
                self.navigationItem.title = NSLocalizedString("Accounts", comment: "")
            }
        }
        
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
    
    
    @objc func addAccount(sender: UIBarButtonItem) {
        guard let account = self.account else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.addAccountViewController) as! AddAccountViewController
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
                    else {throw AccountError.accontAlreadyExists(name: alert!.textFields!.first!.text!)}
                    
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
            let transactionEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountEditorWithInitialBalanceViewController) as! AccountEditorWithInitialBalanceViewController
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
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.accountNavigatorCell, for: indexPath)
        let account  = fetchedResultsController.object(at: indexPath) as Account
        
        if let children = account.children, (children.allObjects as! [Account]).filter({$0.isHidden == false || $0.isHidden == showHiddenAccounts}).count > 0 {
            cell.accessoryType = .disclosureIndicator
        }
        else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.text = account.name
        if account.isHidden {
            cell.textLabel?.textColor = .systemGray
        }
        else {
            cell.textLabel?.textColor = .label
        }
        
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
        
        if let children = selectedAccount.children, (children.allObjects as! [Account]).filter({$0.isHidden == false || $0.isHidden == showHiddenAccounts}).count > 0 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableViewController) as! AccountNavigatorTableViewController
            vc.account = selectedAccount
            vc.context = context
            vc.showHiddenAccounts = self.showHiddenAccounts
            vc.simpleTransactionEditorVC = simpleTransactionEditorVC
//            vc.budgetEditorVC = budgetEditorVC
            vc.preTransactionTableViewCell = preTransactionTableViewCell
            vc.importTransactionTableViewController = importTransactionTableViewController
            vc.typeOfAccountingMethod = typeOfAccountingMethod
            vc.accountRequestorViewController = accountRequestorViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            if let addTransactionVC = simpleTransactionEditorVC {
                if typeOfAccountingMethod == .debit {
                    addTransactionVC.debit = selectedAccount
                }
                else if typeOfAccountingMethod == .credit {
                    addTransactionVC.credit = selectedAccount
                }
                self.navigationController?.popToViewController(addTransactionVC, animated: true)
            }
            else if let accountRequestorViewController = accountRequestorViewController{
                accountRequestorViewController.setAccount(selectedAccount)
                self.navigationController?.popToViewController(accountRequestorViewController, animated: true)
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
        
        let selectedAccount = fetchedResultsController.object(at: indexPath) as Account
        let addSubAccount = addSubAccount(indexPath: indexPath)
        let removeAccount = removeAccount(indexPath: indexPath)
        let hideAccount = hideAccount(indexPath: indexPath)
        let renameAccount = renameAccount(indexPath: indexPath)
        
        if isSwipeAvailable && canModifyAccountStructure {
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
            else if selectedAccount.parent == nil && selectedAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.capital) {
                //can not have subAccount, coz it used in system generated transactions
                //TODO:- create method in AccountManager that can get Account:Other if it exist otherwise Account
                
            }
            else {
                tmpConfiguration.append(addSubAccount)
            }
            
           
            if AccountManager.canBeRenamed(account: selectedAccount) {
                tmpConfiguration.append(renameAccount)
                tmpConfiguration.append(removeAccount)
            }
            if selectedAccount.parent != nil || (selectedAccount.parent == nil && selectedAccount.createdByUser == true) {
                tmpConfiguration.append(hideAccount)
            }
            return UISwipeActionsConfiguration(actions: tmpConfiguration)
        }
        return nil
    }
    
    
    
    func errorHandlerMethod(error : Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
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
}


extension AccountNavigatorTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count != 0 {
            if let account = account {
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "path CONTAINS[c] %@ && name CONTAINS[c] %@ && (isHidden = false || isHidden = %@)", argumentArray: [account.path!,searchController.searchBar.text!, showHiddenAccounts])
            }
            else {
                fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@ && (isHidden = false || isHidden = %@)", argumentArray: [searchController.searchBar.text!,showHiddenAccounts])
            }
            isSwipeAvailable = false
        }
        else {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "parent = %@ && (isHidden = false || isHidden = %@)",argumentArray: [account,showHiddenAccounts])
            isSwipeAvailable = true
        }
        fetchData()
    }
}


extension AccountNavigatorTableViewController {
    private func hideAccount(indexPath: IndexPath) -> UIContextualAction {
        let hideAction = UIContextualAction(style: .normal, title: NSLocalizedString("Hide",comment: "")) { _, _, complete in
            let selectedAccount = self.fetchedResultsController.object(at: indexPath) as Account
            var title = ""
            var message = ""
            if selectedAccount.isHidden {
                title = NSLocalizedString("Unhide",comment: "")
                message = NSLocalizedString("Do you really want unhide account?",comment: "")
            }
            else {
                title = NSLocalizedString("Hide",comment: "")
                message = NSLocalizedString("Do you really want hide account?",comment: "")
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .destructive, handler: {(_) in
                
                do {
                    try AccountManager.changeAccountIsHiddenStatus(selectedAccount)
                    try self.coreDataStack.saveContext(self.context)
                    try self.fetchedResultsController.performFetch()
                    
                    if self.showHiddenAccounts == false{
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                    else {
                        self.tableView.reloadData()
                    }
                }
                catch let error {
                    self.errorHandlerMethod(error: error)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            
            complete(true)
        }
        let selectedAccount = self.fetchedResultsController.object(at: indexPath) as Account
        if selectedAccount.isHidden == false {
            hideAction.backgroundColor = .systemGray
            hideAction.image = UIImage(systemName: "eye.slash")
        }
        else {
            hideAction.backgroundColor = .systemIndigo
            hideAction.image = UIImage(systemName: "eye")
        }
        return hideAction
    }
    
    
    private func removeAccount(indexPath: IndexPath) -> UIContextualAction{
        let removeAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Romov",comment: "")) { _, _, complete in
            let selectedAccount = self.fetchedResultsController.object(at: indexPath) as Account
            do {
                try AccountManager.canBeRemove(account: selectedAccount)
                
                var message = ""
                if let linkedAccount = selectedAccount.linkedAccount {
                    message =  String(format: NSLocalizedString("Do you really want remove account and linked account %@?",comment: ""), linkedAccount.path!)
                }
                else {
                    message = NSLocalizedString("Do you really want remove account and all clidren accounts?",comment: "")
                }
                
                let alert = UIAlertController(title: NSLocalizedString("Remove",comment: ""), message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .destructive, handler: {(_) in
                    do {
                        try AccountManager.removeAccount(selectedAccount, eligibilityChacked: true, context: self.context)
                        try self.coreDataStack.saveContext(self.context)
                        try self.fetchedResultsController.performFetch()
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                    catch let error{
                        self.errorHandlerMethod(error: error)
                    }
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .cancel))
                self.present(alert, animated: true, completion: nil)
                
            }
            catch let error{
                self.errorHandlerMethod(error: error)
            }
            complete(true)
        }
        removeAction.backgroundColor = .systemRed
        removeAction.image = UIImage(systemName: "trash")
        return removeAction
    }
    
    private func renameAccount(indexPath: IndexPath) -> UIContextualAction {
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
                    self.tableView.reloadData()
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
        rename.backgroundColor = .systemBlue
        rename.image = UIImage(systemName: "pencil")
        return rename
    }
    
    private func addSubAccount(indexPath: IndexPath) -> UIContextualAction {
        let addSubCategory = UIContextualAction(style: .normal, title: NSLocalizedString("Add subaccount",comment: "")) { _, _, complete in
            let selectedAccount = self.fetchedResultsController.object(at: indexPath) as Account
            
            if selectedAccount.currency == nil {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let transactionEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountEditorWithInitialBalanceViewController) as! AccountEditorWithInitialBalanceViewController
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
                        else {throw AccountError.accontAlreadyExists(name: alert!.textFields!.first!.text!)}
                        
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
        addSubCategory.backgroundColor = .systemGreen
        addSubCategory.image = UIImage(systemName: "plus")
        return addSubCategory
    }
}
