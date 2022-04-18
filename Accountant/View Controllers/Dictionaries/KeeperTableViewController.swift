//
//  KeeperTableViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import UIKit
import CoreData

protocol KeeperReceiverDelegate: AnyObject {
    func setKeeper(_ selectedKeeper: Keeper)
}

class KeeperTableViewController: UITableViewController {

    enum Mode {
        case bank
        case person
        case nonCash
    }

    var context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext
    var keeper: Keeper?
    var delegate: KeeperReceiverDelegate?
    var bankIndexPath: IndexPath?
    var mode: Mode = .nonCash

    lazy var fetchedResultsController: NSFetchedResultsController<Keeper> = {
        let fetchRequest = Keeper.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.Keeper.name.rawValue, ascending: true)]
        switch mode {
        case .bank:
            fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.type.rawValue) == %i", KeeperType.bank.rawValue)
        case .person:
            fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.type.rawValue) == %i", KeeperType.person.rawValue)
        case .nonCash:
            fetchRequest.predicate = NSPredicate(format: "\(Schema.Keeper.type.rawValue) != %i", KeeperType.cash.rawValue)
        }
        fetchRequest.fetchBatchSize = 20
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil, cacheName: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cell.keeperCell)
        if delegate != nil {
            self.navigationItem.title = NSLocalizedString("Keeper", comment: "")
            let addButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.addKeeper))
            addButton.image = UIImage(systemName: "plus")
            self.navigationItem.rightBarButtonItem = addButton
        }
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch let error {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc func addKeeper() {
        let alert = UIAlertController(title: NSLocalizedString("Add keeper", comment: ""),
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.tag = 100
            textField.placeholder = NSLocalizedString("Name", comment: "")
            textField.delegate = alert
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add bank", comment: ""),
                                      style: .default,
                                      handler: { [weak alert] (_) in
            do {
                guard let alert = alert,
                      let textFields = alert.textFields,
                      let textField = textFields.first
                else {return}
                guard textField.text?.isEmpty == false else {throw KeeperError.emptyName}
                try Keeper.create(name: textField.text!, type: .bank, context: self.context)
                try CoreDataStack.shared.saveContext(self.context)
                try self.fetchedResultsController.performFetch()
                self.tableView.reloadData()
            } catch let error {
                self.errorHandler(error: error)
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add person", comment: ""),
                                      style: .default,
                                      handler: { [weak alert] (_) in
            do {
                guard let alert = alert,
                      let textFields = alert.textFields,
                      let textField = textFields.first
                else {return}
                guard textField.text?.isEmpty == false else {throw KeeperError.emptyName}
                try Keeper.create(name: textField.text!, type: .person, context: self.context)
                try CoreDataStack.shared.saveContext(self.context)
                try self.fetchedResultsController.performFetch()
                self.tableView.reloadData()
            } catch let error {
                self.errorHandler(error: error)
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        self.present(alert, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.keeperCell, for: indexPath)
        let fetchedItem = fetchedResultsController.object(at: indexPath) as Keeper
        cell.textLabel?.text = fetchedItem.name
        if keeper === fetchedItem {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {return}
        delegate.setKeeper(fetchedResultsController.object(at: indexPath) as Keeper)
        self.navigationController?.popViewController(animated: true)
    }

    func errorHandler(error: Error) {
        if error is AppError {
            let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                          message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                          message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                          style: .default,
                                          handler: { [self](_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
