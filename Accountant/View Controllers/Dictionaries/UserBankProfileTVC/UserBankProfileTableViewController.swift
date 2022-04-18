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

    lazy var fetchedResultsController: NSFetchedResultsController<UserBankProfile> = {
        let fetchRequest = UserBankProfile.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context,
                                          sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Cell.userBankProfileCell)
        self.navigationItem.title = NSLocalizedString("Bank profiles",
                                                      tableName: Constants.Localizable.userBankProfileTVC,
                                                      comment: "")

        let addButton = UIBarButtonItem(title: "+", style: .plain, target: self,
                                        action: #selector(self.addUserBankProfile))
        addButton.image = UIImage(systemName: "plus")
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch let error {
            errorHandler(error: error)
        }
    }

    @objc func addUserBankProfile() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let monobankVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.monobankVC) as? MonobankViewController else {return} // swiftlint:disable:this line_length
        self.navigationController?.pushViewController(monobankVC, animated: true)
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
        let cell = UITableViewCell(style: .value1, reuseIdentifier: Constants.Cell.userBankProfileCell)
        cell.textLabel?.text = fetchedItem.name
        cell.detailTextLabel?.text = fetchedItem.keeper?.name ?? ""
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bankAccountVC = BankAccountTableViewController()
        bankAccountVC.userBankProfile = fetchedResultsController.object(at: indexPath)
        self.navigationController?.pushViewController(bankAccountVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { // swiftlint:disable:this function_body_length line_length
        let selectedUBP = fetchedResultsController.object(at: indexPath) as UserBankProfile

        let changeActiveStatus = UIContextualAction(style: .normal, title: nil) { (_, _, complete) in
            var title = NSLocalizedString("Activate", tableName: Constants.Localizable.userBankProfileTVC, comment: "")
            var message = NSLocalizedString("Do you want activate this bank profile in the app? Please note that you need manually activate each bank account for this profile", tableName: Constants.Localizable.userBankProfileTVC, comment: "") // swiftlint:disable:this line_length
            if selectedUBP.active {
                title = NSLocalizedString("Deactivate", tableName: Constants.Localizable.userBankProfileTVC,
                                          comment: "")
                message = NSLocalizedString("Do you want deactivate this bank profile in the app?",
                                            tableName: Constants.Localizable.userBankProfileTVC,
                                            comment: "")
            }

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",
                                                                   tableName: Constants.Localizable.userBankProfileTVC,
                                                                   comment: ""),
                                          style: .default, handler: { (_) in
                do {
                    selectedUBP.changeActiveStatus()
                    try CoreDataStack.shared.saveContext(self.context)
                    tableView.reloadData()
                } catch let error {
                    self.errorHandler(error: error)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                                   tableName: Constants.Localizable.userBankProfileTVC,
                                                                   comment: ""),
                                          style: .cancel))
            self.present(alert, animated: true, completion: nil)
            complete(true)
        }

        if selectedUBP.active {
            changeActiveStatus.backgroundColor = .systemGray
            changeActiveStatus.image = UIImage(systemName: "eye.slash")
        } else {
            changeActiveStatus.backgroundColor = .systemIndigo
            changeActiveStatus.image = UIImage(systemName: "eye")
        }

        let delete = UIContextualAction(style: .normal, title: nil) { (_, _, complete) in

            let alert = UIAlertController(title: NSLocalizedString("Delete",
                                                                   tableName: Constants.Localizable.userBankProfileTVC,
                                                                   comment: ""),
                                          message: NSLocalizedString("Do you want delete this bank profile in the app? All transactions related to this bank profile will be kept. Please enter \"MyBudget: Finance keeper\" to confirm this action", tableName: Constants.Localizable.userBankProfileTVC, comment: ""), // swiftlint:disable:this line_length
                                          preferredStyle: .alert)

            alert.addTextField()
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes",
                                                                   tableName: Constants.Localizable.userBankProfileTVC,
                                                                   comment: ""),
                                          style: .default,
                                          handler: { [weak alert] (_) in
                do {
                    guard let alert = alert,
                          let textFields = alert.textFields,
                          let textField = textFields.first
                    else {return}
                    try selectedUBP.delete(consentText: textField.text!)
                    try CoreDataStack.shared.saveContext(self.context)
                    tableView.reloadData()
                } catch let error {
                    self.errorHandler(error: error)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                                   tableName: Constants.Localizable.userBankProfileTVC,
                                                                   comment: ""),
                                          style: .cancel))
            self.present(alert, animated: true, completion: nil)
            complete(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [delete, changeActiveStatus])
    }

    func errorHandler(error: Error) {
        if error is AppError {
            let alert = UIAlertController(title: NSLocalizedString("Warning",
                                                                   tableName: Constants.Localizable.userBankProfileTVC,
                                                                   comment: ""),
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                                   tableName: Constants.Localizable.userBankProfileTVC,
                                                                   comment: ""),
                                          style: .default,
                                          handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Error",
                                                                   tableName: Constants.Localizable.userBankProfileTVC,
                                                                   comment: ""),
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                                   tableName: Constants.Localizable.userBankProfileTVC,
                                                                   comment: ""),
                                          style: .default,
                                          handler: { [weak self](_) in
                self?.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
