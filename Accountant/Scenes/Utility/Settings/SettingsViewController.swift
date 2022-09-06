//
//  SettingsViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 16.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers
import Purchases

class SettingsViewController: UIViewController {

    enum DataSource: String, CaseIterable {
        case offer = "Purchase offer"
        case startAccounting = "Start accounting"
        case auth = "Auth"
        case envirement = "Test mode"
        case accountingCurrency = "Accounting currency"
        case archive = "Archiving"
        case accountsManager = "Account manager"
        case multiItemTransaction = "Multi item transaction"
        case bankProfiles = "Bank profiles"
        case exchangeRates = "Exchange rates"
        case importAccounts = "Import account list"
        case importTransactions = "Import transaction list"
        case exportAccounts = "Export account list"
        case exportTransactions = "Export transaction list"
        case userGuides = "User guides"
        case termsOfUse = "Terms of use"
        case privacyPolicy = "Privacy policy"
    }

    private(set) var isUserHasPaidAccess = false
    private(set) var proAccessExpirationDate: Date?
    private(set) var environment: Environment = .prod

    private let coreDataStack = CoreDataStack.shared
    private(set) var context = CoreDataStack.shared.persistentContainer.viewContext

    private var dataSource: [DataSource] = []
    private var isImportAccounts: Bool = true

    private(set) lazy var router: SettingsRouter = {
        return SettingsRouter(viewController: self)
    }()

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
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: Constants.Cell.settingsCell)

        addMainView()
        getAppVersion()

        self.environment = CoreDataStack.shared.activeEnvironment

        NotificationCenter.default.addObserver(self, selector: #selector(self.environmentDidChange),
                                               name: .environmentDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        refreshDataSet()
        self.tabBarController?.navigationItem.title =  NSLocalizedString("Settings",
                                                                         tableName: Constants.Localizable.settingsVC,
                                                                         bundle: Bundle.main,
                                                                         comment: "")
        reloadProAccessData()

        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .environmentDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
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

    private func getAppVersion() {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let bundle = dictionary["CFBundleVersion"] as? String
        else {return}

        versionLabel.text = "\(NSLocalizedString("App version", tableName: Constants.Localizable.settingsVC, comment: "")) \(version) (\(bundle))" // swiftlint:disable:this line_length
    }

    @objc private func environmentDidChange() {
        self.environment = coreDataStack.persistentContainer.environment
        context = coreDataStack.persistentContainer.viewContext
        refreshDataSet()
        tableView.reloadData()
    }

    @objc func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if let error = error {
                self.router.route(to: .error(error))
            } else {
                if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                    self.isUserHasPaidAccess = true
                    self.proAccessExpirationDate = purchaserInfo?.expirationDate(forEntitlement: "pro")
                } else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                    self.isUserHasPaidAccess = false
                    self.proAccessExpirationDate = nil
                }
            }
            self.refreshDataSet()
            self.tableView.reloadData()
        }
    }

    func refreshDataSet() {
        dataSource.removeAll()
        for item in DataSource.allCases {
            if (item == .envirement && UserProfileService.isAppLaunchedBefore() == false)
                || (item == .startAccounting && UserProfileService.isAppLaunchedBefore() == true)
                || (item == .auth && isUserHasPaidAccess == false)
                || (item == .multiItemTransaction && isUserHasPaidAccess == false && environment == .prod)
                || item == .importAccounts
                || item == .exportAccounts
                || item == .userGuides
                || item == .exchangeRates {
            } else {
                dataSource.append(item)
            }
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.settingsCell, for: indexPath) as! SettingsCell // swiftlint:disable:this force_cast line_length
        cell.configureCell(for: dataSource[indexPath.row], with: self)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // swiftlint:disable:this function_body_length cyclomatic_complexity line_length
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        switch dataSource[indexPath.row] {
        case .offer:
            router.route(to: .offerVC)
        case .auth, .envirement, .accountingCurrency, .multiItemTransaction:
            break
        case .accountsManager:
            router.route(to: .accountNavVC)
        case .importAccounts:
            if AccessManager.canImportExportEntities(environment: environment,
                                                     isUserHasPaidAccess: isUserHasPaidAccess) {
                isImportAccounts = true
                router.route(to: .openDocumentPickerVC)
            } else {
                router.route(to: .offerVC)
            }
        case .importTransactions:
            if AccessManager.canImportExportEntities(environment: environment,
                                                     isUserHasPaidAccess: isUserHasPaidAccess) {
                isImportAccounts = false
                router.route(to: .openDocumentPickerVC)
            } else {
                router.route(to: .offerVC)
            }
        case .exportAccounts:
            if AccessManager.canImportExportEntities(environment: environment,
                                                     isUserHasPaidAccess: isUserHasPaidAccess) {
                shareFile(fileName: "AccountList", data: ImportExportAccountWorker.exportAccountsToString(context: context))
            } else {
                router.route(to: .offerVC)
            }
        case .exportTransactions:
            if AccessManager.canImportExportEntities(environment: environment,
                                                     isUserHasPaidAccess: isUserHasPaidAccess) {
                shareFile(fileName: "TransactionList",
                          data: TransactionHelper.exportTransactionsToString(context: context))
            } else {
                router.route(to: .offerVC)
            }
        case .termsOfUse:
            router.route(to: .termsOfUse)
        case .privacyPolicy:
            router.route(to: .privacyPolicy)
        case .startAccounting:
            router.route(to: .startAccounting(self.parent))
        case .userGuides:
            guard let userGuideVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.instructionVC) as? InstructionViewController else {return} // swiftlint:disable:this line_length
            self.present(userGuideVC, animated: true, completion: nil)
        case .bankProfiles:
            router.route(to: .bankProfilesVC)
        case .exchangeRates:
            self.navigationController?.pushViewController(ExchangeTableViewController(), animated: true)
        case .archive:
            router.route(to: .archive)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func setEnvironmentToTest(_ newValueTest: Bool) {
        do {
            if newValueTest {
                CoreDataStack.shared.switchPersistentStore(.test)
                try CoreDataStack.shared.restorePersistentStore(.test)
                try SeedDataService.addTestData(persistentContainer: CoreDataStack.shared.persistentContainer)
            } else if !newValueTest && CoreDataStack.shared.activeEnvironment == .test {
                UserProfileService.useMultiItemTransaction(false, environment: .test)
                CoreDataStack.shared.switchPersistentStore(.prod)
            }
            NotificationCenter.default.post(name: .environmentDidChange, object: nil)
        } catch let error {
            router.route(to: .error(error))
        }
    }
}

extension SettingsViewController {
    private func shareFile(fileName: String, data: String) {
        let docDirectory = try? FileManager.default.url(for: .documentDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: true)
        if let fileURL = docDirectory?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            do {
                try data.write(to: fileURL, atomically: true, encoding: .utf8)
                router.route(to: .share(filesToShare: [fileURL]))
            } catch let error {
                router.route(to: .error(error))
            }
        }
    }
}

extension SettingsViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .import, let url = urls.first else { return }
        if isImportAccounts {
            do {
                guard let data = try? String(contentsOf: url) else {return}
                let backGroundContext = coreDataStack.persistentContainer.newBackgroundContext()
                try ImportExportAccountWorker.importAccounts(data, context: backGroundContext)
                try coreDataStack.saveContext(backGroundContext)
            } catch let error {
                router.route(to: .error(error))
            }
        } else {
            router.route(to: .importTransactionVC(fromFile: url))
        }
        controller.dismiss(animated: true)
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
