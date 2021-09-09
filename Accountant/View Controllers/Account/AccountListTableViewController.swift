//
//  MoneyAccountListTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 14.08.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData

class AccountListTableViewController: UITableViewController {
    
    var isUserHasPaidAccess: Bool = false
    let coreDataStack = CoreDataStack.shared
    var context : NSManagedObjectContext!
    
    var delegate : AccountListViewController!
    var accountingCurrency : Currency!
    var listOfAccountsToShow : [AccountData] = []
 
    func updateUI() {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfAccountsToShow.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let account: Account! = listOfAccountsToShow[indexPath.row].account
       
        if AccountManager.getRootAccountFor(account).name! == AccountsNameLocalisationManager.getLocalizedAccountName(.money){
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.moneyAccountCell, for: indexPath) as! MoneyAccountTableViewCell
            cell.updateCell(dataToShow: listOfAccountsToShow[indexPath.row], accountingCurrency : accountingCurrency)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.accountInForeignCurrencyCell, for: indexPath) as! AccountInForeignCurrencyTableViewCell
            cell.updateCell(dataToShow: listOfAccountsToShow[indexPath.row], accountingCurrency : accountingCurrency)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("Warning",comment: ""), message: NSLocalizedString("Amount excluded from total amount in pichart.\nAccount amount cannot be less zero.\nPlease check transaction with this account.",comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameAccount = UIContextualAction(style: .normal, title: NSLocalizedString("Rename",comment: "")) { (contAct, view, complete) in
            let selectedAccount : Account = self.listOfAccountsToShow[indexPath.row].account
            
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
                    self.delegate.updateUI()
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
        renameAccount.backgroundColor = .systemBlue
        renameAccount.image = UIImage(systemName: "pencil")
        
        let hideAccount = UIContextualAction(style: .normal, title: NSLocalizedString("Hide",comment: "")) { _, _, complete in
            let selectedAccount : Account = self.listOfAccountsToShow[indexPath.row].account
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
                    self.delegate.updateUI()
                }
                catch let error {
                    self.errorHandlerMethod(error: error)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No",comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            
            complete(true)
        }
        
        let removeAccount = UIContextualAction(style: .destructive, title: NSLocalizedString("Romov",comment: "")) { _, _, complete in
            let selectedAccount : Account = self.listOfAccountsToShow[indexPath.row].account
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
                        self.delegate.updateUI()
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
        removeAccount.backgroundColor = .systemRed
        removeAccount.image = UIImage(systemName: "trash")
        hideAccount.backgroundColor = .systemGray
        hideAccount.image = UIImage(systemName: "eye.slash")
        renameAccount.backgroundColor = .systemBlue
        renameAccount.image = UIImage(systemName: "pencil")
        
        let configuration : UISwipeActionsConfiguration? = UISwipeActionsConfiguration(actions: [renameAccount, removeAccount, hideAccount])
        return configuration
    }
    
    private func errorHandlerMethod(error : Error) {
            let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
    }
}
