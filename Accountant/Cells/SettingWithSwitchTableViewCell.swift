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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update() {
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
    
    @IBAction func setBioAuth(sender: UISwitch) {
        if sender.isOn {
            UserProfile.setUserAuth(.bioAuth)
        }
        else {
            UserProfile.setUserAuth(.none)
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
