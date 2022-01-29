//
//  UserBankProfileTableViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 19.01.2022.
//

import UIKit
import CoreData

class UserBankProfileTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
    
    lazy var fetchedResultsController : NSFetchedResultsController<UserBankProfile> = {
        let fetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cell.userBankProfileCell)
        
        self.navigationItem.title = NSLocalizedString("Bank profiles", comment: "")
        
        let addButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.addUserBankProfile))
        addButton.image = UIImage(systemName: "plus")
        self.navigationItem.rightBarButtonItem = addButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @objc func addUserBankProfile() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.monobankVC) as! MonobankViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fetchedItem = fetchedResultsController.object(at: indexPath) as UserBankProfile
        
        let cell = UITableViewCell(style: .value1 , reuseIdentifier: Constants.Cell.userBankProfileCell)
        cell.textLabel?.text = fetchedItem.name
        cell.detailTextLabel?.text = fetchedItem.keeper?.name ?? ""
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = BankAccountTableViewController()
        vc.userBankProfile = fetchedResultsController.object(at: indexPath)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let selectedUBP = fetchedResultsController.object(at: indexPath) as UserBankProfile
   
        
        let changeActiveStatus = UIContextualAction(style: .normal, title: nil) { (contAct, view, complete) in
            var title = NSLocalizedString("Activate", comment: "")
            var message = NSLocalizedString("Do you want activate this bank profile in the app? Please note that you need manually activate each bank account for this profile",comment: "")
            if selectedUBP.active {
                title = NSLocalizedString("Deactivate", comment: "")
                message = NSLocalizedString("Do you want deactivate this bank profile in the app?",comment: "")
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .default, handler: { (_) in
                do{
                    UserBankProfileManager.changeActiveStatusFor(selectedUBP,context: self.context)
                    try CoreDataStack.shared.saveContext(self.context)
                    tableView.reloadData()
                }
                catch let error {
                    self.errorHandler(error: error)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            
            complete(true)
        }
      
        if selectedUBP.active {
            changeActiveStatus.backgroundColor = .systemGray
            changeActiveStatus.image = UIImage(systemName: "eye.slash")
        }
        else {
            changeActiveStatus.backgroundColor = .systemIndigo
            changeActiveStatus.image = UIImage(systemName: "eye")
        }
        
        let delete = UIContextualAction(style: .normal, title: nil) { (contAct, view, complete) in
           
            let alert = UIAlertController(title: NSLocalizedString("Delete", comment: ""), message: NSLocalizedString("Do you want delete this bank profile in the app? All transactions related to this bank profile will be kept. Please enter \"MyBudget: Finance keeper\" to confirm this action", comment: ""), preferredStyle: .alert)
            
            alert.addTextField()
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",comment: ""), style: .default, handler: { [weak alert] (_) in
                do{ guard let alert = alert,
                          let textFields = alert.textFields,
                          let textField = textFields.first
                    else {return}
                    try UserBankProfileManager.deleteUBP(selectedUBP, consentText: textField.text!, context: self.context)
                    try CoreDataStack.shared.saveContext(self.context)
                    tableView.reloadData()
                }
                catch let error {
                    self.errorHandler(error: error)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [delete,changeActiveStatus])
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
