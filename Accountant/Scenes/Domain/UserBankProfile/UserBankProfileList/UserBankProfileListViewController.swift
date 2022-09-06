//
//  UserBankProfileListViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 19.01.2022.
//

import UIKit
import CoreData

protocol UserBankProfileListView: AnyObject {
    func configureView()
    func reloadData()
}

class UserBankProfileListViewController: UITableViewController {

    var presenter: UserBankProfileListPresenterProtocol!
    let configurator: UserBankProfileListConfiguratorProtocol = UserBankProfileListConfigurator()

    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(with: self)
        presenter.configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    @objc func addUserBankProfile() {
        self.navigationController?.pushViewController(MonobankUBPViewController(), animated: true)
    }

    func reloadData() {
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfUBPs(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fetchedItem = presenter.ubpAt(indexPath)
        let cell = UITableViewCell(style: .value1, reuseIdentifier: Constants.Cell.userBankProfileCell)
        cell.textLabel?.text = fetchedItem.name
        cell.detailTextLabel?.text = fetchedItem.keeper?.name ?? ""
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.tableViewDidSelectRowAt(indexPath)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [presenter.deleteAction(for: indexPath),
                                                     presenter.changeActiveStatus(for: indexPath)])
    }
}

extension UserBankProfileListViewController: UserBankProfileListView {
    func configureView() {
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cell.userBankProfileCell)
        self.navigationItem.title = NSLocalizedString("Bank profiles",
                                                      tableName: Constants.Localizable.userBankProfileListVC,
                                                      comment: "")

        let addButton = UIBarButtonItem(title: "+", style: .plain, target: self,
                                        action: #selector(self.addUserBankProfile))
        addButton.image = UIImage(systemName: "plus")
        self.navigationItem.rightBarButtonItem = addButton
    }
}
