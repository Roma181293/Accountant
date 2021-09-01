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
    
    //private let coreDataStack = CoreDataStack.shared
   // private let calendar = Calendar.current
    
    var accountingCurrency : Currency!
    var account : Account?
    var dateInterval : DateInterval?
    var sortCategoryBy : SortCategoryType = .nineToZero
    var dateComponent : Calendar.Component = .day
    var listOfAccountsToShow : [AccountData] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountingCurrency = CurrencyManager.getAccountingCurrency(context: CoreDataStack.shared.persistentContainer.viewContext)!
        
        tableView.register(AnalyticTableViewCell.self, forCellReuseIdentifier: Constants.Cell.analyticsCell1)
    }
    
    
    //MARK: - TableView Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listOfAccountsToShow.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AnalyticTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.analyticsCell1, for: indexPath) as! AnalyticTableViewCell
        cell.configureCell(for: listOfAccountsToShow[indexPath.row], account: account!, accountingCurrency: accountingCurrency)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("Warning",comment: ""), message: NSLocalizedString("Amount excluded from total amount in pichart.\nAccount amount cannot be less zero.\nPlease check transaction with this account.",comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectedAccount = listOfAccountsToShow[indexPath.row].account,
           let children = selectedAccount.children,
           selectedAccount != account &&
           children.count > 0 {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.analyticsViewController) as! AnalyticsViewController
            vc.account = selectedAccount
            vc.sortCategoryBy = sortCategoryBy
            vc.dateComponent = dateComponent
            vc.transferedDateInterval = dateInterval
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
