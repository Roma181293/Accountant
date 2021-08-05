//
//  AnalyticsViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 28.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//
//

import UIKit
import Charts
import CoreData
import GoogleMobileAds

class AnalyticsViewController: UIViewController, UIScrollViewDelegate, GADFullScreenContentDelegate{
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    unowned var analyticsTableViewController: AnalyticsTableViewController!
    
    private var interstitial: GADInterstitialAd?
    
    private var slides:[UIView] = []
    
    private let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    private let calendar = Calendar.current
    private var dateOfLastChangesInDB : Date?
    
    // transferedData
    var account : Account?
    var transferedDateInterval : DateInterval?
    var sortCategoryBy : SortCategoryType = .nineToZero
    var dateComponent : Calendar.Component = .day
    //
    
    var accountingCurrency : Currency!
    private var presentingData : PresentingData!
    
    private var dateInterval : DateInterval! {
        didSet {
            transferedDateInterval = dateInterval
            updateUI()
        }
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        accountingCurrency = CurrencyManager.getAccountingCurrency(context: context)!
        scrollView.delegate = self
        if account == nil {
            account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.expense), context: context)
        }
        if account?.parent != nil {
            segmentedControl.isHidden = true
        }
        
        scrollView.addConstraint(NSLayoutConstraint(item: self.scrollView!,
                                                    attribute: NSLayoutConstraint.Attribute.height,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: self.scrollView!,
                                                    attribute: NSLayoutConstraint.Attribute.width,
                                                    multiplier: self.view.frame.size.width/414.0,
                                                    constant: 0))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setTitle()
        if isNeedUpdateAll() {
            dateOfLastChangesInDB = UserProfile.getDateOfLastChangesInDB()
            scrollView.scrollToLeft(animated: false)
            setValueToDateInterval()
            updateUI()
        }
        if let entitlement = UserProfile.getEntitlement(),
           (entitlement.name != .pro || (entitlement.name != .pro && entitlement.expirationDate! < Date())) {
            createAd()
        }
    }
    
    
    @IBAction func chooseAccount(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.income), context: context)
        default:
            account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.expense), context: context)
        }
        updateUI()
    }
    
    func createAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
                               request: request,
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                interstitial = ad
                               })
    }
    
    func setValueToDateInterval() {
        if let transferedDateInterval = transferedDateInterval {
            dateInterval = transferedDateInterval
        }
        
        if dateInterval == nil {
            //set last day of month
            //            guard let leftBorderDate = calendar.dateInterval(of: .month, for: Date())?.start, let rightBorderDate = calendar.dateInterval(of: .month, for: Date())?.end else {return}
            //            timeInterval = (leftBorderDate : leftBorderDate, rightBorderDate : rightBorderDate)
            
            //set current day
            guard let leftBorderDate = calendar.dateInterval(of: .month, for: Date())?.start, let rightBorderDate = calendar.dateInterval(of: .day, for: Date())?.end else {return}
            dateInterval = DateInterval(start: leftBorderDate, end: rightBorderDate)
        }
    }
    
    private func isNeedUpdateAll() -> Bool {
        if dateOfLastChangesInDB == nil || dateOfLastChangesInDB != UserProfile.getDateOfLastChangesInDB(){
            return true
        }
        return false
    }
    
    /**
     This method fill all views
     - update tableView for current/seted timeInterval
     - create slides and set tis slides to scrollView
     - manage pageControl
     */
    
    func updateUI() {
        print(#function)
        do {
            presentingData = try AccountManager.prepareDataToShow(parentAccount: account, dateInterval: dateInterval, accountingCurrency: accountingCurrency, dateComponent: dateComponent, isListForAnalytic: true, sortTableDataBy: sortCategoryBy, context: context)
        }
        catch let error{
            let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        
        presentingData.sortTableData(by: sortCategoryBy)
        
        analyticsTableViewController.account = account
        analyticsTableViewController.dateInterval = dateInterval
        analyticsTableViewController.listOfAccountsToShow = presentingData.tableData
        analyticsTableViewController.sortCategoryBy = sortCategoryBy
        analyticsTableViewController.dateComponent = dateComponent
        analyticsTableViewController.tableView.reloadData()
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.hidesForSinglePage = true
        pageControl.isUserInteractionEnabled = false
    }
    
    func sortTableView (){
        presentingData.sortTableData(by: sortCategoryBy)
        analyticsTableViewController.listOfAccountsToShow = presentingData.tableData
        analyticsTableViewController.tableView.reloadData()
    }

    
    
    private func createSlides() -> [UIView] {
        let slide1 : PieChartView = ChartsManager.setPieChartView(dataForPieCharts : presentingData.getDataForPieChart(distributionType: .amount, showDate: true))
        
        let slide2 : LineChartView = ChartsManager.setLineChartView(chartData: presentingData.lineChartData)
        
        slide1.tag = 1
        slide2.tag = 2
        
        return [slide1, slide2]
    }
    
    
    private func setupSlideScrollView(slides : [UIView]) {
        //deleting previous views
        if let viewWithTag = scrollView.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = scrollView.viewWithTag(2) {
            viewWithTag.removeFromSuperview()
        }
        
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 44, width: view.frame.width, height: view.frame.width / 414.0 * view.frame.width-44)
            print("slides[\(i)].frame", slides[i].frame)
            scrollView.addSubview(slides[i])
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        /*
         * below code scales the imageview on paging the scrollview
         */
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
        if(percentOffset.x > 0 && percentOffset.x <= 0.5) {
            slides[0].transform = CGAffineTransform(scaleX: (0.5-percentOffset.x)/0.5, y:(0.5-percentOffset.x)/0.5)
            slides[1].transform = CGAffineTransform(scaleX: percentOffset.x/0.5, y: percentOffset.x/0.5)
            
        } else if(percentOffset.x > 0.5 && percentOffset.x <= 1) {
            slides[0].transform = CGAffineTransform(scaleX: (0.5-percentOffset.x)/0.5, y:percentOffset.x/0.5)
            slides[1].transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
        }
    }
    
    
    private func setTitle() {
        if let account = account {
            if account.parent != nil {
                self.navigationItem.title = account.name
            }
            else {
                self.tabBarController?.navigationItem.title = NSLocalizedString("Analytics", comment: "")
            }
        }
        else {
            self.tabBarController?.navigationItem.title = NSLocalizedString("Analytics", comment: "")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#function)
        if segue.identifier == "goToConfigurationVC_ID" {
            let vc = segue.destination as! ConfigureAnalyticsViewController
            vc.analyticsViewController = self
            vc.transferedDateInterval = dateInterval
            vc.dateComponent = dateComponent
            vc.sortCategoryBy = sortCategoryBy
            vc.interstitial = interstitial
        }
        else if segue.identifier == "goToAnalyticsTVC_ID" {
            analyticsTableViewController = segue.destination as? AnalyticsTableViewController
            analyticsTableViewController.dateInterval = dateInterval
        }
    }
}
