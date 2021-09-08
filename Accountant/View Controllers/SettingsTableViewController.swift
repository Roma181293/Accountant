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

class SettingsTableViewController: UITableViewController {
    
    var isUserHasPaidAccess = false
    private var proAccessExpirationDate: Date?
    var environment: Environment = .prod
    
    let coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext
    
    var dataSource : [String] = [
        "Purchase offer",
        "Auth",
        "Envirement",
        NSLocalizedString("Accounting currency", comment: ""),
        NSLocalizedString("Accounts manager", comment: ""),
        
        NSLocalizedString("Import Account List", comment: ""),
        NSLocalizedString("Import Transaction List", comment: ""),
        NSLocalizedString("Share Account List", comment: ""),
        NSLocalizedString("Share Transaction List", comment: ""),
        
        NSLocalizedString("Terms of use", comment: ""),
        NSLocalizedString("Privacy policy", comment: "")
        
        //        NSLocalizedString("Subscriptions status", comment: ""),
        //        "TransactionEditor"
    ]
    
    var isImportAccounts: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let  environment = CoreDataStack.shared.activeEnviroment() {
            self.environment = environment
        }
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
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSource[indexPath.row] == "Auth" {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.settingsCellWithSwitchCell, for: indexPath) as! SettingWithSwitchTableViewCell
            cell.updateForAuthConfigure()
            cell.accessoryType = .none
            return cell
        }
        else if dataSource[indexPath.row] == "Envirement"{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.settingsCellWithSwitchCell, for: indexPath) as! SettingWithSwitchTableViewCell
            cell.updateForEnviromentConfigure()
            cell.accessoryType = .none
            return cell
            
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.settingsCell, for: indexPath)
            
            //textLabel
            if dataSource[indexPath.row] == "Purchase offer" {
                if isUserHasPaidAccess {
                    cell.textLabel?.text = NSLocalizedString("PRO access", comment: "")
                }
                else {
                    cell.textLabel?.text = NSLocalizedString("Get PRO access", comment: "")
                }
            }
            else {
                cell.textLabel?.text = dataSource[indexPath.row]
            }
            
            
            //detailTextLabel
            if dataSource[indexPath.row] == NSLocalizedString("Accounting currency", comment: "") {
                if let currency = CurrencyManager.getAccountingCurrency(context: context) {
                    cell.detailTextLabel?.text = currency.code!
                }
                else {
                    cell.detailTextLabel?.text = "No currency"
                }
            }
            else if dataSource[indexPath.row] == "Purchase offer" && isUserHasPaidAccess && proAccessExpirationDate != nil {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .none
                formatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")")
                cell.detailTextLabel?.text = NSLocalizedString("till", comment: "") + " " + formatter.string(from: proAccessExpirationDate!)
            }
            else {
                cell.detailTextLabel?.text = ""
            }
            
            //accessoryType
            if dataSource[indexPath.row] == NSLocalizedString("Accounting currency", comment: "") ||
                dataSource[indexPath.row] == NSLocalizedString("Account & category editor", comment: "") ||
//                dataSource[indexPath.row] == NSLocalizedString("Purchase offer", comment: "") ||
                dataSource[indexPath.row] == NSLocalizedString("Accounts manager", comment: "") ||
                dataSource[indexPath.row] == NSLocalizedString("Terms of use", comment: "") ||
                dataSource[indexPath.row] == NSLocalizedString("Privacy policy", comment: "")
            {
                cell.accessoryType = .disclosureIndicator
            }
            else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if dataSource[indexPath.row] == NSLocalizedString("Accounting currency", comment: "") {
            let currencyTableViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.currencyTableViewController) as! CurrencyTableViewController
            self.navigationController?.pushViewController(currencyTableViewController, animated: true)
        }
        else if dataSource[indexPath.row] == NSLocalizedString("Share Account List", comment: "") {
            shareTXTFile(fileName: "AccountList", data: AccountManager.exportAccountsToString(context: context))
            print(AccountManager.exportAccountsToString(context: context))
        }
        else if dataSource[indexPath.row] == NSLocalizedString("Share Transaction List", comment: ""){
            shareTXTFile(fileName: "TransactionList", data: TransactionManager.exportTransactionsToString(context: context))
        }
        else if dataSource[indexPath.row] == NSLocalizedString("Accounts manager", comment: "") {
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableViewController) as!
                AccountNavigatorTableViewController
            vc.isUserHasPaidAccess = isUserHasPaidAccess
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if dataSource[indexPath.row] == "Purchase offer"{
           showPurchaseOfferVC()
        }
        else if dataSource[indexPath.row] == NSLocalizedString("Subscriptions status", comment: "") {
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.subscriptionsStatusViewController) as! SubsctiptionStatusViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if dataSource[indexPath.row] == "TransactionEditor" {
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.complexTransactionEditorViewController) as! ComplexTransactionEditorViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if dataSource[indexPath.row] == NSLocalizedString("Import Account List", comment: ""){
            
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
        else if dataSource[indexPath.row] == NSLocalizedString("Import Transaction List", comment: ""){
            
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
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
                self.proAccessExpirationDate = purchaserInfo?.expirationDate(forEntitlement: "pro")
            }
            else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
                self.proAccessExpirationDate = nil
            }
            self.tableView.reloadData()
        }
    }
    
    func showPurchaseOfferVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
        self.navigationController?.present(vc, animated: true, completion: nil)
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
                
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
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
                try coreDataStack.saveContext(context)}
            catch let error {
                print("ERROR:", error.localizedDescription)
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
