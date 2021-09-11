//
//  UserProfileTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 16.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers
import Purchases

enum SettingsDataSource: String, CaseIterable{
    case offer = "Purchase offer"
    case auth = "Auth"
    case envirement = "Envirement"
    case accountingCurrency = "Accounting currency"
    case accountsManager = "Accounts manager"
    case importAccounts = "Import Account List"
    case importTransactions = "Import Transaction List"
    case exportAccounts = "Share Account List"
    case exportTransactions = "Share Transaction List"
    case termsOfUse = "Terms of use"
    case privacyPolicy = "Privacy policy"
}

class SettingsTableViewController: UITableViewController {
    
    var isUserHasPaidAccess = false
    var proAccessExpirationDate: Date?
    var environment: Environment = .prod
    
    let coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext
    
    var isImportAccounts: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        if let  environment = CoreDataStack.shared.activeEnviroment() {
            self.environment = environment
        }
        
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: Constants.Cell.settingsCell)
        
        //MARK:- adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.environmentDidChange), name: .environmentDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData), name: .receivedProAccessData, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.navigationItem.title = NSLocalizedString("Settings", comment: "")
        reloadProAccessData()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .environmentDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SettingsDataSource.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.settingsCell, for: indexPath) as! SettingsTableViewCell
        cell.configureCell(for: SettingsDataSource.allCases[indexPath.row] , with: self)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch SettingsDataSource.allCases[indexPath.row] {
        
        case .offer:
            showPurchaseOfferVC()
        case .auth:
            break
        case .envirement:
            break
        case .accountingCurrency:
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.currencyTableViewController) as! CurrencyTableViewController
            self.navigationController?.pushViewController(vc, animated: true)
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
            break
        case .privacyPolicy:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func environmentDidChange(){
        if let  environment = CoreDataStack.shared.activeEnviroment() {
            self.environment = environment
            print(environment.rawValue)
        }
        context = CoreDataStack.shared.persistentContainer.viewContext
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
            self.tableView.reloadData()
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

extension SettingsTableViewController {
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

extension SettingsTableViewController: UIDocumentPickerDelegate {
    
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
