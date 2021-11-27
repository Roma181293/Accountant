//
//  MonobankGetUserInfoViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 18.11.2021.
//

import UIKit

class MonobankGetUserInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkServices.loadMBUserInfo(compliting: { (response, error) in

            if let response = response {
                print(response)
            }

        })
//        NetworkServices.loadMBUserInfo()
    }
    

    

}
