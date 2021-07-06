//
//  CurrencyTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 11.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData

class CurrencyTableViewController: UITableViewController {
    
    private var context = CoreDataStack.shared.persistentContainer.viewContext
    
    var currencyIndexPath: IndexPath?
    var currency : Currency?
    
    var delegate : AccountEditorWithInitialBalanceViewController?
    lazy var fetchedResultsController : NSFetchedResultsController<Currency> = {
        let fetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: "Currency")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "code", cacheName: nil)
        return frc
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if delegate != nil {
        self.navigationItem.title = NSLocalizedString("Currency", comment: "")
        }
        else {
            self.navigationItem.title = NSLocalizedString("Change accounting currency", comment: "")
        }
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        }
        catch let error{
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell_ID", for: indexPath) as! CurrencyTableViewCell
        let fetchedCurrency = fetchedResultsController.object(at: indexPath) as Currency
        
        if delegate == nil {
            if fetchedCurrency.isAccounting {
                currency = fetchedCurrency
                currencyIndexPath = indexPath
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        }
        else {
            if currency == fetchedCurrency {
                cell.accessoryType = .checkmark
            }
        }
        cell.codeLabel.text = fetchedCurrency.code!
        cell.nameLabel.text = fetchedCurrency.name!
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate == nil {
            do {
                let fetchedCurrency = fetchedResultsController.object(at: indexPath) as Currency
                guard let currencyIndexPath = currencyIndexPath else {
                    try CurrencyManager.changeAccountingCurrency(old: nil, new: fetchedCurrency, context: context)
                    try CoreDataStack.shared.saveContext(context)
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    return
                }
                if indexPath != currencyIndexPath {
                    try CurrencyManager.changeAccountingCurrency(old: currency, new: fetchedCurrency, context: context)
                    try CoreDataStack.shared.saveContext(context)
                }
                tableView.reloadRows(at: [currencyIndexPath,indexPath], with: .automatic)
            }
            catch let error{
                if let error = error as? CurrencyError, error == .thisCurrencyAlreadyUsedInTransaction {
                    let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Current accounting currency already used in transaction where one of accounts has different currency. To avoid this warnings please delete this transaction", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        else {
            delegate?.currency = fetchedResultsController.object(at: indexPath) as Currency
            self.navigationController?.popViewController(animated: true)
        }
    }
}
