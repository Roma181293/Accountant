//
//  AccountTypeNavigationViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 19.06.2022.
//

import UIKit

protocol AccountTypeReciverDelegate: AnyObject {
    func setAccountType(_ accountTypeId: UUID)
}

class AccountTypeNavigationViewController: UITableViewController {

    var delegate: AccountTypeReciverDelegate?
    var service: AccountTypeService

    private let localizetTableName = Constants.Localizable.accountTypeNavigation

    init(parentTypeId: UUID?) {
        service = AccountTypeService(with: CoreDataStack.shared.persistentContainer, parentTypeId: parentTypeId)
        super.init(style: .plain)
        service.provideData()
        service.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if delegate != nil {
            self.navigationItem.title = NSLocalizedString("Possible types",
                                                          tableName: localizetTableName,
                                                          comment: "")
        } else {
            if let parentType = service.parentType {
                self.navigationItem.title = parentType.name
            } else {
                self.navigationItem.title = NSLocalizedString("Type manager",
                                                              tableName: localizetTableName,
                                                              comment: "")
            }
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AccountType_Cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.numberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "AccountType_Cell")
        cell.textLabel?.text = service.entityAt(indexPath).name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.setAccountType(service.entityAt(indexPath).id)
            self.navigationController?.popViewController(animated: true)
        } else {
            let vc = AccountTypeNavigationViewController(parentTypeId: service.entityAt(indexPath).id)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension AccountTypeNavigationViewController: AccountTypeServiceDelegate {
    func didFetch() {
        tableView.reloadData()
    }

    func showError(error: Error) {

    }
}
