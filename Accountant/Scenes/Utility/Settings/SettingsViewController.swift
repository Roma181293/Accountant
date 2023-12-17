//
//  SettingsViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 16.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

protocol SettingsItemSwitcherDelegate: AnyObject {
    var isUserHasPaidAccess: Bool {get}
    var paidAccessExpirationDate: Date? {get}
    var environment: Environment {get}
    var acountungCurrency: String {get}
    func switchFor(_ settingsItem: SettingsViewModel.SettingsItem, isOn: Bool)
}

class SettingsViewController: UIViewController {

    private var viewModel = SettingsViewModel()

    private(set) var isUserHasPaidAccess = false
    private(set) var paidAccessExpirationDate: Date?
    private(set) var environment: Environment = .prod
    private(set) var acountungCurrency: String = ""

    private var isImportAccounts: Bool = true

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let versionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.router.viewController = self

        viewModel.accountingCurrency.bind({[weak self] (value) in
            DispatchQueue.main.async {
                self?.acountungCurrency = value
                self?.tableView.reloadData()
            }
        })
        viewModel.userPaidAccessData.bind({[weak self] (value) in
            DispatchQueue.main.async {
                self?.isUserHasPaidAccess = value.hasPaidAccess
                self?.paidAccessExpirationDate = value.expirationDate
                self?.viewModel.reloadData()
                self?.tableView.reloadData()
            }
        })
        viewModel.environment.bind({[weak self] (value) in
            DispatchQueue.main.async {
                self?.environment = value
                self?.viewModel.reloadData()
                self?.tableView.reloadData()
            }
        })

        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: Constants.Cell.settingsCell)

        addMainView()

        versionLabel.text = viewModel.getAppVersion()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadUserAccessData()
        viewModel.reloadData()

        self.tabBarController?.navigationItem.title =  NSLocalizedString("Settings",
                                                                         tableName: Constants.Localizable.settingsVC,
                                                                         bundle: Bundle.main,
                                                                         comment: "")
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }

    private func addMainView() {
        view.addSubview(versionLabel)
        versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                             constant: -5).isActive = true
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -5).isActive = true
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.settingsCell, for: indexPath) as! SettingsCell // swiftlint:disable:this force_cast line_length
        cell.configureCell(for: viewModel.settingsList[indexPath.row], with: self)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(row: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController: SettingsItemSwitcherDelegate {
    func switchFor(_ settingsItem: SettingsViewModel.SettingsItem, isOn: Bool) {
        if settingsItem == .envirement {
            viewModel.switchEnvironment(isOn)
        } else if settingsItem == .auth {
            UserProfileService.setUserAuth(isOn ? .bioAuth: .none)
        }
    }
}

extension SettingsViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .import,
              let url = urls.first else { return }
        if isImportAccounts {
            guard let data = try? String(contentsOf: url) else {return}
            viewModel.importAccounts(data: data)
        } else {
            viewModel.router.route(to: .importTransactionVC(fromFile: url))
        }
        controller.dismiss(animated: true)
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
