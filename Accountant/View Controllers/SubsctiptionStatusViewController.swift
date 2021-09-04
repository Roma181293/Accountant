//
//  SubsctiptionStatusViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 09.02.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import UIKit

class SubsctiptionStatusViewController: UIViewController {

    @IBOutlet weak var entitlementName : UILabel!
    @IBOutlet weak var expirationDate : UILabel!
    @IBOutlet weak var lastUpdate : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let entitlement = UserProfile.getEntitlement() else {return}
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .short
//        dateFormatter.timeStyle = .medium
//        dateFormatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")")
//        
//        
//        entitlementName.text = String(entitlement.name.rawValue)
//        if let expDate = entitlement.expirationDate {
//            expirationDate.text = dateFormatter.string(from: expDate)
//        }
//        lastUpdate.text = dateFormatter.string(from: entitlement.lastUpdate)
    }
    

}
