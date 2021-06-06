//
//  SubscriptionsViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 06.02.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import UIKit
import Purchases

class PurchaseOfferViewController: UIViewController {
    
    let mainView : UIView = {
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        return mainView
    }()
    let offerDatailLabel: UILabel = {
        let offerDatailLabel = UILabel()
        offerDatailLabel.textAlignment = .center
        offerDatailLabel.text = "Відсутність реклами\n Можливість створювати необмежену кількість рахунків та категорій\nМожливість копіювати операції\nПерегляд аналітики за всі періоди\nЕкспорт операцій в форматі .csv\nБезпека"
        offerDatailLabel.textColor = .black
        offerDatailLabel.font = .systemFont(ofSize: 12.0)
        offerDatailLabel.lineBreakMode = .byWordWrapping
        offerDatailLabel.numberOfLines = 0
        offerDatailLabel.translatesAutoresizingMaskIntoConstraints = false
        return offerDatailLabel
    }()
    let paymentDetailLabel: UILabel = {
        let paymentDetailLabel = UILabel()
        paymentDetailLabel.textAlignment = .center
        paymentDetailLabel.text = "Оплату за підписку буде стягнуто з вашого рахунку iTunes під час підтвердження покупки. Підписка подовжується автоматично, якщо ви не скасували її принаймі за 24 години до завершення поточного періоду. Оплата за подовження буде списано протягом доби, що передує даті завершення поточного періоду. Керувати підпискою та скасувани її можно в налаштуваннях облікового запису iTunes"
        paymentDetailLabel.textColor = .black
        paymentDetailLabel.font = .systemFont(ofSize: 12.0)
        paymentDetailLabel.lineBreakMode = .byWordWrapping
        paymentDetailLabel.numberOfLines = 0
        paymentDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        return paymentDetailLabel
    }()
    var offerStackView: UIStackView = {
        let offerStackView = UIStackView()
        offerStackView.axis = .vertical
        offerStackView.alignment = .center
        offerStackView.distribution = .fillEqually
        offerStackView.spacing = 20.0
        offerStackView.translatesAutoresizingMaskIntoConstraints = false
        return offerStackView
    }()
    
    var packageAvailableForPurchase = [Purchases.Package]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("PRO access", comment: "")
        
        self.view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        mainView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        mainView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        mainView.heightAnchor.constraint(lessThanOrEqualToConstant: 667).isActive = true
        mainView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
        mainView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true
        
        mainView.addSubview(offerDatailLabel)
        offerDatailLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
        offerDatailLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10).isActive = true
        offerDatailLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true
        
        mainView.addSubview(paymentDetailLabel)
        paymentDetailLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
        paymentDetailLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10).isActive = true
        paymentDetailLabel.topAnchor.constraint(equalTo: offerDatailLabel.bottomAnchor, constant: 20).isActive = true
        
        mainView.addSubview(offerStackView)
        offerStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
        offerStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10).isActive = true
        offerStackView.topAnchor.constraint(equalTo: paymentDetailLabel.bottomAnchor, constant: 10).isActive = true
        
        
        
        Purchases.shared.offerings { (offerings, error) in
            if let offerings = offerings {
                let offer = offerings.current
                guard let packages = offer?.availablePackages else {print("There is no packegs in Revenue Cat"); return}
                
                for i in 0...packages.count-1 {
                    let package = packages[i]
                    
                    self.packageAvailableForPurchase.append(package)
                    
                    let product = package.product
                    
//                    let title = product.localizedTitle
                    let price = package.localizedPriceString
                    var duration = ""
                    
                    if let subscriptionPeriod = product.subscriptionPeriod {
                        switch subscriptionPeriod.unit {
                        case .day:
                            duration = NSLocalizedString("per day", comment: "")
                        case .month:
                            duration = NSLocalizedString("per month", comment: "")
                        case .week:
                            duration = NSLocalizedString("per week", comment: "")
                        case .year:
                            duration = NSLocalizedString("per year", comment: "")
                        default: break
                        }
                    }
                    
                    //Create button
                    let button = UIButton(type: .system)
                    button.tintColor = .black
                    button.backgroundColor = .red
//                    button.setTitle(title + " " + price + " " + duration, for: .normal)
                    button.setTitle(price + " " + duration, for: .normal)
                    button.tag = i
                    
                    
                    //Add a tap handler
                    button.addTarget(self, action: #selector(self.purchaseTapped(sender:)), for: .touchUpInside)
                    
                    
                    //Add button to the stackView
                    self.offerStackView.addArrangedSubview(button)
                    
                    let height = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 90)
                    button.addConstraint(height)
                    
                    let width = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: self.offerStackView, attribute: .width, multiplier: 1, constant: 0)
                    self.offerStackView.addConstraint(width)
                }
            }
        }
    }
    
    @objc func purchaseTapped(sender: UIButton) {
        
        let package = packageAvailableForPurchase[sender.tag]
        
        Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
            if let error = error {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                    UserProfile.setEntitlement(Entitlement(name: .pro, expirationDate: purchaserInfo?.entitlements.all["pro"]?.expirationDate))
                }
                else {
                    UserProfile.setEntitlement(Entitlement(name: .none, expirationDate: purchaserInfo?.entitlements.all["pro"]?.expirationDate))
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
