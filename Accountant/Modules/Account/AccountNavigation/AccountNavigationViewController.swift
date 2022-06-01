//
//  AccountNavigationViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 21.04.2022.
//

import UIKit
import CoreData
import Purchases

protocol AccountRequestor {
    func setAccount(_ account: Account)
}

protocol AccountNavigationDelegate: UIViewController {
}

class AccountNavigationViewController: UITableViewController {

    var parentAccount: Account?
    var excludeAccountList: [Account] = []
    var showHiddenAccounts: Bool = true
    var canModifyAccountStructure: Bool = true
    var searchBarIsHidden = false

    var requestor: AccountRequestor?
    weak var delegate: AccountNavigationDelegate?

    private var isUserHasPaidAccess = false
    private lazy var dataProvider: AccountProvider = {
        let accountProvider = AccountProvider(with: CoreDataStack.shared.persistentContainer)
        accountProvider.fetchedResultsControllerDelegate = self
        accountProvider.parent = parentAccount
        accountProvider.excludeAccountList = excludeAccountList
        accountProvider.showHiddenAccounts = showHiddenAccounts
        accountProvider.canModifyAccountStructure = canModifyAccountStructure
        return accountProvider
    }()

    private lazy var resultSearchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.searchBar.sizeToFit()
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        controller.automaticallyShowsSearchResultsController = false
        controller.automaticallyShowsCancelButton = false
        tableView.tableHeaderView = controller.searchBar
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadProAccessData()
        
        // adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)
        tableView.register(AccountNavigationCell.self,
                           forCellReuseIdentifier: Constants.Cell.accountNavCell)
        createAddButton()
        configureTableViewBackground()
        configureTitle()
        configureSearchBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        dataProvider.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        resultSearchController.dismiss(animated: true, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }

    func resetPredicate() {
        dataProvider.resetPredicate()
    }

    func refreshDataForNewParent() {
        dataProvider.parent = parentAccount
        dataProvider.resetPredicate()
        dataProvider.reloadData()
        tableView.reloadData()
    }
}

// MARK: - Configure UI
extension AccountNavigationViewController {
    private func createAddButton() {
        if dataProvider.isSwipeAvailable  && dataProvider.canModifyAccountStructure && dataProvider.parent != nil {
            let addButton = UIBarButtonItem(title: "+",
                                            style: .plain,
                                            target: self,
                                            action: #selector(self.addCategoryOrAccount))
            addButton.image = UIImage(systemName: "plus")
            self.navigationItem.rightBarButtonItem = addButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    private func configureTableViewBackground() {
        let backView = UIView(frame: self.tableView.bounds)
        backView.backgroundColor = .systemBackground
        self.tableView.backgroundView = backView
    }

    private func configureTitle() {
        if let parentAccount = parentAccount {
            self.navigationItem.title = "\(parentAccount.name)"
        } else {
            if dataProvider.showHiddenAccounts {
                let title = NSLocalizedString("Account manager",
                                              tableName: Constants.Localizable.accountNavigationVC, comment: "")
                self.navigationController?.title = title
                self.navigationItem.title = title
            } else {
                let title = NSLocalizedString("Accounts",
                                              tableName: Constants.Localizable.accountNavigationVC, comment: "")
                self.navigationController?.title = title
                self.navigationItem.title = title
            }
        }
    }

    private func configureSearchBar() {
        if searchBarIsHidden {
            resultSearchController.isActive = false
        } else {
            resultSearchController.isActive = true
        }
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

// MARK: - Objc methods
extension AccountNavigationViewController {
    @objc func addCategoryOrAccount() {
        self.addCategotyTo(parentAccount)
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
}

// MARK: - Table view data source
extension AccountNavigationViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataProvider.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.accountNavCell,
                                                       for: indexPath) as? AccountNavigationCell
        else {fatalError("###\(#function): Failed to dequeue accountNavCell")}

        let account = dataProvider.fetchedResultsController.object(at: indexPath)
        cell.configureCellFor(account, showPath: !dataProvider.isSwipeAvailable,
                                     showHiddenAccounts: dataProvider.showHiddenAccounts)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedAccount = dataProvider.fetchedResultsController.object(at: indexPath) as Account
        if selectedAccount.childrenList.filter({$0.active || $0.active != dataProvider.showHiddenAccounts}).isEmpty {
            if let requestor = requestor, let delegate = delegate, selectedAccount.type.isConsolidation == false {
                requestor.setAccount(selectedAccount)
                self.navigationController?.popToViewController(delegate, animated: true)
            }
        } else {
            goToAccountNavigationVC(account: selectedAccount)
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        for item in  dataProvider.allowedActions(at: indexPath) {
            switch item {
            case .create: actions.append(addSubAccountAction(at: indexPath))
            case .rename: actions.append(renameAction(at: indexPath))
            case .delete: actions.append(deleteAction(at: indexPath))
            case .changeActiveStatus: actions.append(changeActiveStatusAction(at: indexPath))
            }
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
}

// MARK: - UIContextualAction methods
extension AccountNavigationViewController {
    private func addCategotyTo(_ account: Account?) { // swiftlint:disable:this function_body_length
        if AccessManager.canCreateSubAccountFor(account: account,
                                                  isUserHasPaidAccess: self.isUserHasPaidAccess,
                                                  environment: CoreDataStack.shared.activeEnviroment()!) {
            if let account = account {
                if account.type.useCustomViewToCreateAccount || account.type.hasMoreThenOneChildren {
                    goToAccountEditorWithInitialBalanceVC(account: account)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Add subcategory", tableName: Constants.Localizable.accountNavigationVC, comment: ""),
                                                  message: nil, preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.tag = 100
                        textField.placeholder = NSLocalizedString("Name", tableName: Constants.Localizable.accountNavigationVC, comment: "")
                        textField.delegate = self
                    }

                    let addAction = UIAlertAction(title: NSLocalizedString("Add", tableName: Constants.Localizable.accountNavigationVC, comment: ""),
                                                  style: .default, handler: { [weak alert] (_) in
                        do {
                            guard let name = alert?.textFields?.first?.text, !name.isEmpty,
                                  Account.isFreeAccountName(parent: account,
                                                            name: name,
                                                            context: CoreDataStack.shared.persistentContainer.viewContext)
                            else {throw AccountError.accountAlreadyExists(name: alert!.textFields!.first!.text!)}

                            if !account.isFreeFromTransactionItems {
                                let alert1 = UIAlertController(title: NSLocalizedString("Warning", tableName: Constants.Localizable.accountNavigationVC, comment: ""),
                                                               message: String(format: NSLocalizedString("Category \"%@\" contains transactions. All these thansactions will be automatically moved to the \"%@\" subcategory", tableName: Constants.Localizable.accountNavigationVC, comment: ""), // swiftlint:disable:this line_length
                                                                               account.name, LocalisationManager.getLocalizedName(.other1)), // swiftlint:disable:this line_length
                                                               preferredStyle: .alert)
                                alert1.addAction(UIAlertAction(title: NSLocalizedString("Create and Move", tableName: Constants.Localizable.accountNavigationVC, comment: ""),
                                                               style: .default, handler: { (_) in
                                    do {
                                        try self.dataProvider.addCategoty(parent: account, name: name)
                                    } catch let error {
                                        self.errorHandlerMethod(error: error)
                                    }
                                }))
                                alert1.addAction(UIAlertAction(title: NSLocalizedString("Cancel", tableName: Constants.Localizable.accountNavigationVC, comment: ""),
                                                               style: .cancel))
                                self.present(alert1, animated: true, completion: nil)
                            } else {
                                try self.dataProvider.addCategoty(parent: account, name: name)
                            }
                        } catch let error {
                            self.errorHandlerMethod(error: error)
                        }
                    })
                    alert.addAction(addAction)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", tableName: Constants.Localizable.accountNavigationVC, comment: ""), style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                goToRootAccountEditorVC()
                return
            }
        } else {
            self.showPurchaseOfferVC()
        }
    }

    private func addSubAccountAction(at indexPath: IndexPath) -> UIContextualAction {
        let selectedAccount = dataProvider.fetchedResultsController.object(at: indexPath)
        let addSubCategory = UIContextualAction(style: .normal, title: nil) { _, _, complete in
            self.addCategotyTo(selectedAccount)
            complete(true)
        }
        addSubCategory.backgroundColor = .systemGreen
        addSubCategory.image = UIImage(systemName: "plus")
        return addSubCategory
    }

    private func renameAction(at indexPath: IndexPath) -> UIContextualAction {
        let selectedAccount = dataProvider.fetchedResultsController.object(at: indexPath)
        let rename = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Rename", tableName: Constants.Localizable.accountNavigationVC, comment: "")) { (_, _, complete) in
            let alert = UIAlertController(title: NSLocalizedString("Rename", tableName: Constants.Localizable.accountNavigationVC, comment: ""),
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.tag = 100
                textField.placeholder = NSLocalizedString("New name",
                                                          tableName: Constants.Localizable.accountNavigationVC,
                                                          comment: "")
                textField.text = selectedAccount.name
                textField.delegate = self
            }
            let confirmAction = UIAlertAction(title: NSLocalizedString("Yes", tableName: Constants.Localizable.accountNavigationVC, comment: ""),
                                              style: .destructive,
                                              handler: { [weak alert] (_) in
                guard let newName = alert?.textFields?.first?.text, !newName.isEmpty else {return}
                do {
                    try self.dataProvider.renameAccount(at: indexPath, newName: newName)
                } catch let error {
                    self.errorHandlerMethod(error: error)
                }
            })
            alert.addAction(confirmAction)

            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", tableName: Constants.Localizable.accountNavigationVC, comment: ""), style: .cancel)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            complete(true)
        }
        rename.backgroundColor = .systemBlue
        rename.image = UIImage(systemName: "pencil")
        return rename
    }

    private func changeActiveStatusAction(at indexPath: IndexPath) -> UIContextualAction {
        let account = dataProvider.fetchedResultsController.object(at: indexPath)
        let hideAction = UIContextualAction(style: .normal,
                                            title: NSLocalizedString("Deactivate", tableName: Constants.Localizable.accountNavigationVC, comment: "")) { _, _, complete in
            if AccessManager.canHideAccount(environment: CoreDataStack.shared.activeEnviroment()!,
                                                          isUserHasPaidAccess: self.isUserHasPaidAccess) {
                var title = ""
                var message = ""
                if account.parent?.currency == nil {
                    if account.active {
                        title = NSLocalizedString("Deactivate",
                                                  tableName: Constants.Localizable.accountNavigationVC,
                                                  comment: "")
                        message = NSLocalizedString("Deactivate account?",
                                                    tableName: Constants.Localizable.accountNavigationVC,
                                                    comment: "")
                    } else {
                        title = NSLocalizedString("Activate", tableName: Constants.Localizable.accountNavigationVC,
                                                  comment: "")
                        message = NSLocalizedString("Activate account?",
                                                    tableName: Constants.Localizable.accountNavigationVC,
                                                    comment: "")
                    }
                } else {
                    if account.active {
                        title = NSLocalizedString("Deactivate",
                                                  tableName: Constants.Localizable.accountNavigationVC,
                                                  comment: "")
                        message = NSLocalizedString("Deactivate category?",
                                                    tableName: Constants.Localizable.accountNavigationVC,
                                                    comment: "")
                    } else {
                        title = NSLocalizedString("Activate",
                                                  tableName: Constants.Localizable.accountNavigationVC,
                                                  comment: "")
                        message = NSLocalizedString("Activate category?",
                                                    tableName: Constants.Localizable.accountNavigationVC,
                                                    comment: "")
                    }
                }

                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",
                                                                       tableName: Constants.Localizable.accountNavigationVC,
                                                                       comment: ""),
                                              style: .destructive,
                                              handler: {(_) in

                    do {
                        try self.dataProvider.changeActiveStatus(indexPath: indexPath)
                    } catch let error {
                        self.errorHandlerMethod(error: error)
                    }
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No",
                                                                       tableName: Constants.Localizable.accountNavigationVC,
                                                                       comment: ""),
                                              style: .cancel))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.showPurchaseOfferVC()
            }
            complete(true)
        }
        if account.active {
            hideAction.backgroundColor = .systemIndigo
            hideAction.image = UIImage(systemName: "eye")
        } else {
            hideAction.backgroundColor = .systemGray
            hideAction.image = UIImage(systemName: "eye.slash")
        }
        return hideAction
    }

    private func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let account = dataProvider.fetchedResultsController.object(at: indexPath)
        let removeAction = UIContextualAction(style: .destructive,
                                              title: NSLocalizedString("Delete", tableName: Constants.Localizable.accountNavigationVC, comment: "")) { _, _, complete in
            do {
                try account.canBeRemoved()
                var message = ""
                if account.parent?.currency == nil {
                    if let linkedAccount = account.linkedAccount {
                        message =  String(format: NSLocalizedString("Do you want to delete account and linked account \"%@\"?", tableName: Constants.Localizable.accountNavigationVC, comment: ""), linkedAccount.path) // swiftlint:disable:this line_length
                    } else {
                        message = NSLocalizedString("Do you want to delete account?", tableName: Constants.Localizable.accountNavigationVC, comment: "")
                    }
                } else {
                    message = NSLocalizedString("Do you want to delete this category and all its subcategories?", tableName: Constants.Localizable.accountNavigationVC, comment: "")
                }
                let alert = UIAlertController(title: NSLocalizedString("Delete", tableName: Constants.Localizable.accountNavigationVC, comment: ""),
                                              message: message,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", tableName: Constants.Localizable.accountNavigationVC, comment: ""),
                                              style: .destructive,
                                              handler: {(_) in
                    do {
                        try self.dataProvider.delete(at: indexPath)
                    } catch let error {
                        self.errorHandlerMethod(error: error)
                    }
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", tableName: Constants.Localizable.accountNavigationVC, comment: ""), style: .cancel))
                self.present(alert, animated: true, completion: nil)
            } catch let error {
                self.errorHandlerMethod(error: error)
            }
            complete(true)
        }
        removeAction.backgroundColor = .systemRed
        removeAction.image = UIImage(systemName: "trash")
        return removeAction
    }
}

// MARK: - Routing methods
extension AccountNavigationViewController {

    private func goToAccountNavigationVC(account: Account) {
        let accountNavigatorVC = AccountNavigationViewController()
        accountNavigatorVC.requestor = requestor
        accountNavigatorVC.delegate = delegate
        accountNavigatorVC.parentAccount = account
        accountNavigatorVC.excludeAccountList = excludeAccountList
        accountNavigatorVC.showHiddenAccounts = showHiddenAccounts
        accountNavigatorVC.canModifyAccountStructure = canModifyAccountStructure
        print("searchBarIsHidden", searchBarIsHidden)
        accountNavigatorVC.searchBarIsHidden = searchBarIsHidden
        self.navigationController?.pushViewController(accountNavigatorVC, animated: true)
    }

    private func goToAccountEditorWithInitialBalanceVC(account: Account) {
        let accountEditorVC = AccountEditorViewController()
        accountEditorVC.parentAccount = account
        self.navigationController?.pushViewController(accountEditorVC, animated: true)
    }

    private func goToRootAccountEditorVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addAccountVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.addAccountVC) as? RootAccountEditorViewController else {return} // swiftlint:disable:this line_length
        addAccountVC.isUserHasPaidAccess = isUserHasPaidAccess
        self.navigationController?.pushViewController(addAccountVC, animated: true)
    }
}

// MARK: - Helper methods
extension AccountNavigationViewController {
    private func errorHandlerMethod(error: Error) {
        var title = NSLocalizedString("Error", tableName: Constants.Localizable.accountNavigationVC, comment: "")
        if error as? AppError != nil {
            title = NSLocalizedString("Warning", tableName: Constants.Localizable.accountNavigationVC, comment: "")
        }
        let alert = UIAlertController(title: title, message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: Constants.Localizable.accountNavigationVC, comment: ""), style: .default))
        present(alert, animated: true, completion: nil)
    }

    private func showPurchaseOfferVC() {
        present(PurchaseOfferViewController(), animated: true, completion: nil)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension AccountNavigationViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

// MARK: - UISearchResultsUpdating
extension AccountNavigationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {return}
        dataProvider.search(text)
        tableView.reloadData()
    }
}
