//
//  TransactionListViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 05.06.2022.
//  
//

import UIKit

class TransactionListViewController: UIViewController {

    var output: TransactionListViewOutput?

    private var needHideSearchBar = true

    @IBOutlet weak var tableView: UITableView!

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.loadViewIfNeeded()
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.enablesReturnKeyAutomatically = false
        controller.searchBar.returnKeyType = .done
        controller.searchBar.scopeButtonTitles = [NSLocalizedString("All",
                                                                    tableName: Constants.Localizable.transactionList,
                                                                    comment: ""),
                                                  NSLocalizedString("Applied",
                                                                    tableName: Constants.Localizable.transactionList,
                                                                    comment: ""),
                                                  NSLocalizedString("Approved",
                                                                    tableName: Constants.Localizable.transactionList,
                                                                    comment: ""),
                                                  NSLocalizedString("Drafts",
                                                                    tableName: Constants.Localizable.transactionList,
                                                                    comment: "")]
        return controller
    }()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self

        configureCreateTransactionButton()

        tableView.register(TransactionCell.self, forCellReuseIdentifier: Constants.Cell.complexTransactionCell)

        // Set black color under cells in dark mode
        let backView = UIView(frame: self.tableView.bounds)
        backView.backgroundColor = .systemBackground
        self.tableView.backgroundView = backView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.tabBarController?.navigationItem.searchController = searchController
        self.tabBarController?.navigationItem.hidesSearchBarWhenScrolling = true

        output?.viewWillAppear()

        let title = NSLocalizedString("Transactions",
                                      tableName: Constants.Localizable.transactionList,
                                      comment: "")
        self.tabBarController?.navigationItem.title = title

        needHideSearchBar = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if needHideSearchBar {
            searchController.isActive = false
            self.tabBarController?.navigationItem.searchController = nil
        }
    }

    @objc func addTransaction() {
        needHideSearchBar = false
        output?.createTransaction()
    }

    private func configureCreateTransactionButton() {
        let standardSpacing: CGFloat = -40.0
        view.addSubview(createTransactionButton)
        createTransactionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                        constant: standardSpacing).isActive = true
        createTransactionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                          constant: standardSpacing).isActive = true
        createTransactionButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
        createTransactionButton.heightAnchor.constraint(equalToConstant: 68).isActive = true

        createTransactionButton.addTarget(self, action: #selector(addTransaction),
                                          for: .touchUpInside)
    }
}

// MARK: - TransactionListViewInput
extension TransactionListViewController: TransactionListViewInput {
    func reloadData() {
        tableView.reloadData()
    }

    func configureView() {

    }

    func drawProAccessButton(isHidden: Bool) {
        if isHidden {
            self.tabBarController?.navigationItem.rightBarButtonItem = nil
        } else {
            let item = UIBarButtonItem(title: NSLocalizedString("Get PRO",
                                                                tableName: Constants.Localizable.transactionList,
                                                                comment: ""),
                                       style: .plain,
                                       target: self,
                                       action: #selector(self.proAcceessButtonDidClick))
            self.tabBarController?.navigationItem.rightBarButtonItem = item
        }
    }

    @objc func proAcceessButtonDidClick() {
        output?.proAcceessButtonDidClick()
    }

    func drawSyncStatmentsButton(isHidden: Bool) {
        if isHidden {
            self.tabBarController?.navigationItem.leftBarButtonItem = nil
        } else {
            let item = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(self.syncStatmentsButtonDidClick))
            self.tabBarController?.navigationItem.leftBarButtonItem = item
        }
    }

    @objc func syncStatmentsButtonDidClick() {
        output?.syncStatmentsButtonDidClick()
    }

    // FIXME: move method to the responsible class. TabBarController
    func drawTabBarBadge(isHidden: Bool) {
        guard let tabBarItem = tabBarController?.tabBar.items else {return}
        for (index, item) in tabBarItem.enumerated() {
            guard index != tabBarItem.count - 1 else {return}
            if isHidden {
                item.badgeValue = nil
            } else {
                item.badgeValue = "Test"
            }
        }
    }
}

// MARK: - UISearchResultsUpdating
extension TransactionListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {return}

        var statusFilter: TransactionListWorker.TransactionStatusFilter

        switch searchController.searchBar.selectedScopeButtonIndex {
        case 1: statusFilter = .applied
        case 2: statusFilter = .approved
        case 3: statusFilter = .draft
        default: statusFilter = .all
        }

        output?.search(text: searchText, statusFilter: statusFilter)
    }
}

// MARK: - UITableViewDataSource
extension TransactionListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return output?.numberOfSections() ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output?.numberOfRowsInSection(section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.complexTransactionCell,
                                                 for: indexPath) as! TransactionCell // swiftlint:disable:this force_cast line_length
        guard let transaction = output?.transactionAt(indexPath) else {return cell}
        cell.setTransaction(transaction)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TransactionListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        needHideSearchBar = false
        output?.editTransaction(at: indexPath)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { // swiftlint:disable:this line_length
        guard let output = output else {return nil}
        return UISwipeActionsConfiguration(actions: [output.deleteTransactionAction(at: indexPath),
                                                     output.duplicateTransactionAction(at: indexPath)])
    }
}
