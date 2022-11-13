//
//  KeeperViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import UIKit
import CoreData

protocol KeeperReceiverDelegate: AnyObject {
    func setKeeper(_ keeper: Keeper?)
}

class KeeperViewController: UITableViewController {

    var persistentContainer = CoreDataStack.shared.persistentContainer
    var delegate: KeeperReceiverDelegate?

    var mode: KeeperProvider.Mode = .nonCash
    var keeper: Keeper?

    private lazy var dataProvider: KeeperProvider = {
        let provider = KeeperProvider(with: persistentContainer, fetchedResultsControllerDelegate: self, mode: mode)
        return provider
    }()

    private var alertActionsToEnable: [UIAlertAction] = [] // to input validation

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cell.keeperCell)
        if delegate != nil {
            if mode == .person {
                self.navigationItem.title = NSLocalizedString("Persons",
                                                              tableName: Constants.Localizable.keeperVC,
                                                              comment: "")
            } else if mode == .bank {
                self.navigationItem.title = NSLocalizedString("Banks",
                                                              tableName: Constants.Localizable.keeperVC,
                                                              comment: "")
            } else if mode == .nonCash {
                self.navigationItem.title = NSLocalizedString("Banks & Persons",
                                                              tableName: Constants.Localizable.keeperVC,
                                                              comment: "")
            }
            let addButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.addKeeper))
            addButton.image = UIImage(systemName: "plus")
            self.navigationItem.rightBarButtonItem = addButton
        }
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate
extension KeeperViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataProvider.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fetchedItem = dataProvider.fetchedResultsController.object(at: indexPath)
        let cell = UITableViewCell(style: .value1, reuseIdentifier: Constants.Cell.keeperCell)
        cell.textLabel?.text = fetchedItem.name
        cell.detailTextLabel?.text = fetchedItem.type.toEmoji()
        if let keeper = keeper, keeper.id == fetchedItem.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {return}
        delegate.setKeeper(dataProvider.fetchedResultsController.object(at: indexPath))
        self.navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { // swiftlint:disable:this function_body_length line_length
        let delete = UIContextualAction(style: .destructive,
                                        title: NSLocalizedString("Delete",
                                                                 tableName: Constants.Localizable.keeperVC,
                                                                 comment: "")) { (_, _, complete) in
            let alert = UIAlertController(title: NSLocalizedString("Delete",
                                                                   tableName: Constants.Localizable.keeperVC,
                                                                   comment: ""),
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",
                                                                   tableName: Constants.Localizable.keeperVC,
                                                                   comment: ""),
                                          style: .destructive,
                                          handler: {(_) in
                if self.keeper?.id == self.dataProvider.fetchedResultsController.object(at: indexPath).id {
                    self.keeper = nil
                    self.delegate?.setKeeper(self.keeper)
                }
                self.dataProvider.deleteKeeper(at: indexPath)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                                   tableName: Constants.Localizable.keeperVC,
                                                                   comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")

        let rename = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Rename",
                                                                 tableName: Constants.Localizable.keeperVC,
                                                                 comment: "")) { _, _, complete in
            let alert = UIAlertController(title: NSLocalizedString("Rename",
                                                                   tableName: Constants.Localizable.keeperVC,
                                                                   comment: ""),
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = NSLocalizedString("New name",
                                                          tableName: Constants.Localizable.keeperVC,
                                                          comment: "")
                textField.text = self.dataProvider.fetchedResultsController.object(at: indexPath).name
                textField.addTarget(self, action: #selector(type(of: self).textChanged(_:)), for: .editingChanged)
            }

            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                                   tableName: Constants.Localizable.keeperVC,
                                                                   comment: ""),
                                          style: .default,
                                          handler: { _ in
                self.alertActionsToEnable.removeAll()
            }))
            self.present(alert, animated: true, completion: nil)

            let save = UIAlertAction(title: NSLocalizedString("Save",
                                                              tableName: Constants.Localizable.keeperVC,
                                                              comment: ""),
                                       style: .default) { [self] _ in
                guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
                self.dataProvider.renameKeeper(at: indexPath, newName: name)
                self.delegate?.setKeeper(self.keeper)
            }
            save.isEnabled = false
            alert.addAction(save)
            self.alertActionsToEnable.append(save)
            complete(true)
        }
        rename.backgroundColor = .systemBlue
        rename.image = UIImage(systemName: "pencil")

        let selectedKeeper = dataProvider.fetchedResultsController.object(at: indexPath)
        var allowedActions: [UIContextualAction] = []
        if selectedKeeper.accountsList.isEmpty && selectedKeeper.createdByUser == true {
            allowedActions.append(delete)
        }
        if selectedKeeper.createdByUser == true {
            allowedActions.append(rename)
        }

        let configuration: UISwipeActionsConfiguration? = UISwipeActionsConfiguration(actions: allowedActions)
        return configuration
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension KeeperViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

extension KeeperViewController {
    @objc func addKeeper() {
        var title = NSLocalizedString("Add bank or person",
                                       tableName: Constants.Localizable.keeperVC,
                                       comment: "")
        if mode == .bank {
            title = NSLocalizedString("Add bank",
                                           tableName: Constants.Localizable.keeperVC,
                                           comment: "")
        } else if mode == .person {
            title = NSLocalizedString("Add person",
                                           tableName: Constants.Localizable.keeperVC,
                                           comment: "")
        }
        let alert = UIAlertController(title: title,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("Name", tableName: Constants.Localizable.keeperVC, comment: "")
            textField.addTarget(self, action: #selector(type(of: self).textChanged(_:)), for: .editingChanged)
        }

        if mode == .bank || mode == .nonCash {
            var title = NSLocalizedString("Add bank", tableName: Constants.Localizable.keeperVC, comment: "")
            if mode == .bank {
                title = NSLocalizedString("Add", tableName: Constants.Localizable.keeperVC, comment: "")
            }
            let addBank = UIAlertAction(title: title,
                                        style: .default) { [self]_ in
                guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
                self.dataProvider.addKeeper(name: name, type: .bank, context: self.persistentContainer.viewContext)
            }
            addBank.isEnabled = false
            alert.addAction(addBank)
            alertActionsToEnable.append(addBank)
        }

        if mode == .person || mode == .nonCash {
            var title = NSLocalizedString("Add person", tableName: Constants.Localizable.keeperVC, comment: "")
            if mode == .person {
                title = NSLocalizedString("Add", tableName: Constants.Localizable.keeperVC, comment: "")
            }
            let addPerson = UIAlertAction(title: title,
                                          style: .default) { [self]_ in
                guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
                self.dataProvider.addKeeper(name: name, type: .person, context: self.persistentContainer.viewContext)
            }
            addPerson.isEnabled = false
            alert.addAction(addPerson)
            alertActionsToEnable.append(addPerson)
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                               tableName: Constants.Localizable.keeperVC,
                                                               comment: ""),
                                      style: .default,
                                      handler: { _ in
            self.alertActionsToEnable.removeAll()
        }))
        present(alert, animated: true, completion: nil)
    }

    @objc func textChanged(_ sender: UITextField) {
        guard let keeperName = sender.text, keeperName.count > 1 else {
            alertActionsToEnable.forEach({$0.isEnabled = false})
            return
        }
        let numberOfKeepers = dataProvider.numberOfKeepers(with: keeperName)
        alertActionsToEnable.forEach({$0.isEnabled = (numberOfKeepers == 0)})
    }
}
