//
//  CurrencyViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 20.04.2022.
//

import UIKit
import CoreData

protocol CurrencyReceiverDelegate: AnyObject {
    func setCurrency(_ selectedCurrency: Currency)
}

class CurrencyViewController: UITableViewController {

    enum Mode {
        case setAccountingCurrency
        case setCurrency
    }

    var persistentContainer = CoreDataStack.shared.persistentContainer
    var delegate: CurrencyReceiverDelegate?

    var mode: Mode = .setCurrency
    var currency: Currency?
    var currencyIndexPath: IndexPath?

    private lazy var dataProvider: CurrencyProvider = {
        let provider = CurrencyProvider(with: persistentContainer, fetchedResultsControllerDelegate: self)
        return provider
    }()

    init(currency: Currency? = nil, delegate: CurrencyReceiverDelegate, mode: Mode = .setCurrency) {
        super.init(style: .plain)
        self.currency = currency
        self.delegate = delegate
        self.mode = mode
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var alertActionsToEnable: [UIAlertAction] = [] // to input validation

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: Constants.Cell.currencyCell)
        self.navigationItem.title = NSLocalizedString("Currency",
                                                      tableName: Constants.Localizable.currencyVC,
                                                      comment: "")
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate
extension CurrencyViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataProvider.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.currencyCell, for: indexPath) as! CurrencyTableViewCell // swiftlint:disable:this force_cast line_length
        let fetchedCurrency = dataProvider.fetchedResultsController.object(at: indexPath)
        cell.configure(fetchedCurrency, currency: currency, mode: mode)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {return}
        let selectedCurrency = dataProvider.fetchedResultsController.object(at: indexPath)
        if mode == .setAccountingCurrency {
            dataProvider.setAccountingCurrency(indexPath: indexPath, context: persistentContainer.viewContext)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            delegate.setCurrency(selectedCurrency)
        } else if mode == .setCurrency {
            delegate.setCurrency(selectedCurrency)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension CurrencyViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
