//
//  ImportTransactionTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 24.10.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class ImportTransactionViewController: UIViewController {

    let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    var fileURL: URL
    private var preTransactionList: [PreTransaction] = []
    private var showOlnyErrors: Bool = false

    let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let showOnlyErrorsLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Show olny errors", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let showOnlyErrorsSwich: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    let confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 243/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.backgroundColor = Colors.Main.confirmButton
        button.layer.cornerRadius = 34
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3
        button.layer.masksToBounds =  false
        return button
    }()

    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // MARK: - Confirm button
        view.addSubview(confirmButton)
        confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -89).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -40).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
        confirmButton.addTarget(self, action: #selector(ImportTransactionViewController.save), for: .touchUpInside)

        // MARK: - Stack View
        mainView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -8).isActive = true
        stackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 8).isActive = true
        stackView.addArrangedSubview(showOnlyErrorsLabel)
        stackView.addArrangedSubview(showOnlyErrorsSwich)
        showOnlyErrorsSwich.addTarget(self, action: #selector(switching(_:)), for: .valueChanged)

        // MARK: - TableView
        mainView.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8).isActive = true
        tableView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true

        mainView.addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true

        // MARK: - Configure TableView
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PreTransactionTableViewCell.self,
                           forCellReuseIdentifier: Constants.Cell.preTransactionTableViewCell)
        tableView.keyboardDismissMode = .onDrag

        DispatchQueue.main.async {
            do {
                guard let data = try? String(contentsOf: self.fileURL) else {return}
                self.preTransactionList = try ImportTransactionWorker.importTransactionList(from: data, context: self.context)
                _ = self.isReadyToSave()
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
            } catch let error {
                self.context.rollback()
                self.errorHandler(error: error)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = NSLocalizedString("Import transactions", comment: "")
        _ = isReadyToSave()
        tableView.reloadData()
    }

    deinit {
        context.rollback()
    }

    @objc func switching(_ sender: UISwitch) {
        showOlnyErrors = sender.isOn
        tableView.reloadData()
    }

    private func isReadyToSave() -> Bool {
        for item in preTransactionList where item.isReadyToSave == false {
                showOnlyErrorsLabel.isHidden = false
                showOnlyErrorsSwich.isHidden = false
                confirmButton.isHidden = true
                return false
        }
        if preTransactionList.count == 0 {
            showOnlyErrorsLabel.isHidden = true
            showOnlyErrorsSwich.isHidden = true
            confirmButton.isHidden = true
            print("Isn't ready")
            return false
        }
        confirmButton.isHidden = false
        showOlnyErrors = false
        showOnlyErrorsLabel.isHidden = true
        showOnlyErrorsSwich.isHidden = true
        return true
    }

    @objc func save() {
        do {
            if isReadyToSave() {
                preTransactionList.forEach({
                    if $0.transaction.date < Date() {
                        $0.transaction.status = .applied
                    } else {
                        $0.transaction.status = .approved
                    }
                })
                try coreDataStack.saveContext(context)
                let alert = UIAlertController(title: NSLocalizedString("Success", comment: ""),
                                              message: NSLocalizedString("All transactions successfully added",
                                                                         comment: ""),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                              style: .default,
                                              handler: {(_) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                              message: NSLocalizedString("Please fix all errors in transaction list",
                                                                         comment: ""),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                              style: .cancel,
                                              handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } catch let error {
            errorHandler(error: error)
        }
    }

    func errorHandler(error: Error) {
        var title = NSLocalizedString("Error", comment: "")
        if error is AppError {
            title = NSLocalizedString("Warning", comment: "")
        }

        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ImportTransactionViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preTransactionList.filter({!(showOlnyErrors && $0.isReadyToSave)}).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.preTransactionTableViewCell, for: indexPath) as! PreTransactionTableViewCell // swiftlint:disable:this force_cast line_length
        cell.setTransaction(preTransactionList.filter({!(showOlnyErrors && $0.isReadyToSave)})[indexPath.row].transaction) // swiftlint:disable:this line_length
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transaction = preTransactionList.filter({!(showOlnyErrors && $0.isReadyToSave)})[indexPath.row].transaction
        self.navigationController?.pushViewController(MITransactionEditorAssembly.configure(transactionId: transaction?.id ?? UUID(), context: context), animated: true)
    }
}
