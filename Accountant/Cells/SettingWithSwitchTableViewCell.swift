//
//  SettingWithSwitchTableViewCell.swift
//  Accounting
//
//  Created by Roman Topchii on 11.10.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import LocalAuthentication

class SettingWithSwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title : UILabel!
    @IBOutlet weak var switcher : UISwitch!
    
    private var isAuthConfigure: Bool = false
    private var isEnviromentConfigure: Bool = false
    
    func updateForAuthConfigure() {
        isAuthConfigure = true
        
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            
            if context.biometryType == .faceID {
                title.text = "FaceID"
            }
            else if context.biometryType == .touchID {
                title.text = "TouchID"
            }
            else if context.biometryType == .none{
                title.text = "Secure code"
            }
            
            switch UserProfile.getUserAuth() {
            case .appAuth:
                break
            case .bioAuth:
                
                switcher.isOn = true
            case .none:
                switcher.isOn = false
            }
        }
    }
    
    
    func updateForEnviromentConfigure() {
        isEnviromentConfigure = true
        
        title.text = NSLocalizedString("Test mode", comment: "")
        
        if CoreDataStack.shared.activeEnviroment() == .prod {
            switcher.isOn = false
        }
        else if CoreDataStack.shared.activeEnviroment() == .test {
            switcher.isOn = true
        }
    }
    
    
    @IBAction func switching(sender: UISwitch) {
        if isAuthConfigure {
            if sender.isOn {
                UserProfile.setUserAuth(.bioAuth)
            }
            else {
                UserProfile.setUserAuth(.none)
            }
        }
        
        
        else if isEnviromentConfigure {
            UserProfile.setDateOfLastChangesInDB(Date())
            do {
                if sender.isOn {
                    CoreDataStack.shared.switchToDB(.test)
                    
                    let context = CoreDataStack.shared.persistentContainer.viewContext
                    
                    CurrencyManager.addCurrencies(context: context)
                    guard let currency = try CurrencyManager.getCurrencyForCode("UAH", context: context) else {return}
                    try CurrencyManager.changeAccountingCurrency(old: nil, new: currency, context: context)
                    AccountManager.addBaseAccounts(accountingCurrency: currency, context: context)
                    try CoreDataStack.shared.saveContext(context)
                }
                else {
                    let context = CoreDataStack.shared.persistentContainer.viewContext
                    
                    try TransactionManager.deleteAllTransactions(context: context)
                    try AccountManager.deleteAllAccounts(context: context)
                    try CurrencyManager.deleteAllCurrencies(context: context)
                    try CoreDataStack.shared.saveContext(context)
                    
                    CoreDataStack.shared.switchToDB(.prod)
                }
                NotificationCenter.default.post(name: .environmentDidChange, object: nil)
            } catch let error {
                print(error)
            }
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
