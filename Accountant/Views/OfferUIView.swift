//
//  OfferUIView.swift
//  Accountant
//
//  Created by Roman Topchii on 05.09.2021.
//


import UIKit
import Purchases

class OfferUIView: UIView {
    
    let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 2.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let priceTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    let introductoryDurationLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    var offerDisclaimerLabel = ""
    var purchaseButonTitle = ""
    
    let periodTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    let additionalSaleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemPink
        imageView.alpha = 0
        return imageView
    }()
    
    let salesBadgeView: SalesBadgeUIView = {
        let view = SalesBadgeUIView()
        view.alpha = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.Size.cornerButtonRadius
        return view
    }()

    lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.Size.cornerMainRadius
        view.backgroundColor = UIColor.systemGray3
        return view
    }()
    
    let activeBorderColor = UIColor.red
    let inactiveBorderColor = UIColor.systemGray3
    var packageForPurchase: Purchases.Package?
    private var isEligible = false
    private var minMonthPrice: NSDecimalNumber = 0
    var isActive = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = inactiveBorderColor
        
        let heightConstant = CGFloat(66)
        let widthConstant = CGFloat(UIScreen.main.bounds.width - 25 * 2)
        self.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        self.widthAnchor.constraint(equalToConstant: widthConstant).isActive = true
        self.layer.cornerRadius = Constants.Size.cornerMainRadius
        
        //MARK: - Background View
        self.addSubview(backgroundView)
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1).isActive = true
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
        
        //MARK: - Checkmark ImageView
        backgroundView.addSubview(checkmarkImageView)
        checkmarkImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        checkmarkImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkmarkImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 0).isActive = true
        checkmarkImageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10).isActive = true
        
        //MARK: - Title Stack subview
        backgroundView.addSubview(titleStackView)
        titleStackView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        titleStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10).isActive = true
     
    }
    
    func setCurrentPackage(package: Purchases.Package, isEligible: Bool, minMonthPrice: NSDecimalNumber) {
        
        //Set The Package
        self.packageForPurchase = package
        self.minMonthPrice = minMonthPrice
        
        
        self.isEligible = isEligible
        
        //Get the product
        let product = package.product
        let price = package.localizedPriceString
        
        var duration = ""
        switch (product.subscriptionPeriod!.unit, product.subscriptionPeriod!.numberOfUnits) {
        case (.day, 7):
            duration = NSLocalizedString("per week", comment: "")
        case (.week, 1):
            duration = NSLocalizedString("per week", comment: "")
        case (.month, 1):
            duration = NSLocalizedString("per month", comment: "")
        case (.month, 2):
            duration = NSLocalizedString("per 2 months", comment: "")
        case (.month, 3):
            duration = NSLocalizedString("per 3 months", comment: "")
        case (.month, 6):
            duration = NSLocalizedString("per 6 months", comment: "")
        case (.year, 1):
            duration = NSLocalizedString("per year", comment: "")
            self.isActive = true
            makeViewActive()
        default:
            duration = ""
        }
        
        //Sales badge show
        let discount = discountCalculation()
        if  discount > 0 && ((product.subscriptionPeriod!.unit == .month && product.subscriptionPeriod!.numberOfUnits > 1 ) || product.subscriptionPeriod!.unit == .year){
        addSalesViewBadge(discount: discount)
        }
        
        self.offerDisclaimerLabel = NSLocalizedString("A subscription is automatically renewed unless you cancel it at least 24 hours before the end of the billing cycle. The renewal fee will be charged on the day before the end of the current billing cycle. You can manage or cancel subscription in your iTunes account settings", comment: "")
        
        self.purchaseButonTitle = NSLocalizedString("Subscribe", comment: "")
        
        
            if isEligible && product.introductoryPrice?.type == .introductory {
                self.purchaseButonTitle = NSLocalizedString("Try for free", comment: "")
                var trialDuration = ""
                switch (product.introductoryPrice?.subscriptionPeriod.unit, product.introductoryPrice?.numberOfPeriods){
                case (.day, 3):
                    trialDuration = NSLocalizedString("per 3 days", comment: "")
                case (.week, 1):
                    trialDuration = NSLocalizedString("per 7 days", comment: "")
                case (.week, 2):
                    trialDuration = NSLocalizedString("per 14 days", comment: "")
                case (.month, 1):
                    trialDuration = NSLocalizedString("per month", comment: "")
                case (.month, 3):
                    trialDuration = NSLocalizedString("per 3 months", comment: "")
                case (.month, 6):
                    trialDuration = NSLocalizedString("per 6 months", comment: "")
                case (.year, 1):
                    trialDuration = NSLocalizedString("per year", comment: "")
                default:
                    trialDuration = ""
                }
                
                introductoryDurationLabel.text = trialDuration + NSLocalizedString("for free", comment: "")
                
                priceTitleLabel.text = "\(NSLocalizedString("after", comment: "")) \(price) \(duration)"
                priceTitleLabel.textColor = self.activeBorderColor
                
                titleStackView.addArrangedSubview(introductoryDurationLabel)
                titleStackView.addArrangedSubview(priceTitleLabel)
            }
            else {
                priceTitleLabel.text = "\(price) \(duration)"
                titleStackView.addArrangedSubview(priceTitleLabel)
            }
    }
    
    func makeViewActive() {
        self.backgroundColor = self.activeBorderColor
        checkmarkImageView.alpha = 1
    }
    
    func makeViewInactive() {
        self.backgroundColor = self.inactiveBorderColor
        checkmarkImageView.alpha = 0
    }
    
    func discountCalculation() -> Int {
        guard let product = self.packageForPurchase?.product, product.subscriptionPeriod!.numberOfUnits != 0 else {return 0}
        
        var subscriptionPeriodInMonths: Int = 0
        switch product.subscriptionPeriod!.unit {
        case .month:
            subscriptionPeriodInMonths = product.subscriptionPeriod!.numberOfUnits
        case .year:
            subscriptionPeriodInMonths = product.subscriptionPeriod!.numberOfUnits * 12
        default:
            break
        }
        
        guard subscriptionPeriodInMonths != 0 else {return 0}
        
        return Int((1 - Double(truncating: product.price)/(Double(subscriptionPeriodInMonths) * Double(truncating: self.minMonthPrice)))*100)
    }
    
    
    func addSalesViewBadge(discount: Int) {
            self.insertSubview(salesBadgeView, at: 0)
            salesBadgeView.label.text = "\(NSLocalizedString("Discount", comment: "")) \(discount)%"
            let badgeWidth = salesBadgeView.label.intrinsicContentSize.width + 6
            salesBadgeView.widthAnchor.constraint(equalToConstant: badgeWidth).isActive = true
            salesBadgeView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 5).isActive = true
            salesBadgeView.topAnchor.constraint(equalTo: self.topAnchor, constant: -7).isActive = true
            self.bringSubviewToFront(salesBadgeView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
