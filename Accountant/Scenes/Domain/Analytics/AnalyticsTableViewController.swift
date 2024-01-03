//
//  AnalyticsTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 19.08.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import Charts
import CoreData

class AnalyticsTableViewController: UITableViewController {

    var presentingCurrency: Currency!
    var account: Account?
    var dateInterval: DateInterval?
    var sortCategoryBy: SortCategoryType = .nineToZero
    var dateComponent: Calendar.Component = .day
    var listOfAccountsToShow: [AccountData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        presentingCurrency = CurrencyHelper.getAccountingCurrency(context: CoreDataStack.shared.persistentContainer.viewContext)! // swiftlint:disable:this line_length
        tableView.register(AnalyticTableViewCell.self, forCellReuseIdentifier: Constants.Cell.analyticsCell1)
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: Constants.Cell.accountTableViewCell)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfAccountsToShow.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if account?.path == LocalizationManager.getLocalizedName(.money) {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.accountTableViewCell, for: indexPath) as! AccountTableViewCell // swiftlint:disable:this force_cast line_length
            cell.updateCellForData(listOfAccountsToShow[indexPath.row], currency: presentingCurrency)
            return cell
        } else {
            let cell: AnalyticTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.analyticsCell1, for: indexPath) as! AnalyticTableViewCell // swiftlint:disable:this force_cast line_length
            cell.configureCell(for: listOfAccountsToShow[indexPath.row], account: account!,
                               accountingCurrency: presentingCurrency)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                      message: NSLocalizedString("This value is subtracted from the total amount and pie chart.\nCategory amount cannot be less than zero.\nPlease check transactions on this category", comment: ""), // swiftlint:disable:this line_length
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                      style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedAccount = listOfAccountsToShow[indexPath.row].account,
           !selectedAccount.childrenList.isEmpty, selectedAccount != account {
            let analyticsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.analyticsVC) as! AnalyticsViewController // swiftlint:disable:this force_cast line_length
            analyticsVC.account = selectedAccount
            analyticsVC.sortCategoryBy = sortCategoryBy
            analyticsVC.dateComponent = dateComponent
            analyticsVC.transferedDateInterval = dateInterval
            self.navigationController?.pushViewController(analyticsVC, animated: true)
        }
    }
}
