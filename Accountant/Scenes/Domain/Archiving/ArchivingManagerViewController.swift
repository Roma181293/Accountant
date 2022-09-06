//
//  ArchivingManagerViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 06.07.2022.
//

import UIKit

class ArchivingManagerViewController: UIViewController {

    private var archivingListToShow: [ArchivingHistoryViewModel] = []
    private var worker: ArchivingWorker!

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("By archive transactions, you protect account/category amount changing in a set period.\nIf you want to change the balance before the last date, please set the archive date in the past", tableName: "ArchivinHistoryLocalizable", comment: "") // swiftlint:disable:this line_length
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.maximumDate = Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    private let archiveButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Archive transactions before the date", tableName: "ArchivinHistoryLocalizable", comment: ""), for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Archiving", tableName: "ArchivinHistoryLocalizable", comment: "")
        setConstraints()
        archiveButton.addTarget(self, action: #selector(archiveButtonDidClick), for: .touchUpInside)
        tableView.register(ArchivingHistoryTableViewCell.self, forCellReuseIdentifier: Constants.Cell.holderCell)
        tableView.dataSource = self
        let persistentContainer = CoreDataStack.shared.persistentContainer
        let transactionStatusWorker = TransactionStatusWorker(persistentContainer: persistentContainer)
        worker = ArchivingWorker(transactionStatusWorker: transactionStatusWorker,
                                 persistentContainer: persistentContainer)
        worker.delegate = self
        worker.fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datePicker.maximumDate = Date()
    }

    private func setConstraints() {

        view.backgroundColor = .systemBackground

        view.addSubview(descriptionLabel)
        descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true

        view.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(archiveButton)
        archiveButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20).isActive = true
        archiveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        archiveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        archiveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: archiveButton.bottomAnchor, constant: 40).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    @objc func archiveButtonDidClick() {
        worker.setArchivingPeriod(date: datePicker.date)
    }

}

extension ArchivingManagerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivingListToShow.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = archivingListToShow[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.holderCell, for: indexPath) as! ArchivingHistoryTableViewCell // swiftlint:disable:this force_cast
        cell.set(item)
        return cell
    }
}

extension ArchivingManagerViewController: ArchivingWorkerDelegate {
    func didFetch(_ list: [ArchivingHistoryViewModel]) {
        archivingListToShow = list
        datePicker.date = Date()
        tableView.reloadData()
    }
}
