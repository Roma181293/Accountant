//
//  MoneyAccountListViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 31.03.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import Charts
//import Purchases

class AccountListViewController: UIViewController, UIScrollViewDelegate { // swiftlint:disable:this type_body_length

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var currencyDateLable: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var chnageCurrencyButton: UIButton!
    private unowned var moneyAccountListTableViewController: AccountListTableViewController!

    private var slides: [UIView] = []
    var isUserHasPaidAccess: Bool = true
    var environment: Environment = .prod
    let coreDataStack = CoreDataStack.shared
    var context = CoreDataStack.shared.persistentContainer.viewContext

    private let calendar = Calendar.current
    private var dateOfLastChangesInDB: Date?

    private var account: Account!
    private var currency: Currency!
    private var presentingData: PresentingData!
    private var dateComponent: Calendar.Component = .day

    private var dateInterval: DateInterval? {
        didSet {
            guard let dateInterval = dateInterval else {return}
            switch dateInterval.duration {
            case 0...3600*24*90:
                dateComponent = .day
            case 3600*24*90...3600*24*365:
                dateComponent = .weekOfMonth
            default:
                dateComponent = .month
            }
            currencyHistoricalData = UserProfileService.getLastExchangeRate()
        }
    }

    private var currencyHistoricalData: CurrencyHistoricalData? {
        didSet {
            if let currencyHistoricalData = currencyHistoricalData,
               let exchangeDateString = currencyHistoricalData.exchangeDateStringFormat(),
               let exchangeDate = currencyHistoricalData.ecxhangeDate() {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                if dateFormatter.string(from: Date()) == exchangeDateString {
                    currencyDateLable.text = ""
                } else {
                    let localeDateFormatter = DateFormatter()
                    localeDateFormatter.dateStyle = .short
                    localeDateFormatter.timeStyle = .none
                    localeDateFormatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")") // swiftlint:disable:this line_length
                    currencyDateLable.text = String(format: NSLocalizedString("Exchange rate updated: %@", comment: ""),
                                                    localeDateFormatter.string(from: exchangeDate))
                }
            }
        }
    }

    override func loadView() {
        super.loadView()
        var correction: CGFloat = 0
        switch  UIDevice.modelName {
        case "iPhone 6", "iPhone 6 Plus", "iPhone 6s", "iPhone 6s Plus", "iPhone 7", "iPhone 7 Plus",
            "iPhone 8", "iPhone 8 Plus", "iPhone SE (2nd generation)": correction = 24
        case "iPhone 11", "iPhone XR": correction = -4
        case "iPhone X", "iPhone XS", "iPhone 11 Pro", "iPhone XS Max", "iPhone 11 Pro Max": correction = 0
        case "iPhone 12 mini", "iPhone 13 Mini": correction = -6
        case "iPhone 12", "iPhone 12 Pro", "iPhone 12 Pro Max", "iPhone 13 Pro Max",
            "iPhone 13 Pro", "iPhone 13": correction = -3
        default: break
        }
        scrollView.frame = CGRect(x: 0, y: scrollView.frame.origin.y,
                                  width: view.frame.width,
                                  height: view.frame.height/2-scrollView.frame.origin.y+correction)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.environmentDidChange),
                                               name: .environmentDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProAccessData),
                                               name: .receivedProAccessData, object: nil)
        context = CoreDataStack.shared.persistentContainer.viewContext

        self.environment = coreDataStack.activeEnvironment

        reloadProAccessData()

        currency = CurrencyHelper.getAccountingCurrency(context: context)!
        scrollView.delegate = self
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            account = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.money),
                                                 context: context)
        case 1:
            account = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.debtors),
                                                 context: context)
        default:
            account = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.credits),
                                                 context: context)
        }
        moneyAccountListTableViewController.environment = self.environment
        moneyAccountListTableViewController.context = context
        moneyAccountListTableViewController.delegate = self
        moneyAccountListTableViewController.currency = currency
        moneyAccountListTableViewController.isUserHasPaidAccess = isUserHasPaidAccess
        moneyAccountListTableViewController.account = account
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil

        self.tabBarController?.navigationItem.title = NSLocalizedString("Accounts", comment: "")
        if isNeedUpdateAll() {
            dateOfLastChangesInDB = UserProfileService.getDateOfLastChangesInDB()
            scrollView.scrollToLeft(animated: false)
            guard let startDate = TransactionHelper.getFirstTransactionDate(context: context)
            else {
                dateInterval = DateInterval(start: Date(), end: Date())
                self.updateUI()
                return
            }
            dateInterval = DateInterval(start: startDate, end: Date())
            currencyHistoricalData = UserProfileService.getLastExchangeRate()
            self.updateUI()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .environmentDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .receivedProAccessData, object: nil)
    }
    @IBAction func chnageCurrency(_ sender: Any) {
        let currencyVC = CurrencyViewController()
        currencyVC.currency = currency
        currencyVC.delegate = self
        self.navigationController?.pushViewController(currencyVC, animated: true)
    }

    @IBAction func changeAccount(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            account = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.money),
                                                 context: context)
        case 1:
            account = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.debtors),
                                                 context: context)
        default:
            account = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.credits),
                                                 context: context)
        }
        updateUI()
    }

    private func isNeedUpdateAll() -> Bool {
        if dateOfLastChangesInDB == nil || dateOfLastChangesInDB != UserProfileService.getDateOfLastChangesInDB() {
            return true
        }
        return false
    }

    public func updateUI() {
        guard let dateInterval = dateInterval, let account = account else {return}
        do {
            presentingData = try account.prepareDataToShow(dateInterval: dateInterval,
                                                           selectedCurrency: currency,
                                                           currencyHistoricalData: currencyHistoricalData,
                                                           dateComponent: dateComponent,
                                                           sortTableDataBy: SortCategoryType.nineToZero)
        } catch let error {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                          message: "\(error.localizedDescription)",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                          style: .default))
            self.present(alert, animated: true, completion: nil)
        }

        slides = createSlides()
        setupSlideScrollView(slides: slides)
        moneyAccountListTableViewController.account = account
        moneyAccountListTableViewController.listOfAccountsToShow = presentingData.tableData
        moneyAccountListTableViewController.tableView.reloadData()
        pageControl.numberOfPages = slides.count
        pageControl.hidesForSinglePage = true
    }

    // swiftlint:disable line_length
    private func createSlides() -> [UIView] {
        let slide1: PieChartView = ChartsManager.setPieChartView(dataForPieCharts: presentingData.getDataForPieChart(distributionType: .amount, showDate: false))
        let slide2: PieChartView = ChartsManager.setPieChartView(dataForPieCharts: presentingData.getDataForPieChart(distributionType: .currecy, showDate: false))
        let slide3: LineChartView = ChartsManager.setLineChartView(chartData: presentingData.lineChartData)
        let slide4: PieChartView = ChartsManager.setPieChartView(dataForPieCharts: presentingData.getDataForPieChart(distributionType: .holder, showDate: false))
        let slide5: PieChartView = ChartsManager.setPieChartView(dataForPieCharts: presentingData.getDataForPieChart(distributionType: .keeper, showDate: false))
        slide1.tag = 2
        slide2.tag = 3
        slide3.tag = 4
        slide4.tag = 5
        slide5.tag = 6
        return [slide1, slide2, slide3, slide4, slide5]
    }
    // swiftlint:enable line_length

    private func setupSlideScrollView(slides: [UIView]) {
        for index in 1...6 {
            if let viewWithTag = scrollView.viewWithTag(index) {
                viewWithTag.removeFromSuperview()
            }
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(slides.count),
                                        height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        for index in 0 ..< slides.count {
            slides[index].frame = CGRect(x: scrollView.frame.width * CGFloat(index),
                                         y: 0,
                                         width: scrollView.frame.width,
                                         height: scrollView.frame.height)
            scrollView.addSubview(slides[index])
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)

        if slides.count == 4 {
            if percentOffset.x > 0 && percentOffset.x <= 0.33 {
                slides[0].transform = CGAffineTransform(scaleX: (0.33-percentOffset.x)/0.33,
                                                        y: (0.33-percentOffset.x)/0.33)
                slides[1].transform = CGAffineTransform(scaleX: percentOffset.x/0.33,
                                                        y: percentOffset.x/0.33)
            } else if percentOffset.x > 0.33 && percentOffset.x <= 0.66 {
                slides[1].transform = CGAffineTransform(scaleX: (0.66-percentOffset.x)/0.33,
                                                        y: (0.66-percentOffset.x)/0.33)
                slides[2].transform = CGAffineTransform(scaleX: percentOffset.x/0.66,
                                                        y: percentOffset.x/0.66)
            } else if percentOffset.x > 0.66 && percentOffset.x <= 1 {
                slides[2].transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.33,
                                                        y: (1-percentOffset.x)/0.33)
                slides[3].transform = CGAffineTransform(scaleX: percentOffset.x,
                                                        y: percentOffset.x)
            }
        } else if slides.count == 3 {
            if percentOffset.x > 0 && percentOffset.x <= 0.5 {
                slides[0].transform = CGAffineTransform(scaleX: (0.5-percentOffset.x)/0.5,
                                                        y: (0.5-percentOffset.x)/0.5)
                slides[1].transform = CGAffineTransform(scaleX: percentOffset.x/0.5,
                                                        y: percentOffset.x/0.5)
            } else if percentOffset.x > 0.5 && percentOffset.x <= 1 {
                slides[1].transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.5,
                                                        y: (1-percentOffset.x)/0.5)
                slides[2].transform = CGAffineTransform(scaleX: percentOffset.x,
                                                        y: percentOffset.x)
            }
        }
    }

    private func addBluredView() {
        let bluredView = UIView()
        if !UIAccessibility.isReduceTransparencyEnabled {
            bluredView.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            // always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            bluredView.addSubview(blurEffectView)
            // if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            bluredView.backgroundColor = .black
        }
        bluredView.tag = 10
        view.addSubview(bluredView)
    }

    private func deleteBluredView() {
        if let viewWithTag = self.view.viewWithTag(10) {
            viewWithTag.removeFromSuperview()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.goToMoneyAccountListTVC {
            moneyAccountListTableViewController = segue.destination as? AccountListTableViewController
        }
    }

    @objc func environmentDidChange() {
        segmentedControl.selectedSegmentIndex = 0

        context = CoreDataStack.shared.persistentContainer.viewContext
        currency = CurrencyHelper.getAccountingCurrency(context: context)!
        account = AccountHelper.getAccountWithPath(LocalizationManager.getLocalizedName(.money),
                                             context: context)

        moneyAccountListTableViewController.context = context
        moneyAccountListTableViewController.currency = currency
        moneyAccountListTableViewController.account = account


        self.environment = coreDataStack.activeEnvironment
        moneyAccountListTableViewController.environment = self.environment
        
        if let startDate = TransactionHelper.getFirstTransactionDate(context: context) {
            dateInterval = DateInterval(start: startDate, end: Date())
        } else {
            dateInterval = DateInterval(start: Date(), end: Date())
        }
        currencyHistoricalData = UserProfileService.getLastExchangeRate()
    }

    @objc func reloadProAccessData() {
//        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
//            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
//                self.isUserHasPaidAccess = true
//            } else if purchaserInfo?.entitlements.all["pro"]?.isActive == false {
//                self.isUserHasPaidAccess = false
//            }
//            self.moneyAccountListTableViewController.isUserHasPaidAccess = self.isUserHasPaidAccess
//        }
    }

    private func showPurchaseOfferVC() {
        self.present(PurchaseOfferViewController(), animated: true, completion: nil)
    }
}

extension AccountListViewController: CurrencyReceiverDelegate {
    func setCurrency(_ selectedCurrency: Currency) {
        currency = selectedCurrency
        moneyAccountListTableViewController.currency = currency
        updateUI()
    }
}
