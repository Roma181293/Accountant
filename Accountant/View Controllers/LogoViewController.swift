//
//  LogoViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 28.09.2021.
//

import UIKit

class LogoViewController: UIViewController {

    let mainView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let logoView :LogoView = {
        let view = LogoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mainView)
        mainView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        mainView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        mainView.addSubview(logoView)
        logoView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        logoView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        logoView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        logoView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        
    }
}
