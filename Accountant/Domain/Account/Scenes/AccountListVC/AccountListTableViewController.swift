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
    var environment: Environment = .prod

    var coreDataStack = CoreDataStack.shared
    var context: NSManagedObjectContext!

    var delegate: AccountListViewController!

    var account: Account?
    var currency: Currency!
    var showHiddenAccounts: Bool = false
    var listOfAccountsToShow: [AccountData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: Constants.Cell.accountTableViewCell)
    }

    func updateSourceTable() throws {
        delegate.updateUI()
    }

    func getVCUsedForPop() -> UIViewController? {
        return self.delegate.parent // because self.delegate isn't in navigationStack
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfAccountsToShow.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.accountTableViewCell, for: indexPath) as! AccountTableViewCell // swiftlint:disable:this force_cast line_length
        cell.updateCellForData(listOfAccountsToShow[indexPath.row], currency: currency)
        return cell
    }

    // swiftlint:disable line_length
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                      message: NSLocalizedString("This value is subtracted from the total amount and pie chart.\nAccount amount cannot be less than zero.\nPlease check transactions on this account", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                      style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func errorHandlerMethod(error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: "\(error.localizedDescription)",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                      style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
