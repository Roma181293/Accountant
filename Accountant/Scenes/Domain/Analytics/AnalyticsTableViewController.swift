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

    var accountingCurrency: Currency!
    var account: Account?
    var dateInterval: DateInterval?
    var sortCategoryBy: SortCategoryType = .nineToZero
    var dateComponent: Calendar.Component = .day
    var listOfAccountsToShow: [AccountData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        accountingCurrency = CurrencyHelper.getAccountingCurrency(context: CoreDataStack.shared.persistentContainer.viewContext)! // swiftlint:disable:this line_length
        tableView.register(AnalyticTableViewCell.self, forCellReuseIdentifier: Constants.Cell.analyticsCell1)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfAccountsToShow.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AnalyticTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.analyticsCell1, for: indexPath) as! AnalyticTableViewCell // swiftlint:disable:this force_cast line_length
        cell.configureCell(for: listOfAccountsToShow[indexPath.row], account: account!,
                              accountingCurrency: accountingCurrency)
        return cell
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
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let analyticsVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.analyticsVC) as! AnalyticsViewController // swiftlint:disable:this force_cast line_length
            analyticsVC.account = selectedAccount
            analyticsVC.sortCategoryBy = sortCategoryBy
            analyticsVC.dateComponent = dateComponent
            analyticsVC.transferedDateInterval = dateInterval
            self.navigationController?.pushViewController(analyticsVC, animated: true)
        }
    }
}
