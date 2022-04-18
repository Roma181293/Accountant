//
//  AccountNavigatorTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 22.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData
import Purchases

class AccountNavigatorTableViewController: UITableViewController, AccountManagerTableViewControllerDelegate {

    var coreDataStack = CoreDataStack.shared
    var context: NSManagedObjectContext! = CoreDataStack.shared.persistentContainer.viewContext

    var isUserHasPaidAccess = false
    var environment: Environment = .prod

    var resultSearchController = UISearchController()

    var canModifyAccountStructure: Bool = true
    var isSwipeAvailable: Bool = true {
        didSet {
            if isSwipeAvailable  && canModifyAccountStructure && account != nil {
                let addButton = UIBarButtonItem(title: "+",
                                                style: .plain,
                                                target: self,
                                                action: #selector(self.addAccount))
                addButton.image = UIImage(systemName: "plus")
                self.navigationItem.rightBarButtonItem = addButton
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    var searchBarIsHidden = true

    // TRANSPORT VARIABLES
    weak var simpleTransactionEditorVC: SimpleTransactionEditorViewController?
    var transactionItemType: TransactionItem.TypeEnum?
    var accountRequestorViewController: AccountRequestor?
    // TRANSPORT VARIABLES
    
    weak var account: Account?
    var excludeAccountList: [Account] = []

    var showHiddenAccounts = true
    var accountManagerController = AccountManagerController()

    lazy var fetchedResultsController: NSFetchedResultsController<Account> = {
        let fetchRequest = Account.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue) = %@ && (\(Schema.Account.active.rawValue) = true || \(Schema.Account.active.rawValue) != %@) && NOT (SELF IN %@)", argumentArray: [account, showHiddenAccounts, excludeAccountList]) // swiftlint:disable:this line_length
        fetchRequest.predicate = predicate
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AccountNavigationTableViewCell.self,
                           forCellReuseIdentifier: Constants.Cell.accountNavigationTableViewCell)
        // Set black color under cells in dark mode
        let backView = UIView(frame: self.tableView.bounds)
        backView.backgroundColor = .systemBackground
        self.tableView.backgroundView = backView

        // adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)
        accountManagerController.delegate = self

        if let  environment = CoreDataStack.shared.activeEnviroment() {
            self.environment = environment
        }

        isSwipeAvailable = true // need assign to show add button

        if let account = account {
            self.navigationItem.title = "\(account.name)"
        } else {
            if showHiddenAccounts {
                self.navigationController?.title = NSLocalizedString("Account manager", comment: "")
                self.navigationItem.title = NSLocalizedString("Account manager", comment: "")
            } else {
                self.navigationController?.title = NSLocalizedString("Accounts", comment: "")
                self.navigationItem.title = NSLocalizedString("Accounts", comment: "")
            }
        }

        if searchBarIsHidden {
            resultSearchController.isActive = false
        } else {
            resultSearchController.isActive = true
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
        tableView.tableFooterView = UIView(frame: .zero)
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

    deinit {
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }

    func updateSourceTable() throws {
        try fetchedResultsController.performFetch()
    }

    func getVCUsedForPop() -> UIViewController? {
        return self
    }

    @objc func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            } else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
            }
        }
    }

    @objc func addAccount() {
        accountManagerController.addSubAccountTo(account: account)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.accountNavigationTableViewCell, for: indexPath) as! AccountNavigationTableViewCell // swiftlint:disable:this force_cast line_length
        let account  = fetchedResultsController.object(at: indexPath) as Account
        cell.configureCellForAccount(account, showPath: !isSwipeAvailable, showHiddenAccounts: showHiddenAccounts)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedAccount = fetchedResultsController.object(at: indexPath) as Account
        if selectedAccount.childrenList.filter({$0.active || $0.active != showHiddenAccounts}).isEmpty {
            if let addTransactionVC = simpleTransactionEditorVC {
                if transactionItemType == .debit {
                    addTransactionVC.debit = selectedAccount
                } else if transactionItemType == .credit {
                    addTransactionVC.credit = selectedAccount
                }
                self.navigationController?.popToViewController(addTransactionVC, animated: true)
            } else if let accountRequestorViewController = accountRequestorViewController {
                accountRequestorViewController.setAccount(selectedAccount)
                self.navigationController?.popToViewController(accountRequestorViewController, animated: true)
            }
        } else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableVC) as? AccountNavigatorTableViewController else {return} // swiftlint:disable:this line_length
            vc.account = selectedAccount
            vc.isUserHasPaidAccess = isUserHasPaidAccess
            vc.context = context
            vc.showHiddenAccounts = self.showHiddenAccounts
            vc.searchBarIsHidden = self.searchBarIsHidden
            vc.simpleTransactionEditorVC = simpleTransactionEditorVC
            vc.transactionItemType = transactionItemType
            vc.accountRequestorViewController = accountRequestorViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let selectedAccount = fetchedResultsController.object(at: indexPath) as Account

        if isSwipeAvailable && canModifyAccountStructure {
            var tmpConfiguration: [UIContextualAction] = []

            if let parent = selectedAccount.parent, (
                parent.name == AccountsNameLocalisationManager.getLocalizedAccountName(.money) // can have only one lvl od subAccounts
                || parent.name == AccountsNameLocalisationManager.getLocalizedAccountName(.credits) // can have only one lvl od subAccounts
                || parent.name == AccountsNameLocalisationManager.getLocalizedAccountName(.debtors) // can have only one lvl od subAccounts
                || selectedAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.other1) //can not have subAccount
                || selectedAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.beforeAccountingPeriod) //coz it used in system generated transactions
            )
            // FIXME: - remove this line if it is not affect functionality
            //AccountManager.canBeRenamed(account: selectedAccount),
            
            {
                
            } else if selectedAccount.parent == nil && selectedAccount.name == AccountsNameLocalisationManager.getLocalizedAccountName(.capital) {
                //can not have subAccount, coz it used in system generated transactions
                //TODO:- create method in AccountManager that can get Account:Other if it exist otherwise Account
                
            } else {
                tmpConfiguration.append(accountManagerController.addSubAccount(indexPath: indexPath, selectedAccount: selectedAccount))
            }

            if selectedAccount.canBeRenamed {
                tmpConfiguration.append(accountManagerController.renameAccount(indexPath: indexPath, selectedAccount: selectedAccount))
                tmpConfiguration.append(accountManagerController.removeAccount(indexPath: indexPath, selectedAccount: selectedAccount))
            }
            if selectedAccount.parent != nil || (selectedAccount.parent == nil && selectedAccount.createdByUser == true) {
                tmpConfiguration.append(accountManagerController.hideAccount(indexPath: indexPath, selectedAccount: selectedAccount))
            }
            return UISwipeActionsConfiguration(actions: tmpConfiguration)
        }
        return nil
    }

    func errorHandlerMethod(error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: "\(error.localizedDescription)",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    func fetchData() {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            errorHandlerMethod(error: error)
        }
    }

    func resetPredicate() {
        let predicate = NSPredicate(format: "\(Schema.Account.parent.rawValue) = %@ && (\(Schema.Account.active.rawValue) = true || \(Schema.Account.active.rawValue) != %@) && NOT (SELF IN %@)", argumentArray: [account, showHiddenAccounts, excludeAccountList]) // swiftlint:disable:this line_length
        fetchedResultsController.fetchRequest.predicate = predicate
    }
}

extension AccountNavigatorTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count != 0 {
            var prdct = NSPredicate()
            if account != nil {
                prdct = NSPredicate(format: "\(Schema.Account.name.rawValue) CONTAINS[c] %@ && (\(Schema.Account.active.rawValue) = true || \(Schema.Account.active.rawValue) != %@) && NOT (SELF IN %@)", argumentArray: [searchController.searchBar.text!, showHiddenAccounts, excludeAccountList]) // swiftlint:disable:this line_length
            } else {
                prdct = NSPredicate(format: "\(Schema.Account.name.rawValue) CONTAINS[c] %@ && (\(Schema.Account.active.rawValue) = true || \(Schema.Account.active.rawValue) != %@) && NOT (SELF IN %@)", argumentArray: [searchController.searchBar.text!,showHiddenAccounts, excludeAccountList]) // swiftlint:disable:this line_length
            }
            fetchedResultsController.fetchRequest.predicate = prdct
            isSwipeAvailable = false
        } else {
            resetPredicate()
            isSwipeAvailable = true
        }
        fetchData()
    }
}
