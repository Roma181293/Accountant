//
//  ConfigureAnalyticsViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 16.06.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Purchases

class ConfigureAnalyticsViewController: UIViewController {
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var sortedBySegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateComponentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var myView: UIView!
    
    var isUserHasPaidAccess = false
    
    //Transfered data
    weak var analyticsViewController : AnalyticsViewController!
    var transferedDateInterval : DateInterval!
    var sortCategoryBy : SortCategoryType = .aToz
    var dateComponent : Calendar.Component = .day
    
    var interstitial: GADInterstitialAd?
    
    private var dateInterval : DateInterval! {
        didSet {
            configureDatePickers()
        }
    }
    private let dateformatter = DateFormatter()
    private let calendar = Calendar.current
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK:- adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData), name: .receivedProAccessData, object: nil)
        
        reloadProAccessData()
        
        //MARK: - Content for user that doesnt pay
        interstitial?.fullScreenContentDelegate = analyticsViewController
//        showContentForNonPaidUser()
        
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.datePickerMode = .date
        
        myView.layer.borderWidth = 0.5
        myView.layer.borderColor = UIColor.black.cgColor
        configureSegmentedControls()
        
        if let transferedDateInterval = transferedDateInterval {
            dateInterval = transferedDateInterval
        }
    }
    
    deinit {
        print("ConfigureAnalyticsVC",#function)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }
    
    
    @IBAction func sortBy(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sortCategoryBy = .aToz
        case 1:
            sortCategoryBy = .zToa
        case 2:
            sortCategoryBy = .zeroToNine
        default:
            sortCategoryBy = .nineToZero
        }
    }
    
    
    @IBAction func selectDateComponent(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            dateComponent = .day
        case 1:
            dateComponent = .weekOfMonth
        default:
            dateComponent = .month
        }
    }
    
    var isPurchaseOfferDidShow : Bool = false
    
    @IBAction func doneAction(_ sender: Any) {
        if analyticsViewController.transferedDateInterval == dateInterval &&
            analyticsViewController.sortCategoryBy != sortCategoryBy &&
            analyticsViewController.dateComponent == dateComponent {
            guard isUserHasPaidAccess || isPurchaseOfferDidShow
            else {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
                analyticsViewController.navigationController?.present(vc, animated: true, completion: nil)
                isPurchaseOfferDidShow = true
                analyticsViewController.sortCategoryBy = sortCategoryBy
                analyticsViewController.sortTableView()
                analyticsViewController.analyticsTableViewController.tableView.reloadData()
                self.dismiss(animated: true, completion: nil)
                return
            }
            analyticsViewController.sortCategoryBy = sortCategoryBy
            analyticsViewController.sortTableView()
            analyticsViewController.analyticsTableViewController.tableView.reloadData()
        }
        else  if analyticsViewController.transferedDateInterval != dateInterval ||
                    analyticsViewController.sortCategoryBy != sortCategoryBy ||
                    analyticsViewController.dateComponent != dateComponent {
            guard isUserHasPaidAccess || isPurchaseOfferDidShow
            else {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
                analyticsViewController.navigationController?.present(vc, animated: true, completion: nil)
                isPurchaseOfferDidShow = true
                analyticsViewController.transferedDateInterval = dateInterval
                analyticsViewController.sortCategoryBy = sortCategoryBy
                analyticsViewController.dateComponent = dateComponent
                analyticsViewController.setValueToDateInterval()
                self.dismiss(animated: true, completion: nil)
                return
            }
            analyticsViewController.transferedDateInterval = dateInterval
            analyticsViewController.sortCategoryBy = sortCategoryBy
            analyticsViewController.dateComponent = dateComponent
            analyticsViewController.setValueToDateInterval()  //there is no need call update method. because it calls in observer 
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func showContentForNonPaidUser() {
        guard isUserHasPaidAccess == false else  {return}
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 25), execute:{
                switch UserProfile.whatPreContentShowInView(.configureAnalytics) {
                case .add:
                    if let interstitial = self.interstitial {
                        interstitial.present(fromRootViewController: self)
                        self.dismiss(animated: true, completion: nil)
                    }
                case .offer:
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.purchaseOfferViewController) as! PurchaseOfferViewController
                    self.analyticsViewController.navigationController?.present(vc, animated: true, completion: nil)
                default:
                    return
                }
            })
        
    }
    
    private func configureDatePickers() {
        guard let dateInterval = dateInterval, let rightBorderDate = calendar.date(byAdding: .day, value: -1, to: dateInterval.end) else {return}
        startDatePicker.date = dateInterval.start
        startDatePicker.maximumDate = rightBorderDate
        
        endDatePicker.date = rightBorderDate
        endDatePicker.minimumDate = startDatePicker.date
    }
    
    
    func configureSegmentedControls() {
        switch sortCategoryBy {
        case .aToz:
            sortedBySegmentedControl.selectedSegmentIndex = 0
        case .zToa:
            sortedBySegmentedControl.selectedSegmentIndex = 1
        case .zeroToNine:
            sortedBySegmentedControl.selectedSegmentIndex = 2
        case .nineToZero:
            sortedBySegmentedControl.selectedSegmentIndex = 3
        }
        
        switch dateComponent {
        case .day:
            dateComponentSegmentedControl.selectedSegmentIndex = 0
        case .weekOfMonth:
            dateComponentSegmentedControl.selectedSegmentIndex = 1
        case .month:
            dateComponentSegmentedControl.selectedSegmentIndex = 2
        default:
            break
        }
    }
    
    
    @IBAction func setStartDate() {
        self.dateInterval = DateInterval(start: startDatePicker.date, end: dateInterval.end)
    }
    
    
    @IBAction func setEndDate() {
        if let pickedDate = calendar.date(byAdding: .day, value: +1, to: endDatePicker.date){
            self.dateInterval = DateInterval(start: dateInterval.start, end: pickedDate)
        }
    }
    
    @objc func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            }
            else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
            }
        }
    }
}
