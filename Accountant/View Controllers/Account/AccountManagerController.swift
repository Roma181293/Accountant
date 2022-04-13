//
//  AccountManagerController.swift
//  Accountant
//
//  Created by Roman Topchii on 09.09.2021.
//

import UIKit
import CoreData

protocol AccountManagerTableViewControllerDelegate: UITableViewController{
    
    var isUserHasPaidAccess: Bool {get set}
    var environment: Environment {get set}
    var context: NSManagedObjectContext! {get set}
    var coreDataStack: CoreDataStack {get set}
    var account: Account? {get set}
    var showHiddenAccounts: Bool {get set}
    
    func updateSourceTable() throws
    func errorHandlerMethod(error: Error)
    func getVCUsedForPop() -> UIViewController?  // method requires for popToVC after creating trancastion
}

class AccountManagerController {
    unowned var delegate: AccountManagerTableViewControllerDelegate!
    
    
    func addSubAccountTo(account: Account?) {
        if AccessCheckManager.checkUserAccessToCreateSubAccountForSelected(account: account, isUserHasPaidAccess: delegate.isUserHasPaidAccess, environment: delegate.environment) {
            guard let account = self.delegate.account else {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.addAccountVC) as! AddAccountViewController
                vc.environment = delegate.environment
                vc.isUserHasPaidAccess = delegate.isUserHasPaidAccess
                self.delegate.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            if let accountCurrency = account.currency {
                let alert = UIAlertController(title: NSLocalizedString("Add category",comment: ""), message: nil, preferredStyle: .alert)
                
                alert.addTextField { (textField) in
                    textField.tag = 100
                    textField.placeholder = NSLocalizedString("Name",comment: "")
                    textField.delegate = alert as! UITextFieldDelegate
                }
                alert.addAction(UIAlertAction(title: NSLocalizedString("Add",comment: ""), style: .default, handler: { [weak alert] (_) in
                    
                    do {
                        guard let alert = alert,
                              let textFields = alert.textFields,
                              let textField = textFields.first
                        else {return}
                        
                        try Account.createAccount(parent: account, name: textField.text!, type: account.type, currency: accountCurrency, context: self.delegate.context)
                        try self.delegate.coreDataStack.saveContext(self.delegate.context)
                        try self.delegate.updateSourceTable()
                        self.delegate.tableView.reloadData()
                    }
                    catch let error{
                        print("Error",error)
                        self.delegate.errorHandlerMethod(error: error)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
                self.delegate.present(alert, animated: true, completion: nil)
            }
            else {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let accountEditorWithInitialBalanceVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountEditorWithInitialBalanceVC) as! AccountEditorWithInitialBalanceViewController
                accountEditorWithInitialBalanceVC.parentAccount = account
                self.delegate.navigationController?.pushViewController(accountEditorWithInitialBalanceVC, animated: true)
            }
        }
        else {
            self.showPurchaseOfferVC()
        }
    }
    
    
    func hideAccount(indexPath: IndexPath, selectedAccount: Account) -> UIContextualAction {
        let hideAction = UIContextualAction(style: .normal, title: NSLocalizedString("Hide",comment: "")) { _, _, complete in
            
            if AccessCheckManager.checkUserAccessToHideAccount(environment: self.delegate.environment, isUserHasPaidAccess: self.delegate.isUserHasPaidAccess) {
                var title = ""
                var message = ""
                if selectedAccount.parent?.currency == nil {
                    if selectedAccount.active {
                        title = NSLocalizedString("Hide",comment: "")
                        message = NSLocalizedString("Are you sure you want to hide account?",comment: "")
                    }
                    else {
                        title = NSLocalizedString("Unhide",comment: "")
                        message = NSLocalizedString("Are you sure you want to unhide account?",comment: "")
                    }
                }
                else {
                    if selectedAccount.active {
                        title = NSLocalizedString("Hide",comment: "")
                        message = NSLocalizedString("Are you sure you want to hide category?",comment: "")
                    }
                    else {
                        title = NSLocalizedString("Unhide",comment: "")
                        message = NSLocalizedString("Are you sure you want to unhide category?",comment: "")
                    }
                }
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .destructive, handler: {(_) in
                    
                    do {
                        try selectedAccount.changeActiveStatus()
                        try self.delegate.coreDataStack.saveContext(self.delegate.context)
                        try self.delegate.updateSourceTable()
                        
                        //FIXME:- try to uncomment somehow
//                        if self.delegate.showHiddenAccounts == false{
//                            self.delegate.tableView.deleteRows(at: [indexPath], with: .fade)
//                        }
//                        else {
                            self.delegate.tableView.reloadData()
//                        }
                    }
                    catch let error {
                        self.delegate.errorHandlerMethod(error: error)
                    }
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .cancel))
                self.delegate.present(alert, animated: true, completion: nil)
            }
            else {
                self.showPurchaseOfferVC()
            }
            complete(true)
        }
        
        if selectedAccount.active {
            hideAction.backgroundColor = .systemIndigo
            hideAction.image = UIImage(systemName: "eye")
        }
        else {
            hideAction.backgroundColor = .systemGray
            hideAction.image = UIImage(systemName: "eye.slash")
        }
        return hideAction
    }
    
    
    func removeAccount(indexPath: IndexPath, selectedAccount: Account) -> UIContextualAction{
        let removeAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete",comment: "")) { _, _, complete in
            do {
                try selectedAccount.canBeRemoved()
                
                var message = ""
                if selectedAccount.parent?.currency == nil {
                    if let linkedAccount = selectedAccount.linkedAccount {
                        message =  String(format: NSLocalizedString("Are you sure you want to delete account and linked account  \"%@\"?",comment: ""), linkedAccount.path)
                    }
                    else {
                        message = NSLocalizedString("Are you sure you want to delete account?",comment: "")
                    }
                }
                else {
                    message = NSLocalizedString("Are you sure you want to delete this category and all its subcategories?",comment: "")
                }
                
                let alert = UIAlertController(title: NSLocalizedString("Delete",comment: ""), message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .destructive, handler: {(_) in
                    do {
                        try selectedAccount.delete(eligibilityChacked: true)
                        try self.delegate.coreDataStack.saveContext(self.delegate.context)
                        try self.delegate.updateSourceTable()
                        
                        //FIXME:- self.delegate.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.delegate.tableView.reloadData()//deleteRows(at: [indexPath], with: .fade)
                    }
                    catch let error{
                        self.delegate.errorHandlerMethod(error: error)
                    }
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .cancel))
                self.delegate.present(alert, animated: true, completion: nil)
                
            }
            catch let error{
                self.delegate.errorHandlerMethod(error: error)
            }
            complete(true)
        }
        removeAction.backgroundColor = .systemRed
        removeAction.image = UIImage(systemName: "trash")
        return removeAction
    }
    
    func renameAccount(indexPath: IndexPath, selectedAccount: Account) -> UIContextualAction {
        let rename = UIContextualAction(style: .normal, title: NSLocalizedString("Rename",comment: "")) { (contAct, view, complete) in
            
            let alert = UIAlertController(title: NSLocalizedString("Rename",comment: ""), message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = NSLocalizedString("New name",comment: "")
                textField.text = selectedAccount.name
                textField.tag = 100
                textField.delegate = alert as! UITextFieldDelegate
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .destructive, handler: { [weak alert] (_) in
                guard let textField = alert?.textFields![0] else {return}
                
                do {
                    try selectedAccount.rename(to: textField.text!, context: self.delegate.context)
                    try self.delegate.coreDataStack.saveContext(self.delegate.context)
                    try self.delegate.updateSourceTable()
                    self.delegate.tableView.reloadData()
                }
                catch let error{
                    print("Error",error)
                    self.delegate.errorHandlerMethod(error: error)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .cancel))
            self.delegate.present(alert, animated: true, completion: nil)
            
            complete(true)
        }
        rename.backgroundColor = .systemBlue
        rename.image = UIImage(systemName: "pencil")
        return rename
    }
    
    func addSubAccount(indexPath: IndexPath, selectedAccount: Account) -> UIContextualAction {
        let addSubCategory = UIContextualAction(style: .normal, title: nil) { _, _, complete in
            
            if AccessCheckManager.checkUserAccessToCreateSubAccountForSelected(account: selectedAccount, isUserHasPaidAccess: self.delegate.isUserHasPaidAccess, environment: self.delegate.environment) {
                if selectedAccount.currency == nil {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let accountEditorWithInitialBalanceVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountEditorWithInitialBalanceVC) as! AccountEditorWithInitialBalanceViewController
                    
                    accountEditorWithInitialBalanceVC.parentAccount = selectedAccount
                    self.delegate.navigationController?.pushViewController(accountEditorWithInitialBalanceVC, animated: true)
                }
                else {
                    
                    let alert = UIAlertController(title: NSLocalizedString("Add subcategory",comment: ""), message: nil, preferredStyle: .alert)
                    
                    alert.addTextField { (textField) in
                        textField.tag = 100
                        textField.placeholder = NSLocalizedString("Name", comment: "")
                        textField.delegate = alert as! UITextFieldDelegate
                    }
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Add",comment: ""), style: .default, handler: { [weak alert] (_) in
                        
                        do {
                            guard let alert = alert,
                                  let textFields = alert.textFields,
                                  let textField = textFields.first,
                                  Account.isFreeAccountName(parent: selectedAccount, name: textField.text!, context: self.delegate.context)
                            else {throw AccountError.accountAlreadyExists(name: alert!.textFields!.first!.text!)}
                            
                            if !selectedAccount.isFreeFromTransactionItems {
                                
                                let alert1 = UIAlertController(title: NSLocalizedString("Warning",comment: ""), message:  String(format: NSLocalizedString("Category \"%@\" contains transactions. All these thansactions will be automatically moved to the new \"%@\" subcategory",comment: ""), selectedAccount.name, AccountsNameLocalisationManager.getLocalizedAccountName(.other1)), preferredStyle: .alert)
                                alert1.addAction(UIAlertAction(title: NSLocalizedString("Create and Move",comment: ""), style: .default, handler: { [weak alert1] (_) in
                                    do {
                                        try Account.createAccount(parent: selectedAccount, name: textField.text!, type: selectedAccount.type, currency: selectedAccount.currency!, context: self.delegate.context)
                                        try self.delegate.coreDataStack.saveContext(self.delegate.context)
                                        try self.delegate.updateSourceTable()
                                        self.delegate.tableView.reloadData()
                                    }
                                    catch let error{
                                        print("Error",error)
                                        self.delegate.errorHandlerMethod(error: error)
                                    }
                                    
                                }))
                                
                                alert1.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
                                self.delegate.present(alert1, animated: true, completion: nil)
                                
                            }
                            else {
                                
                                try Account.createAccount(parent: selectedAccount, name: textField.text!, type: selectedAccount.type, currency: selectedAccount.currency!, context: self.delegate.context)
                                try self.delegate.coreDataStack.saveContext(self.delegate.context)
                                try self.delegate.updateSourceTable()
                                self.delegate.tableView.reloadData()
                            }
                        }
                        catch let error{
                            print("Error",error)
                            self.delegate.errorHandlerMethod(error: error)
                        }
                    }))
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
                    self.delegate.present(alert, animated: true, completion: nil)
                }
            }
            else {
                self.showPurchaseOfferVC()
            }
            complete(true)
        }
        addSubCategory.backgroundColor = .systemGreen
        addSubCategory.image = UIImage(systemName: "plus")
        return addSubCategory
    }
    
    func addTransactionWithDebitAccount(indexPath: IndexPath, selectedAccount: Account) -> UIContextualAction {
        let addDebitTransaction = UIContextualAction(style: .normal, title: NSLocalizedString("To",comment: "")) { (contAct, view, complete) in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let simpleTransactionEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.simpleTransactionEditorVC) as! SimpleTransactionEditorViewController
            simpleTransactionEditorVC.debit = selectedAccount
            simpleTransactionEditorVC.delegate = self.delegate
            self.delegate.navigationController?.pushViewController(simpleTransactionEditorVC, animated: true)
            complete(true)
        }
        addDebitTransaction.backgroundColor = .systemGreen
        return addDebitTransaction
    }
    
    func addTransactionWithCreditAccount(indexPath: IndexPath, selectedAccount: Account) -> UIContextualAction {
        let addCreditTransaction = UIContextualAction(style: .normal, title: NSLocalizedString("From",comment: "")) { (contAct, view, complete) in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let simpleTransactionEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.simpleTransactionEditorVC) as! SimpleTransactionEditorViewController
            simpleTransactionEditorVC.credit = selectedAccount
            simpleTransactionEditorVC.delegate = self.delegate
            self.delegate.navigationController?.pushViewController(simpleTransactionEditorVC, animated: true)
            complete(true)
        }
        addCreditTransaction.backgroundColor = .systemOrange
        return addCreditTransaction
    }
    
    func editAccount(indexPath: IndexPath, selectedAccount: Account) -> UIContextualAction {
        let editAccount = UIContextualAction(style: .normal, title: NSLocalizedString("Edit",comment: "")) { (contAct, view, complete) in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let accountEditorWithInitialBalanceViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountEditorWithInitialBalanceVC) as! AccountEditorWithInitialBalanceViewController
            accountEditorWithInitialBalanceViewController.parentAccount = selectedAccount.rootAccount
            accountEditorWithInitialBalanceViewController.account = selectedAccount
            self.delegate.navigationController?.pushViewController(accountEditorWithInitialBalanceViewController, animated: true)
            complete(true)
        }
        editAccount.backgroundColor = .systemPink
        editAccount.image = UIImage(systemName: "gear")
        return editAccount
    }
    
    func showPurchaseOfferVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferVC) as! PurchaseOfferViewController
        self.delegate.present(vc, animated: true, completion: nil)
    }
}
