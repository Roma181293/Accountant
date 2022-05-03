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

    @IBOutlet weak var tableView: UITableView!
    var isUserHasPaidAccess: Bool = false
    let coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext
    var environment = Environment.prod
    var resultSearchController = UISearchController()

    private lazy var dataProvider: TransactionListProvider = {
        return TransactionListProvider(with: coreDataStack.persistentContainer, fetchedResultsControllerDelegate: self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let environment = coreDataStack.activeEnviroment() {
            self.environment = environment
        }

        addButtonToViewController()
        // Set black color under cells in dark mode
        let backView = UIView(frame: self.tableView.bounds)
        backView.backgroundColor = .systemBackground
        self.tableView.backgroundView = backView

        reloadProAccessData()

        tableView.register(TransactionCell.self,
                           forCellReuseIdentifier: Constants.Cell.complexTransactionCell)

        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.obscuresBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            tableView.tableHeaderView = controller.searchBar
            return controller
        })()

        // adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.environmentDidChange),
                                               name: .environmentDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)

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

        self.tabBarController?.navigationItem.title = NSLocalizedString("Transactions", comment: "")
        if isUserHasPaidAccess == false {
            let item = UIBarButtonItem(title: NSLocalizedString("Get PRO", comment: ""),
                                       style: .plain,
                                       target: self,
                                       action: #selector(self.showPurchaseOfferVC))
            self.tabBarController?.navigationItem.rightBarButtonItem = item
        }
        if BankAccount.hasActiveBankAccounts(context: context) {
            let item = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(self.syncStatmentsData))
            self.tabBarController?.navigationItem.leftBarButtonItem = item
        }
        context.rollback()   // needs to avoid fatal error when user add transactionItem wo account and click <Back
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

    @objc func syncStatmentsData() {
        let backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        StatementLoadingService.loadStatments(context: backgroundContext,
                                              compliting: {(success, error) in
            if let success = success, success == true {
                self.fetchData()
            } else if let error = error {
                self.errorHandler(error: error)
            }
        })
    }

    @objc func showPurchaseOfferVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let purchaseOfferVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferVC) as? PurchaseOfferViewController else {return} // swiftlint:disable:this line_length
        self.present(purchaseOfferVC, animated: true, completion: nil)
    }

    private func fetchData() {
        do {
            try dataProvider.fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                          message: "\(error.localizedDescription)",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                          style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc func addTransaction(_ sender: UIButton!) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if UserProfile.isUseMultiItemTransaction(environment: environment) {
            guard let transactioEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.complexTransactionEditorVC) as? ComplexTransactionEditorViewController else {return} // swiftlint:disable:this line_length
            self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        } else {
            self.navigationController?.pushViewController(SimpleTransactionEditorViewController(), animated: true)
        }
    }

    @objc func environmentDidChange() {
        // reset context and fetchedResultsController
        context = CoreDataStack.shared.persistentContainer.viewContext
        if let environment = coreDataStack.activeEnviroment() {
            self.environment = environment
        }
        dataProvider = TransactionListProvider(with: coreDataStack.persistentContainer, fetchedResultsControllerDelegate: self)

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

    @objc func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            } else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
                UserProfile.useMultiItemTransaction(false, environment: self.environment)
            }
        }
    }

    private func addButtonToViewController() {
        let addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70 ,
                                                               y: self.view.frame.height - 150),
                                               size: CGSize(width: 68, height: 68)))
        view.addSubview(addButton)

        addButton.translatesAutoresizingMaskIntoConstraints = false
        let standardSpacing: CGFloat = -40.0
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -(89-49)),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: standardSpacing),
            addButton.heightAnchor.constraint(equalToConstant: 68),
            addButton.widthAnchor.constraint(equalToConstant: 68)
        ])

        addButton.backgroundColor = Colors.Main.confirmButton
        addButton.layer.cornerRadius = 34
        addButton.layer.shadowColor = UIColor.gray.cgColor
        addButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        addButton.layer.shadowOpacity = 0.5
        addButton.layer.shadowRadius = 3
        addButton.layer.masksToBounds =  false

        if let image = UIImage(systemName: "plus") {
            addButton.setImage(image, for: .normal)
        }
        addButton.addTarget(self, action: #selector(TransactionListViewController.addTransaction(_:)),
                            for: .touchUpInside)
    }

    func errorHandler(error: Error) {
        var title = NSLocalizedString("Error", comment: "")
        if error is AppError {
            title = NSLocalizedString("Warning", comment: "")
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
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if transaction.itemsList.count > 2 || UserProfile.isUseMultiItemTransaction(environment: environment) {
            guard let transactioEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.complexTransactionEditorVC) as? ComplexTransactionEditorViewController else {return} // swiftlint:disable:this line_length
            transactioEditorVC.transaction = transaction
            self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        } else if transaction.applied == false || UserProfile.isUseMultiItemTransaction(environment: environment) {
            guard let transactioEditorVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.complexTransactionEditorVC) as? ComplexTransactionEditorViewController else {return} // swiftlint:disable:this line_length
            transactioEditorVC.transaction = transaction
            transactioEditorVC.mode = .editDraft
            self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        } else {
            let transactioEditorVC = SimpleTransactionEditorViewController()
            transactioEditorVC.transaction = transaction
            self.navigationController?.pushViewController(transactioEditorVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { // swiftlint:disable:this function_body_length line_length
        let delete = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Delete", comment: "")) { (_, _, complete) in
            let alert = UIAlertController(title: NSLocalizedString("Delete", comment: ""),
                                          message: NSLocalizedString("Do you want to delete transaction?", comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                                          style: .destructive,
                                          handler: {(_) in

                self.dataProvider.deleteTransaction(at: indexPath)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")

        let duplicate = UIContextualAction(style: .normal,
                                           title: NSLocalizedString("Duplicate", comment: "")) { _, _, complete in
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
        if searchController.searchBar.text!.count != 0 {
            let predicate = NSPredicate(format: "\(Schema.Transaction.items).\(Schema.TransactionItem.account).\(Schema.Account.path) CONTAINS[c] %@ || comment CONTAINS[c] %@",
                                        argumentArray: [searchController.searchBar.text!,
                                                        searchController.searchBar.text!])
            dataProvider.fetchedResultsController.fetchRequest.predicate = predicate
        } else {
            dataProvider.fetchedResultsController.fetchRequest.predicate = nil
        }
        fetchData()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TransactionListViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
