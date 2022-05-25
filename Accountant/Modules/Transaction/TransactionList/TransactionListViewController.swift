//
//  TransactionListViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 04.03.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData
import Purchases

class TransactionListViewController: UIViewController {

    private var isUserHasPaidAccess: Bool = false
    private let coreDataStack = CoreDataStack.shared
    private var environment = Environment.prod
    private var resultSearchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.sizeToFit()
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        return controller
    }()

    @IBOutlet weak var tableView: UITableView!
    private let createTransactionButton: UIButton = {
        let addButton = UIButton()
        addButton.backgroundColor = Colors.Main.confirmButton
        addButton.layer.cornerRadius = 34
        addButton.layer.shadowColor = UIColor.gray.cgColor
        addButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        addButton.layer.shadowOpacity = 0.5
        addButton.layer.shadowRadius = 3
        addButton.layer.masksToBounds =  false
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        return addButton
    }()

    private lazy var dataProvider: TransactionListProvider = {
        return TransactionListProvider(with: coreDataStack.persistentContainer, fetchedResultsControllerDelegate: self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let environment = coreDataStack.activeEnviroment() {
            self.environment = environment
        }

        TransactionItem.clearItemsWOLinkToTransaction()

        reloadProAccessData()
        // adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.environmentDidChange),
                                               name: .environmentDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)

        // register cell
        tableView.register(TransactionCell.self, forCellReuseIdentifier: Constants.Cell.complexTransactionCell)

        // configure SearchBar
        tableView.tableHeaderView = resultSearchController.searchBar
        resultSearchController.searchResultsUpdater = self

        addCreateTransactionButton()

        // Set black color under cells in dark mode
        let backView = UIView(frame: self.tableView.bounds)
        backView.backgroundColor = .systemBackground
        self.tableView.backgroundView = backView

        // TabBarController badge manage
        guard let tabBarItem = tabBarController?.tabBar.items else {return}
        for (index, item) in tabBarItem.enumerated() {
            guard index != tabBarItem.count - 1 else {return}
            if coreDataStack.activeEnviroment() == .test {
                item.badgeValue = "Test"
            } else {
                item.badgeValue = nil
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.tabBarController?.navigationItem.title = NSLocalizedString("Transactions",
                                                                        tableName: Constants.Localizable.transactionListVC,
                                                                        comment: "")
        if isUserHasPaidAccess == false {
            let item = UIBarButtonItem(title: NSLocalizedString("Get PRO",
                                                                tableName: Constants.Localizable.transactionListVC,
                                                                comment: ""),
                                       style: .plain,
                                       target: self,
                                       action: #selector(self.showPurchaseOfferVC))
            self.tabBarController?.navigationItem.rightBarButtonItem = item
        }
        if BankAccount.hasActiveBankAccounts(context: coreDataStack.persistentContainer.viewContext) {
            let item = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(self.syncStatmentsData))
            self.tabBarController?.navigationItem.leftBarButtonItem = item
        }

        // needs to avoid fatal error when user add transactionItem wo account and click <Back
        coreDataStack.persistentContainer.viewContext.rollback()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        resultSearchController.dismiss(animated: true, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .environmentDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }

    @objc private func syncStatmentsData() {
        let backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        StatementLoadingService.loadStatments(context: backgroundContext,
                                              compliting: {(_, error) in
            if let error = error {
                self.errorHandler(error: error)
            }
        })
    }

    @objc private func showPurchaseOfferVC() {
        self.present(PurchaseOfferViewController(), animated: true, completion: nil)
    }

    @objc func addTransaction(_ sender: UIButton!) {
        if UserProfile.isUseMultiItemTransaction(environment: environment) {
            self.navigationController?.pushViewController(ComplexTransactionEditorViewController(), animated: true)
        } else {
            self.navigationController?.pushViewController(SimpleTransactionEditorViewController(), animated: true)
        }
    }

    @objc func environmentDidChange() {
        if let environment = coreDataStack.activeEnviroment() {
            self.environment = environment
        }
        dataProvider = TransactionListProvider(with: coreDataStack.persistentContainer,
                                               fetchedResultsControllerDelegate: self)

        // clear resultSearchController
        resultSearchController.searchBar.text = ""

        // TabBarController badge manage
        guard let tabBarItem = tabBarController?.tabBar.items else {return}
        for (index, item) in tabBarItem.enumerated() {
            guard index != tabBarItem.count - 1 else {return}
            if coreDataStack.activeEnviroment() == .test {
                item.badgeValue = "Test"
            } else {
                item.badgeValue = nil
            }
        }
    }

    @objc private func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            } else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
                UserProfile.useMultiItemTransaction(false, environment: self.environment)
            }
        }
    }

    private func addCreateTransactionButton() {
        let standardSpacing: CGFloat = -40.0
        view.addSubview(createTransactionButton)
        createTransactionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                        constant: standardSpacing).isActive = true
        createTransactionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                          constant: standardSpacing).isActive = true
        createTransactionButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
        createTransactionButton.heightAnchor.constraint(equalToConstant: 68).isActive = true

        createTransactionButton.addTarget(self, action: #selector(TransactionListViewController.addTransaction(_:)),
                                          for: .touchUpInside)
    }

    private func errorHandler(error: Error) {
        var title = NSLocalizedString("Error", tableName: Constants.Localizable.transactionListVC, comment: "")
        if error is AppError {
            title = NSLocalizedString("Warning", tableName: Constants.Localizable.transactionListVC, comment: "")
        }
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension TransactionListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.complexTransactionCell,
                                                 for: indexPath) as! TransactionCell // swiftlint:disable:this force_cast line_length
        let transaction = dataProvider.fetchedResultsController.object(at: indexPath) as Transaction
        cell.setTransaction(transaction)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transaction = dataProvider.fetchedResultsController.object(at: indexPath) as Transaction
        if transaction.itemsList.count != 2 || transaction.status != .applied || UserProfile.isUseMultiItemTransaction(environment: environment) {
            let transactioEditorVC = ComplexTransactionEditorViewController()
            transactioEditorVC.transaction = transaction
            if transaction.status != .applied {
                transactioEditorVC.mode = .editDraft
            }
            self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        } else {
            let transactioEditorVC = SimpleTransactionEditorViewController()
            transactioEditorVC.transaction = transaction
            self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { // swiftlint:disable:this line_length
        let delete = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Delete", tableName: Constants.Localizable.transactionListVC, comment: "")) { (_, _, complete) in
            let alert = UIAlertController(title: NSLocalizedString("Delete", tableName: Constants.Localizable.transactionListVC, comment: ""),
                                          message: NSLocalizedString("Do you want to delete transaction?", tableName: Constants.Localizable.transactionListVC, comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                                          style: .destructive,
                                          handler: {(_) in

                self.dataProvider.deleteTransaction(at: indexPath)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No",
                                                                   tableName: Constants.Localizable.transactionListVC,
                                                                   comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")

        let duplicate = UIContextualAction(style: .normal,
                                           title: NSLocalizedString("Duplicate",
                                                                    tableName: Constants.Localizable.transactionListVC,
                                                                    comment: "")) { _, _, complete in
            if self.isUserHasPaidAccess || self.coreDataStack.activeEnviroment() == .test {
                self.dataProvider.duplicateTransaction(at: indexPath)
            } else {
                self.showPurchaseOfferVC()
            }
            complete(true)
        }
        duplicate.backgroundColor = .systemBlue
        duplicate.image = UIImage(systemName: "doc.on.doc")

        return UISwipeActionsConfiguration(actions: [delete, duplicate])
    }
}

// MARK: - UISearchResultsUpdating
extension TransactionListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {return}
        dataProvider.search(text: text)
        tableView.reloadData()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TransactionListViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
