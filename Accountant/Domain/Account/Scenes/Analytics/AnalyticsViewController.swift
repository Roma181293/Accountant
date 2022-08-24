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
import Purchases

class AnalyticsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!

    var isUserHasPaidAccess = false

    private let coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext

    unowned var analyticsTableViewController: AnalyticsTableViewController!

    private var slides: [UIView] = []

    private let calendar = Calendar.current
    private var dateOfLastChangesInDB: Date?

    // transferedData
    var account: Account?
    var transferedDateInterval: DateInterval?
    var sortCategoryBy: SortCategoryType = .nineToZero
    var dateComponent: Calendar.Component = .day
    //

    var accountingCurrency: Currency!
    private var presentingData: PresentingData!

    private var dateInterval: DateInterval! {
        didSet {
            transferedDateInterval = dateInterval
            updateUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        context = CoreDataStack.shared.persistentContainer.viewContext
        NotificationCenter.default.addObserver(self, selector: #selector(self.environmentDidChange),
                                               name: .environmentDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)

        reloadProAccessData()

        accountingCurrency = CurrencyHelper.getAccountingCurrency(context: context)!
        scrollView.delegate = self
        if account == nil {
            account = AccountHelper.getAccountWithPath(LocalisationManager.getLocalizedName(.expense),
                                                 context: context)
        }
        if let level = account?.level, level > 1 {
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
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        setTitle()
        if isNeedUpdateAll() {
            dateOfLastChangesInDB = UserProfile.getDateOfLastChangesInDB()
            scrollView.scrollToLeft(animated: false)
            setValueToDateInterval()
            updateUI()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .environmentDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }

    @IBAction func chooseAccount(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            account = AccountHelper.getAccountWithPath(LocalisationManager.getLocalizedName(.income),
                                                 context: context)
        default:
            account = AccountHelper.getAccountWithPath(LocalisationManager.getLocalizedName(.expense),
                                                 context: context)
        }
        updateUI()
    }

    func setValueToDateInterval() {
        if let transferedDateInterval = transferedDateInterval {
            dateInterval = transferedDateInterval
        }
        if dateInterval == nil {
            guard let leftBorderDate = calendar.dateInterval(of: .month, for: Date())?.start,
                  let rightBorderDate = calendar.dateInterval(of: .day, for: Date())?.end else {return}
            dateInterval = DateInterval(start: leftBorderDate, end: rightBorderDate)
        }
    }

    private func isNeedUpdateAll() -> Bool {
        if dateOfLastChangesInDB == nil || dateOfLastChangesInDB != UserProfile.getDateOfLastChangesInDB() {
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
        guard let account = account else {return}
        do {
            presentingData = try account.prepareDataToShow(dateInterval: dateInterval,
                                                           selectedCurrency: accountingCurrency,
                                                           dateComponent: dateComponent,
                                                           isListForAnalytic: true,
                                                           sortTableDataBy: sortCategoryBy)
        } catch let error {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                          message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }

        presentingData.sortTableDataBy(sortCategoryBy)

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

    func sortTableView() {
        presentingData.sortTableDataBy(sortCategoryBy)
        analyticsTableViewController.listOfAccountsToShow = presentingData.tableData
        analyticsTableViewController.tableView.reloadData()
    }

    private func createSlides() -> [UIView] {
        let dataForPieCharts = presentingData.getDataForPieChart(distributionType: .amount, showDate: true)

        let slide1 = ChartsManager.setPieChartView(dataForPieCharts: dataForPieCharts)
        let slide2 = ChartsManager.setLineChartView(chartData: presentingData.lineChartData)
        slide1.tag = 1
        slide2.tag = 2
        return [slide1, slide2]
    }

    private func setupSlideScrollView(slides: [UIView]) {
        // deleting previous views
        if let viewWithTag = scrollView.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = scrollView.viewWithTag(2) {
            viewWithTag.removeFromSuperview()
        }
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count),
                                        height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        for index in 0 ..< slides.count {
            slides[index].frame = CGRect(x: view.frame.width * CGFloat(index),
                                         y: 44,
                                         width: view.frame.width,
                                         height: view.frame.width / 414.0 * view.frame.width-44)
            print("slides[\(index)].frame", slides[index].frame)
            scrollView.addSubview(slides[index])
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

        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)

        if percentOffset.x > 0 && percentOffset.x <= 0.5 {
            slides[0].transform = CGAffineTransform(scaleX: (0.5-percentOffset.x)/0.5, y: (0.5-percentOffset.x)/0.5)
            slides[1].transform = CGAffineTransform(scaleX: percentOffset.x/0.5, y: percentOffset.x/0.5)
        } else if percentOffset.x > 0.5 && percentOffset.x <= 1 {
            slides[0].transform = CGAffineTransform(scaleX: (0.5-percentOffset.x)/0.5, y: percentOffset.x/0.5)
            slides[1].transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
        }
    }

    private func setTitle() {
        if let account = account {
            if account.parent != nil {
                self.navigationItem.title = account.name
            } else {
                self.tabBarController?.navigationItem.title = NSLocalizedString("Analytics", comment: "")
            }
        } else {
            self.tabBarController?.navigationItem.title = NSLocalizedString("Analytics", comment: "")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.goToConfigurationVC {
            guard let configAnalyticVC = segue.destination as? ConfigureAnalyticsViewController else {return}
            configAnalyticVC.analyticsViewController = self
            configAnalyticVC.transferedDateInterval = dateInterval
            configAnalyticVC.dateComponent = dateComponent
            configAnalyticVC.sortCategoryBy = sortCategoryBy
        } else if segue.identifier == Constants.Segue.goToAnalyticsTVC {
            analyticsTableViewController = segue.destination as? AnalyticsTableViewController
            analyticsTableViewController.dateInterval = dateInterval
        }
    }

    @objc func environmentDidChange() {
        context = CoreDataStack.shared.persistentContainer.viewContext

        accountingCurrency = CurrencyHelper.getAccountingCurrency(context: context)!
        account = AccountHelper.getAccountWithPath(LocalisationManager.getLocalizedName(.expense),
                                             context: context)
        segmentedControl.selectedSegmentIndex = 1

        if isNeedUpdateAll() {
            dateOfLastChangesInDB = UserProfile.getDateOfLastChangesInDB()
            scrollView.scrollToLeft(animated: false)
            setValueToDateInterval()
            updateUI()
        }
    }

    @objc func reloadProAccessData() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                self.isUserHasPaidAccess = true
            } else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
                self.isUserHasPaidAccess = false
            }
        }
    }
}
