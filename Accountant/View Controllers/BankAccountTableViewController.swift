//
//  BankAccountTableViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 19.01.2022.
//

import UIKit
import CoreData

class BankAccountTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
    
    var userBankProfile: UserBankProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cell.userBankProfileCell)
        
        self.navigationItem.title = (userBankProfile.name ?? "") + "-" + (userBankProfile.keeper?.name ?? "")
        
            tableView.reloadData()
       
    }
    
    
    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userBankProfile.bankAccounts?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle , reuseIdentifier: Constants.Cell.userBankProfileCell)
//        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.userBankProfileCell, for: indexPath)
        let ba = (userBankProfile.bankAccounts?.allObjects as! [BankAccount])[indexPath.row]
        cell.textLabel?.text = (ba.strBin ?? "") + " (" + (ba.account?.currency?.code ?? "") + ")"
        cell.detailTextLabel?.text = ba.account?.path
        return cell
    }
    
    var bankAccount: BankAccount!
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }
    
    func errorHandler(error : Error) {
        if error is AppError {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { [self](_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let changeLink = UIContextualAction(style: .normal, title: NSLocalizedString("Relink",comment: "")) { (contAct, view, complete) in
            
            let alert = UIAlertController(title: NSLocalizedString("Relink",comment: ""), message: NSLocalizedString("Do you really want to change linked account?", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .default, handler: { (_) in
                self.bankAccount = (self.userBankProfile.bankAccounts?.allObjects as! [BankAccount])[indexPath.row]
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableViewController) as! AccountNavigatorTableViewController
                vc.context = self.context
                vc.showHiddenAccounts = false
                vc.canModifyAccountStructure = false
                vc.accountRequestorViewController = self
                vc.account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: self.context)
                vc.excludeAccountList = BankAccountManager.findNotValidAccountCandidateForLinking(for: self.bankAccount)
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            
            complete(true)
        }
        changeLink.backgroundColor = .systemBlue
        changeLink.image = UIImage(systemName: "link")
        return UISwipeActionsConfiguration(actions: [changeLink])
    }
}


extension BankAccountTableViewController: AccountRequestor {
    func setAccount(_ account: Account) {
        do{
            try BankAccountManager.changeLinkedAccount(to: account, for: bankAccount)
            try CoreDataStack.shared.saveContext(context)
            tableView.reloadData()
        }
        catch let error {
            errorHandler(error: error)
        }
    }
}

