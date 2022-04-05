//
//  ExchangeTableViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 12.01.2022.
//

import UIKit
import CoreData

class ExchangeTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
    
    var exchange: Exchange?
    
    var accountingCurrency: Currency!
    
    lazy var fetchedResultsController : NSFetchedResultsController<Exchange> = {
        let fetchRequest : NSFetchRequest<Exchange> = NSFetchRequest<Exchange>(entityName: Exchange.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cell.exchangeCell)
        
        //            if delegate != nil {
       
        
        //                let addButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.addHolder))
        //                addButton.image = UIImage(systemName: "plus")
        //                self.navigationItem.rightBarButtonItem = addButton
        //            }
        if exchange == nil {
            self.navigationItem.title = NSLocalizedString("Exchange rates", comment: "")
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
        if let exchange = exchange, let date = exchange.date {
            accountingCurrency = Currency.getAccountingCurrency(context: context)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            self.navigationItem.title = dateFormatter.string(from: date)
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let exchange = exchange {
            return exchange.rates!.allObjects.count
        }
        else {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.exchangeCell, for: indexPath)
        
        if let exchange = exchange {
            guard let rates = exchange.rates else {return cell}
            let rate = (rates.allObjects as! [Rate])[indexPath.row]
            cell.textLabel?.text = "1 " + rate.currency!.code! + " = " + String(rate.amount) + " " + accountingCurrency.code!
            cell.detailTextLabel?.text = String(rate.amount)
        }
        else {
            let fetchedItem = fetchedResultsController.object(at: indexPath) as Exchange
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            cell.textLabel?.text = dateFormatter.string(from: fetchedItem.date!)
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = String(fetchedItem.rates?.count ?? 0)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if exchange == nil {
            let vc = ExchangeTableViewController()
            vc.exchange = fetchedResultsController.object(at: indexPath)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func errorHandler(error : Error) {
        if error is AppError {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { [self](_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
