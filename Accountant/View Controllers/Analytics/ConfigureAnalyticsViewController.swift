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
    
    
    
    let bluredView: UIView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let dateIntervalLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Time interval", comment: "")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let startDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    let dashLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let endDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    let sortedByLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Sorted by", comment: "")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let sortedBySegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [NSLocalizedString("A-Z",comment: ""),
                                                          NSLocalizedString("Z-A",comment: ""),
                                                          NSLocalizedString("0-9",comment: ""),
                                                          NSLocalizedString("9-0",comment: "")])
        segmentedControl.selectedSegmentIndex = 3
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
        
    let dateComponentLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Time distribution", comment: "")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateComponentSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [NSLocalizedString("Day",comment: ""),
                                                          NSLocalizedString("Week",comment: ""),
                                                          NSLocalizedString("Month",comment: "")])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let discardButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = Constants.Size.cornerButtonRadius
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.backgroundColor = Colors.Main.defaultButton
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let applyButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = Constants.Size.cornerButtonRadius
        button.setTitle(NSLocalizedString("Apply", comment: ""), for: .normal)
        button.backgroundColor = Colors.Main.defaultButton
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- adding NotificationCenter observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData), name: .receivedProAccessData, object: nil)
        
        reloadProAccessData()
        
        interstitial?.fullScreenContentDelegate = analyticsViewController
      
        addMainView()
        configureSegmentedControls()
        
        if let transferedDateInterval = transferedDateInterval {
            dateInterval = transferedDateInterval
        }
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissAction(_:)))
        bluredView.isUserInteractionEnabled = true
        bluredView.addGestureRecognizer(dismissTap)
        
        startDatePicker.addTarget(self, action: #selector(self.setStartDate), for: .editingDidEnd)
        endDatePicker.addTarget(self, action: #selector(self.setEndDate), for: .editingDidEnd)
        
        sortedBySegmentedControl.addTarget(self, action: #selector(sortBy(_:)), for: .valueChanged)
        dateComponentSegmentedControl.addTarget(self, action: #selector(selectDateComponent(_:)), for: .valueChanged)
        
        discardButton.addTarget(self, action: #selector(self.dismissAction(_:)), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(self.doneAction(_:)), for: .touchUpInside)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }
    
    private func addMainView() {
        let minSpace: CGFloat = 5
        let maxSpace: CGFloat = 20
        
        
        view.backgroundColor = .clear
        
        //MARK:- Blured View
        view.addSubview(bluredView)
        bluredView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bluredView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bluredView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bluredView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //MARK:- Main View
        view.addSubview(mainView)
        mainView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //MARK:- Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10).isActive = true
        mainStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -10).isActive = true
        
        //MARK:- Date Interval Label
        mainStackView.addArrangedSubview(dateIntervalLabel)
        mainStackView.setCustomSpacing(minSpace, after: dateIntervalLabel)
        
        //MARK:- Date View
        mainStackView.addArrangedSubview(dateView)
       
        //MARK:- Dash Label
        dateView.addSubview(dashLabel)
        dashLabel.widthAnchor.constraint(equalToConstant: 5).isActive = true
        dashLabel.centerXAnchor.constraint(equalTo: dateView.centerXAnchor).isActive = true
        dashLabel.centerYAnchor.constraint(equalTo: dateView.centerYAnchor).isActive = true
        
        //MARK:- Start Date Picker
        dateView.addSubview(startDatePicker)
//        startDatePicker.leadingAnchor.constraint(equalTo: dateView.leadingAnchor).isActive = true
        startDatePicker.trailingAnchor.constraint(equalTo: dashLabel.leadingAnchor, constant: -5).isActive = true
        startDatePicker.topAnchor.constraint(equalTo: dateView.topAnchor).isActive = true
        startDatePicker.bottomAnchor.constraint(equalTo: dateView.bottomAnchor).isActive = true
        
        //MARK:- End Date Picker
        dateView.addSubview(endDatePicker)
        endDatePicker.leadingAnchor.constraint(equalTo: dashLabel.trailingAnchor, constant: 5).isActive = true
//        endDatePicker.trailingAnchor.constraint(equalTo: dateView.trailingAnchor).isActive = true
        endDatePicker.topAnchor.constraint(equalTo: dateView.topAnchor).isActive = true
        endDatePicker.bottomAnchor.constraint(equalTo: dateView.bottomAnchor).isActive = true
        
        mainStackView.setCustomSpacing(maxSpace, after: dateView)
        mainStackView.addArrangedSubview(sortedByLabel)
        mainStackView.setCustomSpacing(minSpace, after: sortedByLabel)
        mainStackView.addArrangedSubview(sortedBySegmentedControl)
        mainStackView.setCustomSpacing(maxSpace, after: sortedBySegmentedControl)
        mainStackView.addArrangedSubview(dateComponentLabel)
        mainStackView.setCustomSpacing(minSpace, after: dateComponentLabel)
        mainStackView.addArrangedSubview(dateComponentSegmentedControl)
        mainStackView.setCustomSpacing(30, after: dateComponentSegmentedControl)
        
        //MARK:- Buttons Stack View
        mainStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(discardButton)
        buttonsStackView.addArrangedSubview(applyButton)
    }
    
    @objc private func sortBy(_ sender: UISegmentedControl) {
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
    
    
    @objc private func selectDateComponent(_ sender: UISegmentedControl) {
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
    
    @objc private func doneAction(_ sender: Any) {
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
    
    
    @objc private func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: NOT USED
    private func showContentForNonPaidUser() {
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
    
    private func configureSegmentedControls() {
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
    
    
    @objc private func setStartDate() {
        self.dateInterval = DateInterval(start: startDatePicker.date, end: dateInterval.end)
    }
    
    
    @objc private func setEndDate() {
        if let pickedDate = calendar.date(byAdding: .day, value: +1, to: endDatePicker.date){
            self.dateInterval = DateInterval(start: dateInterval.start, end: pickedDate)
        }
    }
    
    @objc private func reloadProAccessData() {
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
