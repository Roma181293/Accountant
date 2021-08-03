//
//  AccountManagerTableViewCell.swift
//  Accounting
//
//  Created by Roman Topchii on 26.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData
class AccountManagerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var accountIsHiddenSwitch: UISwitch!
    
    let coreDataStack = CoreDataStack.shared
    var account : Account!
    var tableView : AccountManagerTableViewController!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func updateCell(account: Account, tableView : AccountManagerTableViewController) {
        self.account = account
        self.tableView = tableView
        accountIsHiddenSwitch.isOn = !account.isHidden
        chooseAccessoryType()
        title.text = account.name
    }
    
    @IBAction func switchAccountIsHiddenStatus(_ sender: Any) {
        chooseAccessoryType()
        do {
            AccountManager.changeAccountIsHiddenStatus(account)
            try self.coreDataStack.saveContext(self.coreDataStack.persistentContainer.viewContext)
            try tableView.fetchedResultsController.performFetch()
            tableView.fetchData()
        }
        catch let error{
            print("Error",error)
        }
    }
    
    private func chooseAccessoryType() {
        if let children = account.children, children.count > 0{
            self.accessoryType = .disclosureIndicator
        }
        else {
            self.accessoryType = .none
        }
    }
}
