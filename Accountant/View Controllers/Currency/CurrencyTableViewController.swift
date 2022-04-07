//
//  CurrencyTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 11.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import CoreData

protocol CurrencyReceiverDelegate {
    func setCurrency(_ selectedCurrency: Currency)
}
enum CurrencyTVCMode {
    case setAccountingCurrency
    case setCurrency
}
class CurrencyTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
    
    var currencyIndexPath: IndexPath?
    var currency : Currency?
    var mode: CurrencyTVCMode = .setCurrency
    
    var delegate : CurrencyReceiverDelegate?
    lazy var fetchedResultsController : NSFetchedResultsController<Currency> = {
        let fetchRequest : NSFetchRequest<Currency> = NSFetchRequest<Currency>(entityName: "Currency")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "isAccounting", ascending: false), NSSortDescriptor(key: "code", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
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
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.currencyCell, for: indexPath) as! CurrencyTableViewCell
        let fetchedCurrency = fetchedResultsController.object(at: indexPath) as Currency
        
        if let delegate = delegate {
            if mode == .setAccountingCurrency {
                if fetchedCurrency.isAccounting {
                    currency = fetchedCurrency
                    currencyIndexPath = indexPath
                    delegate.setCurrency(fetchedCurrency)
                    cell.accessoryType = .checkmark
                }
                else {
                    cell.accessoryType = .none
                }
            }
            else if mode == .setCurrency {
                if currency === fetchedCurrency {
                    cell.accessoryType = .checkmark
                }
                else {
                    cell.accessoryType = .none
                }
            }
        }
            cell.codeLabel.text = fetchedCurrency.code
            if let name = fetchedCurrency.name  {
                cell.nameLabel.text = name
            }
            else {
                cell.nameLabel.text = NSLocalizedString(fetchedCurrency.code, comment: "")
            }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {return}
        if mode == .setAccountingCurrency {

            do {
                let fetchedCurrency = fetchedResultsController.object(at: indexPath) as Currency
                guard let currencyIndexPath = currencyIndexPath else {
                    try Currency.changeAccountingCurrency(old: nil, new: fetchedCurrency, context: context)
                    try CoreDataStack.shared.saveContext(context)
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    delegate.setCurrency(fetchedCurrency)
                    return
                }
                if indexPath != currencyIndexPath {
                    try Currency.changeAccountingCurrency(old: currency, new: fetchedCurrency, context: context)
                    try CoreDataStack.shared.saveContext(context)
                }
                else {
                    delegate.setCurrency(fetchedCurrency)
                }
                tableView.reloadRows(at: [currencyIndexPath,indexPath], with: .automatic)
            }
            catch let error{
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel))
                self.present(alert, animated: true, completion: nil)
                
            }
         
        }
        else if mode == .setCurrency {
            delegate.setCurrency(fetchedResultsController.object(at: indexPath) as Currency)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
