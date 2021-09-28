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
import SafariServices

enum SettingsDataSource: String, CaseIterable{
    case offer = "Purchase offer"
    case startAccounting = "Start accounting"
    case auth = "Auth"
    case envirement = "Envirement"
    case accountingCurrency = "Accounting currency"
    case accountsManager = "Account manager"
    case importAccounts = "Import Account List"
    case importTransactions = "Import Transaction List"
    case exportAccounts = "Share Account List"
    case exportTransactions = "Share Transaction List"
    case termsOfUse = "Terms of use"
    case privacyPolicy = "Privacy policy"
}

class SettingsViewController: UIViewController {
    
    var isUserHasPaidAccess = false
    var proAccessExpirationDate: Date?
    var environment: Environment = .prod
    
    let coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext
    
    var dataSource: [SettingsDataSource] = []
    var isImportAccounts: Bool = true
    
    
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
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: Constants.Cell.settingsCell)

        addMainView()
        getAppVersion()
        
        if let  environment = CoreDataStack.shared.activeEnviroment() {
            self.environment = environment
        }
        
        
        //MARK:- adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.environmentDidChange), name: .environmentDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData), name: .receivedProAccessData, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        refreshDataSet()
     
        self.tabBarController?.navigationItem.title = NSLocalizedString("Settings", comment: "")
        reloadProAccessData()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .environmentDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }
    
    private func addMainView() {
        view.addSubview(versionLabel)
        versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
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
        
        versionLabel.text = "\(NSLocalizedString("App version", comment: "")) \(version) (\(bundle))"
    }
    
    @objc func environmentDidChange(){
        if let  environment = CoreDataStack.shared.activeEnviroment() {
            self.environment = environment
            print(environment.rawValue)
        }
        context = CoreDataStack.shared.persistentContainer.viewContext
        refreshDataSet()
        tableView.reloadData()
    }
    
    @objc func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if let error = error {
                self.errorHandler(error: error)
            }
            else {
                if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                    self.isUserHasPaidAccess = true
                    self.proAccessExpirationDate = purchaserInfo?.expirationDate(forEntitlement: "pro")
                }
                else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
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
        for item in SettingsDataSource.allCases {
            if (item == .envirement && UserProfile.isAppLaunchedBefore() == false)
                || (item == .startAccounting && UserProfile.isAppLaunchedBefore() == true)
                || (item == .auth && isUserHasPaidAccess == false) {}
            else {
                dataSource.append(item)
            }
        }
    }
    
    func showPurchaseOfferVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func errorHandler(error: Error) {
        var title = NSLocalizedString("Error", comment: "")
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}



extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.settingsCell, for: indexPath) as! SettingsTableViewCell
        cell.configureCell(for: dataSource[indexPath.row] , with: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch dataSource[indexPath.row] {
        
        case .offer:
            showPurchaseOfferVC()
        case .auth:
            break
        case .envirement:
            break
        case .accountingCurrency:
//            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.currencyTableViewController) as! CurrencyTableViewController
//            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .accountsManager:
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableViewController) as!
                AccountNavigatorTableViewController
            vc.isUserHasPaidAccess = isUserHasPaidAccess
            self.navigationController?.pushViewController(vc, animated: true)
        case .importAccounts:
            if AccessCheckManager.checkUserAccessToImportExportEntities(environment: environment, isUserHasPaidAccess: isUserHasPaidAccess) {
                isImportAccounts = true
                
                if #available(iOS 14.0, *) {
                    let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text], asCopy: true)
                    importMenu.delegate = self
                    importMenu.modalPresentationStyle = .formSheet
                    self.present(importMenu, animated: true, completion: nil)
                    
                } else {
                    let importMenu = UIDocumentPickerViewController(documentTypes: ["text"], in: .import)
                    importMenu.delegate = self
                    importMenu.modalPresentationStyle = .formSheet
                    self.present(importMenu, animated: true, completion: nil)
                }
            }
            else{
                showPurchaseOfferVC()
            }
        case .importTransactions:
            if AccessCheckManager.checkUserAccessToImportExportEntities(environment: environment, isUserHasPaidAccess: isUserHasPaidAccess) {
                isImportAccounts = false
                
                if #available(iOS 14.0, *) {
                    let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text], asCopy: true)
                    importMenu.delegate = self
                    importMenu.modalPresentationStyle = .formSheet
                    self.present(importMenu, animated: true, completion: nil)
                    
                } else {
                    let importMenu = UIDocumentPickerViewController(documentTypes: ["text"], in: .import)
                    importMenu.delegate = self
                    importMenu.modalPresentationStyle = .formSheet
                    self.present(importMenu, animated: true, completion: nil)
                }
            }
            else{
                showPurchaseOfferVC()
            }
        case .exportAccounts:
            if AccessCheckManager.checkUserAccessToImportExportEntities(environment: environment, isUserHasPaidAccess: isUserHasPaidAccess) {
                shareTXTFile(fileName: "AccountList", data: AccountManager.exportAccountsToString(context: context))
            }
            else{
                showPurchaseOfferVC()
            }
        case .exportTransactions:
            if AccessCheckManager.checkUserAccessToImportExportEntities(environment: environment, isUserHasPaidAccess: isUserHasPaidAccess) {
                shareTXTFile(fileName: "TransactionList", data: TransactionManager.exportTransactionsToString(context: context))
            }
            else{
                showPurchaseOfferVC()
            }
        case .termsOfUse:
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let url = URL(string: Constants.URL.termsOfUse)
            let webVC = WebViewController(url: url!, configuration: config)
            self.present(webVC, animated: true, completion: nil)
        case .privacyPolicy:
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let url = URL(string: Constants.URL.privacyPolicy)
            let webVC = WebViewController(url: url!, configuration: config)
            self.present(webVC, animated: true, completion: nil)
        case .startAccounting:
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.startAccountingViewController) as! StartAccountingViewController
            vc.vc = self.parent
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController {
    func shareTXTFile (fileName: String, data : String) {
        let docDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileURL = docDirectory?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            do {
                try data.write(to: fileURL, atomically: true, encoding: .utf8)
                
                let objectsToShare = [fileURL]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
                
            } catch let error {
                errorHandler(error: error)
            }
        }
    }
}

extension SettingsViewController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .import, let url = urls.first, let data = try? String(contentsOf: url)
        else { return }
        
        if isImportAccounts {
            do {
                try AccountManager.importAccounts( data, context: context)
                try coreDataStack.saveContext(context)
            } catch let error {
                errorHandler(error: error)
            }
        }
        else {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.importTransactionViewController) as! ImportTransactionViewController
            vc.dataFromFile = data
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        controller.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
