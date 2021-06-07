//
//  MoneyAccountListViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 31.03.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit
import Charts

class AccountListViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var currencyDateLable: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    private unowned var moneyAccountListTableViewController: AccountListTableViewController!
    
    private var slides: [UIView] = []
    
    let coreDataStack = CoreDataStack.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    private let calendar = Calendar.current
    private var dateOfLastChangesInDB : Date?
    
    private var account : Account!
    private var accountingCurrency : Currency!
    private var presentingData : PresentingData!
    private var dateComponent : Calendar.Component = .day
  
    private var dateInterval : DateInterval? {
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
            currencyHistoricalData = UserProfile.getLastExchangeRate()
        }
    }
    
    private var currencyHistoricalData : CurrencyHistoricalDataProtocol?{
        didSet {
            if let currencyHistoricalData = currencyHistoricalData, let exchangeDate = currencyHistoricalData.exchangeDate() {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                let today = dateFormatter.string(from:Date())
                if today == exchangeDate{
                    currencyDateLable.text = ""
                }
                else {
                    //FIXME:-  "Exchange rate updated: %@" указывает дату в неверном формате, так как курс валют хранит дату в формате строки
                    currencyDateLable.text = String(format: NSLocalizedString("Exchange rate updated: %@",comment: ""), exchangeDate)
                }
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        var correction : CGFloat = 0
        switch  UIDevice.modelName {
        case "iPhone 6","iPhone 6 Plus", "iPhone 6s","iPhone 6s Plus", "iPhone 7","iPhone 7 Plus","iPhone 8","iPhone 8 Plus","iPhone SE (2nd generation)": correction = 24
        case "iPhone 11","iPhone XR": correction = -4
        case "iPhone X","iPhone XS","iPhone 11 Pro", "iPhone XS Max", "iPhone 11 Pro Max": correction = 0
        case "iPhone 12 mini": correction = -6
        case "iPhone 12","iPhone 12 Pro","iPhone 12 Pro Max": correction = -3
        default: break
        }
        scrollView.frame = CGRect(x: 0, y: scrollView.frame.origin.y, width: view.frame.width, height: view.frame.height/2-scrollView.frame.origin.y+correction)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountingCurrency = CurrencyManager.getAccountingCurrency(context: context)!
        scrollView.delegate = self
        moneyAccountListTableViewController.context = context
        moneyAccountListTableViewController.delegate = self
        moneyAccountListTableViewController.accountingCurrency = accountingCurrency
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
        case 1:
            account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.debtors), context: context)
        default:
            account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.credits), context: context)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addButtonToViewController()
        self.tabBarController?.navigationItem.title = NSLocalizedString("Accounts",comment: "")
        if isNeedUpdateAll() {
            dateOfLastChangesInDB = UserProfile.getDateOfLastChangesInDB()
            scrollView.scrollToLeft(animated: false)
            guard let startDate = TransactionManager.getDateForFirstTransaction(context: context)
            else {
                dateInterval = DateInterval(start : Date(), end : Date())
                self.updateUI()
                return
            }
            dateInterval = DateInterval(start : startDate, end : Date())
            currencyHistoricalData = UserProfile.getLastExchangeRate()
            self.updateUI()
        }
    }
    
    @IBAction func changeAccount(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.money), context: context)
        case 1:
            account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.debtors), context: context)
        default:
            account = AccountManager.getAccountWithPath(AccountsNameLocalisationManager.getLocalizedAccountName(.credits), context: context)
        }
        updateUI()
    }
    
    
    private func isNeedUpdateAll() -> Bool {
        if dateOfLastChangesInDB == nil || dateOfLastChangesInDB != UserProfile.getDateOfLastChangesInDB(){
            return true
        }
        return false
    }
    
    
    /**
     This method fill all views
     - sets date to date textFields
     - create slides and set tis slides to scrollView
     - manage pageControl
     */
    public func updateUI() {
        guard let dateInterval = dateInterval, let account = account else {return}
        do {
            presentingData = try AccountManager.prepareDataToShow(parentAccount: account, dateInterval: dateInterval, accountingCurrency: accountingCurrency, currencyHistoricalData: currencyHistoricalData, dateComponent: dateComponent, isListForAnalytic: false, sortTableDataBy: SortCategoryType.nineToZero, context: context)
        }
        catch let error{
            let alert = UIAlertController(title: NSLocalizedString("Error",comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok",comment: ""), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        moneyAccountListTableViewController.listOfAccountsToShow = presentingData.tableData
        moneyAccountListTableViewController.updateUI()
        
        pageControl.numberOfPages = slides.count
        pageControl.hidesForSinglePage = true
    }
    
    
    
    private func createSlides() -> [UIView] {
        
        let slide1 : PieChartView = ChartsManager.setPieChartView(dataForPieCharts : presentingData.getDataForPieChart(distributionType: .amount, showDate: false))
        
        let slide2 : PieChartView = ChartsManager.setPieChartView(dataForPieCharts : presentingData.getDataForPieChart(distributionType: .currecy, showDate: false))
        
        let slide3 : LineChartView = ChartsManager.setLineChartView(chartData: presentingData.lineChartData)
        
       
        slide1.tag = 2
        slide2.tag = 3
        slide3.tag = 4
        
        return [slide1, slide2, slide3]
    }
    
    
    private func setupSlideScrollView(slides : [UIView]) {
        //deleting previous views
        for i in 1...4 {
            if let viewWithTag = scrollView.viewWithTag(i) {
                viewWithTag.removeFromSuperview()
            }
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(slides.count), height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        print("UIScreen.main.bounds.height",UIScreen.main.bounds.height)
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            print("slides[\(i)].frame", slides[i].frame)
            scrollView.addSubview(slides[i])
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/scrollView.frame.width)
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
        
        if slides.count == 4 {
            if(percentOffset.x > 0 && percentOffset.x <= 0.33) {
                
                slides[0].transform = CGAffineTransform(scaleX: (0.33-percentOffset.x)/0.33, y: (0.33-percentOffset.x)/0.33)
                slides[1].transform = CGAffineTransform(scaleX: percentOffset.x/0.33, y: percentOffset.x/0.33)
                
            } else if(percentOffset.x > 0.33 && percentOffset.x <= 0.66) {
                slides[1].transform = CGAffineTransform(scaleX: (0.66-percentOffset.x)/0.33, y: (0.66-percentOffset.x)/0.33)
                slides[2].transform = CGAffineTransform(scaleX: percentOffset.x/0.66, y: percentOffset.x/0.66)
                
            } else if(percentOffset.x > 0.66 && percentOffset.x <= 1) {
                slides[2].transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.33, y: (1-percentOffset.x)/0.33)
                slides[3].transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
            }
        }
        else if slides.count == 3 {
            
            if(percentOffset.x > 0 && percentOffset.x <= 0.5) {

                slides[0].transform = CGAffineTransform(scaleX: (0.5-percentOffset.x)/0.5, y: (0.5-percentOffset.x)/0.5)
                slides[1].transform = CGAffineTransform(scaleX: percentOffset.x/0.5, y: percentOffset.x/0.5)
            } else if(percentOffset.x > 0.5 && percentOffset.x <= 1) {
                slides[1].transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.5, y: (1-percentOffset.x)/0.5)
                slides[2].transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
            }
        }
    }

    
    private func addBluredView() {
        let bluredView = UIView()
        if !UIAccessibility.isReduceTransparencyEnabled {
            bluredView.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            bluredView.addSubview(blurEffectView)
            //if you have more UIViews, use an insertSubview API to place it where needed
            
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
    
    
    
    private func addButtonToViewController() {
        let addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70 , y: self.view.frame.height - 150), size: CGSize(width: 68, height: 68)))
        addButton.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 243/255, alpha: 1)
        view.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        let standardSpacing: CGFloat = -40.0
          NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(89-49)), //49- tabbar heigth
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: standardSpacing),
            addButton.heightAnchor.constraint(equalToConstant: 68),
            addButton.widthAnchor.constraint(equalToConstant: 68)
          ])
        
        addButton.layer.cornerRadius = 34
        if let image = UIImage(systemName: "plus") {
            addButton.setImage(image, for: .normal)
        }
        addButton.addTarget(self, action: #selector(AccountListViewController.addAccount(_:)), for: .touchUpInside)
    }
    
    @objc func addAccount(_ sender:UIButton!){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let account = account else {return}
        let entryVC = storyBoard.instantiateViewController(withIdentifier: "AccountEditorWithInitialBalanceVC_ID") as! AccountEditorWithInitialBalanceViewController
        entryVC.parentAccount = account
        entryVC.delegate = self.parent //because self isn't in navigationStack
        self.navigationController?.pushViewController(entryVC, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMoneyAccountListTVC_ID" {
            moneyAccountListTableViewController = segue.destination as? AccountListTableViewController
        }
    }
}
