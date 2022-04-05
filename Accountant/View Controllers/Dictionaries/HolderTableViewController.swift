//
//  HolderTableViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import UIKit
import CoreData

protocol HolderReceiverDelegate {
    func setHolder(_ selectedHolder: Holder)
}

class HolderTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
    
    var holderIndexPath: IndexPath?
    var holder: Holder?
    
    var delegate: HolderReceiverDelegate?
    
    lazy var fetchedResultsController : NSFetchedResultsController<Holder> = {
        let fetchRequest : NSFetchRequest<Holder> = NSFetchRequest<Holder>(entityName: Holder.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cell.holderCell)
        
        if delegate != nil {
            self.navigationItem.title = NSLocalizedString("Holder", comment: "")
            
            let addButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.addHolder))
            addButton.image = UIImage(systemName: "plus")
            self.navigationItem.rightBarButtonItem = addButton
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
    
    @objc func addHolder() {
        let alert = UIAlertController(title: NSLocalizedString("Add Holder",comment: ""), message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.tag = 101
            textField.placeholder = NSLocalizedString("Icon",comment: "")
            textField.delegate = alert as! UITextFieldDelegate
        }
        alert.addTextField { (textField) in
            textField.tag = 100
            textField.placeholder = NSLocalizedString("Name",comment: "")
            textField.delegate = alert as! UITextFieldDelegate
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add",comment: ""), style: .default, handler: { [weak alert] (_) in
            
            do {
                guard let alert = alert,
                      let textFields = alert.textFields,
                      let iconTextField = textFields.first,
                      let nameTextField = textFields.last
                else {return}
                
                guard iconTextField.text?.isEmpty == false else {throw HolderError.emptyIcon}
                guard nameTextField.text?.isEmpty == false else {throw HolderError.emptyName}
                
                try Holder.create(name: nameTextField.text!, icon: iconTextField.text!, context: self.context)
                try CoreDataStack.shared.saveContext(self.context)
                try self.fetchedResultsController.performFetch()
                self.tableView.reloadData()
            }
            catch let error{
                print("Error",error)
                self.errorHandler(error: error)
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            print(count)
            return count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.holderCell, for: indexPath)
        let fetchedItem = fetchedResultsController.object(at: indexPath) as Holder
        
        cell.textLabel?.text = fetchedItem.icon! + "   " + fetchedItem.name!
        
        if holder === fetchedItem {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {return}
        delegate.setHolder(fetchedResultsController.object(at: indexPath) as Holder)
        self.navigationController?.popViewController(animated: true)
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
