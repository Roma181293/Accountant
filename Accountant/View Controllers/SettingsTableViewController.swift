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
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    var userProfile : [String] = [
        NSLocalizedString("PRO access", comment: ""),
        NSLocalizedString("Accounting currency", comment: ""),
        NSLocalizedString("Accounts manager", comment: ""),
        "BioAuth",
        NSLocalizedString("Share Account List", comment: ""),
        NSLocalizedString("Share Transaction List", comment: ""),
        
        NSLocalizedString("Import Account List", comment: ""),
        NSLocalizedString("Import Transaction List", comment: ""),
        //  NSLocalizedString("Add data for test app", comment: "")
        NSLocalizedString("Subscriptions status", comment: "")
    ]
    
    var isImportAccounts: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.navigationItem.title = NSLocalizedString("Settings", comment: "")
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userProfile.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if userProfile[indexPath.row] == "BioAuth" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellSwitch_ID", for: indexPath) as! SettingWithSwitchTableViewCell
            cell.update()
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell_ID", for: indexPath)
            
            cell.textLabel?.text = userProfile[indexPath.row]
            cell.detailTextLabel?.text = ""
            
            if userProfile[indexPath.row] == NSLocalizedString("Accounting currency", comment: "") {
                cell.detailTextLabel?.text = CurrencyManager.getAccountingCurrency(context: context)!.code!
            }
            else if userProfile[indexPath.row] == NSLocalizedString("Account & category editor", comment: "") {
                cell.accessoryType = .disclosureIndicator
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if userProfile[indexPath.row] == NSLocalizedString("Accounting currency", comment: "") {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let currencyTableViewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyTVC_ID") as! CurrencyTableViewController
            self.navigationController?.pushViewController(currencyTableViewController, animated: true)
        }
        else if userProfile[indexPath.row] == NSLocalizedString("Share Account List", comment: "") {
            shareTXTFile(fileName: "AccountList", data: AccountManager.exportAccountsToString(context: context))
            print(AccountManager.exportAccountsToString(context: context))
        }
        else if userProfile[indexPath.row] == NSLocalizedString("Share Transaction List", comment: ""){
            shareTXTFile(fileName: "TransactionList", data: TransactionManager.exportTransactionsToString(context: context))
        }
        else if userProfile[indexPath.row] == NSLocalizedString("Import Account List", comment: ""){
           
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
        else if userProfile[indexPath.row] == NSLocalizedString("Import Transaction List", comment: ""){
           
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
        else if userProfile[indexPath.row] == NSLocalizedString("Accounts manager", comment: "") {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "AccountManagerTVC_ID") as! AccountManagerTableViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if userProfile[indexPath.row] == NSLocalizedString("PRO access", comment: ""){
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PurchaseOfferVC_ID") as! PurchaseOfferViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if userProfile[indexPath.row] == NSLocalizedString("Subscriptions status", comment: "") {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "SubscriptionsStatusVC_ID") as! SubsctiptionStatusViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func proSubscriprion() {
        print("receive pro access")
    }
    
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
            let vc = storyBoard.instantiateViewController(withIdentifier: "ImportTransactionVC_ID") as! ImportTransactionViewController
            vc.dataFromFile = data
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        controller.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
