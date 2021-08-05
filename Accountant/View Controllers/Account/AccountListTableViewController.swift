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
        let rename = UIContextualAction(style: .normal, title: NSLocalizedString("Rename",comment: "")) { (contAct, view, complete) in
            let account : Account! = self.listOfAccountsToShow[indexPath.row].account

            let alert = UIAlertController(title: NSLocalizedString("Rename account",comment: ""), message: NSLocalizedString("Enter new account name",comment: ""), preferredStyle: .alert)

            alert.addTextField { (textField) in
                textField.placeholder = NSLocalizedString("Example: Cash",comment: "")
            }

            alert.addAction(UIAlertAction(title: NSLocalizedString("Save",comment: ""), style: .destructive, handler: { [weak alert] (_) in
                guard let textField = alert?.textFields![0] else {return}

                do {
                    try AccountManager.renameAccount(account, to: textField.text!, context: self.context)
                    try self.coreDataStack.saveContext(self.context)
                    self.delegate.updateUI()
                }
                catch let error{
                    print("Error",error)
                    self.errorHandlerMethod(error: error)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)

            complete(true)
        }
        
        let hideAccount = UIContextualAction(style: .normal, title: NSLocalizedString("Hide",comment: "")) { _, _, complete in
            let selectedAccount : Account! = self.listOfAccountsToShow[indexPath.row].account

            if selectedAccount.parent != nil {
                if self.listOfAccountsToShow[indexPath.row].amountInAccountCurrency == 0 {
                    let alert = UIAlertController(title: NSLocalizedString("Hide",comment: ""), message: NSLocalizedString("Do you really want hide account?",comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .destructive, handler: { [self](_) in
                        do {
                            AccountManager.changeAccountIsHiddenStatus(selectedAccount)
                            try self.coreDataStack.saveContext(self.context)
                        self.delegate.updateUI()
                        }
                        catch let error{
                            errorHandlerMethod(error: error)
                        }
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
            complete(true)
        }
        
        let configuration : UISwipeActionsConfiguration? = UISwipeActionsConfiguration(actions: [hideAccount, rename])
        configuration?.actions[0].backgroundColor = .systemOrange
        configuration?.actions[1].backgroundColor = .systemGreen
        
        return configuration
    }
    
    private func errorHandlerMethod(error : Error) {
        if let error = error as? AccountError{
            if error == .accontWithThisNameAlreadyExists {
                let alert = UIAlertController(title: NSLocalizedString("Warning",comment: ""), message: NSLocalizedString("Account with this name already exists. Please try another name.",comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
