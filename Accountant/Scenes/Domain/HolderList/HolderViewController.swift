//
//  HolderViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 20.04.2022.
//

import UIKit
import CoreData

protocol HolderReceiverDelegate: AnyObject {
    func setHolder(_ holder: Holder?) // optional for cases when user delete
}

class HolderViewController: UITableViewController {

    var persistentContainer = CoreDataStack.shared.persistentContainer
    var delegate: HolderReceiverDelegate?

    var holder: Holder?

    private lazy var dataProvider: HolderProvider = {
        let provider = HolderProvider(with: persistentContainer, fetchedResultsControllerDelegate: self)
        return provider
    }()

    private var alertActionsToEnable: [UIAlertAction] = [] // to input validation

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cell.holderCell)
        if delegate != nil {
            self.navigationItem.title = NSLocalizedString("Holders",
                                                              tableName: Constants.Localizable.holderVC,
                                                              comment: "")

            let addButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(self.addKeeper))
            addButton.image = UIImage(systemName: "plus")
            self.navigationItem.rightBarButtonItem = addButton
        }
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate
extension HolderViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataProvider.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fetchedItem = dataProvider.fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.holderCell, for: indexPath)
        cell.textLabel?.text = fetchedItem.icon + "   " + fetchedItem.name
        if let holder = holder, holder.id == fetchedItem.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {return}
        delegate.setHolder(dataProvider.fetchedResultsController.object(at: indexPath))
        self.navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { // swiftlint:disable:this function_body_length line_length

        let selectedHolder = self.dataProvider.fetchedResultsController.object(at: indexPath)

        let delete = UIContextualAction(style: .destructive,
                                        title: NSLocalizedString("Delete",
                                                                 tableName: Constants.Localizable.holderVC,
                                                                 comment: "")) { (_, _, complete) in
            let alert = UIAlertController(title: NSLocalizedString("Delete",
                                                                   tableName: Constants.Localizable.holderVC,
                                                                   comment: ""),
                                          message: String(format: NSLocalizedString("Do you want to delete %@ - %@?",
                                                                                    tableName: Constants.Localizable.holderVC,
                                                                                    comment: ""),
                                                          selectedHolder.icon,
                                                          selectedHolder.name),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",
                                                                   tableName: Constants.Localizable.holderVC,
                                                                   comment: ""),
                                          style: .destructive,
                                          handler: {(_) in
                if self.holder?.id == self.dataProvider.fetchedResultsController.object(at: indexPath).id {
                    self.holder = nil
                    self.delegate?.setHolder(self.holder)
                }
                self.dataProvider.deleteHolder(at: indexPath)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                                   tableName: Constants.Localizable.holderVC,
                                                                   comment: ""), style: .cancel))
            self.present(alert, animated: true, completion: nil)
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")

        let rename = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Edit",
                                                                 tableName: Constants.Localizable.holderVC,
                                                                 comment: "")) { _, _, complete in
            let alert = UIAlertController(title: NSLocalizedString("Edit",
                                                                   tableName: Constants.Localizable.holderVC,
                                                                   comment: ""),
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addTextField { textField in
                textField.tag = 1
                textField.placeholder = NSLocalizedString("New name",
                                                          tableName: Constants.Localizable.holderVC,
                                                          comment: "")
                textField.text = self.dataProvider.fetchedResultsController.object(at: indexPath).name
                textField.addTarget(self, action: #selector(type(of: self).textChanged(_:)), for: .editingChanged)
            }
            alert.addTextField { textField in
                textField.tag = 2
                textField.placeholder = NSLocalizedString("New icon, one symbol (Emoji)",
                                                          tableName: Constants.Localizable.holderVC,
                                                          comment: "")
                textField.text = self.dataProvider.fetchedResultsController.object(at: indexPath).icon
                textField.addTarget(self, action: #selector(type(of: self).textChanged(_:)), for: .editingChanged)
            }

            let saveAction = UIAlertAction(title: NSLocalizedString("Save",
                                                                    tableName: Constants.Localizable.holderVC,
                                                                    comment: ""),
                                        style: .default) { [self]_ in
                guard let name = alert.textFields?.first?.text, !name.isEmpty,
                let icon = alert.textFields?.last?.text, !icon.isEmpty else { return }
                self.dataProvider.editHolder(at: indexPath, newName: name, newIcon: icon)
            }
            saveAction.isEnabled = false
            alert.addAction(saveAction)
            self.alertActionsToEnable.append(saveAction)

            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                                   tableName: Constants.Localizable.holderVC,
                                                                   comment: ""),
                                          style: .default,
                                          handler: { _ in
                self.alertActionsToEnable.removeAll()
            }))
            self.present(alert, animated: true, completion: nil)
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
extension HolderViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

extension HolderViewController {
    @objc func addKeeper() {
        let alert = UIAlertController(title: NSLocalizedString("Add holder",
                                                               tableName: Constants.Localizable.holderVC,
                                                               comment: ""),
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.tag = 1
            textField.placeholder = NSLocalizedString("Name", tableName: Constants.Localizable.holderVC, comment: "")
            textField.addTarget(self, action: #selector(type(of: self).textChanged(_:)), for: .editingChanged)
        }
        alert.addTextField { textField in
            textField.tag = 2
            textField.placeholder = NSLocalizedString("Icon, one symbol (Emoji)",
                                                      tableName: Constants.Localizable.holderVC,
                                                      comment: "")
            textField.addTarget(self, action: #selector(type(of: self).textChanged(_:)), for: .editingChanged)
        }

        let addAction = UIAlertAction(title: NSLocalizedString("Add", tableName:
                                                                Constants.Localizable.holderVC,
                                                               comment: ""),
                                    style: .default) { [self]_ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty,
            let icon = alert.textFields?.last?.text, !icon.isEmpty else { return }
            self.dataProvider.addHolder(name: name, icon: icon, context: self.persistentContainer.viewContext)
        }
        addAction.isEnabled = false
        alert.addAction(addAction)
        alertActionsToEnable.append(addAction)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                               tableName: Constants.Localizable.holderVC,
                                                               comment: ""),
                                      style: .default,
                                      handler: { _ in
            self.alertActionsToEnable.removeAll()
        }))
        present(alert, animated: true, completion: nil)
    }

    @objc func textChanged(_ sender: UITextField) {
        if sender.tag == 1 {
            guard let holderName = sender.text, holderName.count > 1 else {
                alertActionsToEnable.forEach({$0.isEnabled = false})
                return
            }
            let numberOfHolders = dataProvider.numberOfHolders(withName: holderName)
            alertActionsToEnable.forEach({$0.isEnabled = (numberOfHolders == 0)})
        } else if sender.tag == 2 {
            guard let holderIcon = sender.text, holderIcon.count == 1 else {
                alertActionsToEnable.forEach({$0.isEnabled = false})
                return
            }
            let numberOfHolders = dataProvider.numberOfHolders(withIcon: holderIcon)
            alertActionsToEnable.forEach({$0.isEnabled = (numberOfHolders == 0)})
        }
    }
}
