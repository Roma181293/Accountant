//
//  UserProfileTableViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 16.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

class SettingsTableViewController: UITableViewController {
    
    let coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext
    
    var dataSource : [String] = [
        NSLocalizedString("PRO access", comment: ""),
        "Auth",
        "Envirement",
        NSLocalizedString("Accounting currency", comment: ""),
        NSLocalizedString("Accounts manager", comment: ""),
    
        NSLocalizedString("Import Account List", comment: ""),
        NSLocalizedString("Import Transaction List", comment: ""),
        NSLocalizedString("Share Account List", comment: ""),
        NSLocalizedString("Share Transaction List", comment: "")
//        NSLocalizedString("Subscriptions status", comment: ""),
//        "TransactionEditor"
    ]
    
    var isImportAccounts: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK:- adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.environmentDidChange), name: .environmentDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.navigationItem.title = NSLocalizedString("Settings", comment: "")
        tableView.reloadData()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .environmentDidChange, object: nil)
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
            return cell
        }
        
        else if dataSource[indexPath.row] == "Envirement"{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.settingsCellWithSwitchCell, for: indexPath) as! SettingWithSwitchTableViewCell
            cell.updateForEnviromentConfigure()
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.settingsCell, for: indexPath)
            
            cell.textLabel?.text = dataSource[indexPath.row]
            cell.detailTextLabel?.text = ""
            
            if dataSource[indexPath.row] == NSLocalizedString("Accounting currency", comment: "") {
                if let currency = CurrencyManager.getAccountingCurrency(context: context) {
                    cell.detailTextLabel?.text = currency.code!
                }
                else {
                    cell.detailTextLabel?.text = "No currency"
                }
            }
            else if dataSource[indexPath.row] == NSLocalizedString("Account & category editor", comment: "") {
                cell.accessoryType = .disclosureIndicator
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
        else if dataSource[indexPath.row] == NSLocalizedString("Accounts manager", comment: "") {
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.accountNavigatorTableViewController) as! AccountNavigatorTableViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if dataSource[indexPath.row] == NSLocalizedString("PRO access", comment: ""){
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if dataSource[indexPath.row] == NSLocalizedString("Subscriptions status", comment: "") {
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.subscriptionsStatusViewController) as! SubsctiptionStatusViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if dataSource[indexPath.row] == "TransactionEditor" {
            let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.complexTransactionEditorViewController) as! ComplexTransactionEditorViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func environmentDidChange(){
        context = CoreDataStack.shared.persistentContainer.viewContext
        tableView.reloadData()
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
