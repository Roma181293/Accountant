//
//  SetNameViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 04.08.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

class SetAccountingStartDateViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonToViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Accounting start date", comment: "")
        guard let startAccountingDate = UserProfile.getAccountingStartDate() else {
            return
        }
        datePicker.date = startAccountingDate
    }
    
    private func addButtonToViewController() {
        let addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70 , y: self.view.frame.height - 150), size: CGSize(width: 68, height: 68)))
        addButton.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 243/255, alpha: 1)
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -89),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            addButton.heightAnchor.constraint(equalToConstant: 68),
            addButton.widthAnchor.constraint(equalToConstant: 68),
          ])
        
        addButton.layer.cornerRadius = 34
        if let image = UIImage(systemName: "arrow.right") {
            addButton.setImage(image, for: .normal)
        }
        addButton.addTarget(self, action: #selector(SetAccountingStartDateViewController.next(_:)), for: .touchUpInside)
    }
    
    @objc func next(_ sender:UIButton!) {
        let calendar = Calendar.current
        guard let date = calendar.dateInterval(of: .day, for: datePicker.date)?.start else {return}
        UserProfile.setAccountingStartDate(date)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let setNameVC = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.setAccountingCurrencyViewController) as! SetAccountingCurrencyViewController
        self.navigationController?.pushViewController(setNameVC, animated: true)
    }
 
}
