//
//  MoneyAccountListTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 14.08.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData

class AccountListTableViewController: UITableViewController, AccountManagerTableViewControllerDelegate {
    
    var isUserHasPaidAccess: Bool = false
    var environment: Environment = .prod
    
    var coreDataStack = CoreDataStack.shared
    var context : NSManagedObjectContext!
    
    var delegate : AccountListViewController!
    var accountingCurrency : Currency!
    var showHiddenAccounts: Bool = false
    var listOfAccountsToShow : [AccountData] = []
    
    var accountManagerController = AccountManagerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountManagerController.delegate = self
    }
    
    func updateSourceTable() throws {
        delegate.updateUI()
    }
    
    func showPurchaseOfferVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
        self.present(vc, animated: true, completion: nil)
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
        let selectedAccount : Account = self.listOfAccountsToShow[indexPath.row].account
        
        var tmpConfiguration: [UIContextualAction] = []
        
        if AccountManager.canBeRenamed(account: selectedAccount) {
            tmpConfiguration.append(accountManagerController.renameAccount(indexPath: indexPath, selectedAccount: selectedAccount))
            tmpConfiguration.append(accountManagerController.removeAccount(indexPath: indexPath, selectedAccount: selectedAccount))
        }
        if selectedAccount.parent != nil || (selectedAccount.parent == nil && selectedAccount.createdByUser == true) {
            tmpConfiguration.append(accountManagerController.hideAccount(indexPath: indexPath, selectedAccount: selectedAccount))
        }
        return UISwipeActionsConfiguration(actions: tmpConfiguration)
    }
    
    func errorHandlerMethod(error : Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
