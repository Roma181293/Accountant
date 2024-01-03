//
//  PurchaseOfferViewController.swift
//  Accounting
//
//  Created by Roman Topchii on 06.02.2021.
//  Copyright © 2021 Roman Topchii. All rights reserved.
//

import UIKit
import Purchases
import SafariServices
import FirebaseAnalytics

final class PurchaseOfferViewController: UIViewController { // swiftlint:disable:this type_body_length

    let descriptionArray = [ ("♾", "Unlimited number of accounts, categories and subcategories"),
                             ("✔", "Subcategories. Create income and expense strucrure"),
                             ("₴＄€", "Account creation in currencies different from accounting currency"),
                             ("🙈", "Hide accounts and categories"),
                             ("🧾🧾", "Duplicate transactions"),
                             ("🤫", "Export and import of transactions"),
                             ("🔒", "Security")
    ]

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = "MyBudget"
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    let descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.backgroundColor = UIColor(white: 1, alpha: 0)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let subscriptionLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    let iHavePaidAcccessActivityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = UIColor.darkGray
        view.alpha = 0
        view.startAnimating()
        return view
    }()

    let iHavePaidAcccessLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = NSLocalizedString("Already have a \"PRO\" subscription?",
                                            tableName: Constants.Localizable.purchaseOfferVC,
                                            comment: "")
        label.textColor = UIColor.systemBlue
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let termsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = NSLocalizedString("Terms of use",
                                            tableName: Constants.Localizable.purchaseOfferVC,
                                            comment: "")
        label.textColor = UIColor.systemBlue
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let policyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = NSLocalizedString("Privacy policy",
                                            tableName: Constants.Localizable.purchaseOfferVC,
                                            comment: "")
        label.textColor = UIColor.systemBlue
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let proBadgeView: BadgeView = {
        let view = BadgeView()
        view.proBadge()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.Size.cornerButtonRadius
        return view
    }()

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20.0
        stackView.backgroundColor = UIColor(white: 1, alpha: 0)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let offerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 20.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let purchaseButon: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Subscribe",
                                          tableName: Constants.Localizable.purchaseOfferVC,
                                          comment: "").uppercased(),
                        for: .normal)
        button.backgroundColor = UIColor.systemIndigo
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        return view
    }()

    let closeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.lightGray
        return imageView
    }()

    let purchaseButtonActivityIndicatorImageView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = UIColor.white
        view.alpha = 0
        view.startAnimating()
        return view
    }()

    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = UIColor.white
        view.alpha = 0
        view.startAnimating()
        return view
    }()

    let loaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        return view
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(white: 1, alpha: 0)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        return view
    }()

    var packagesAvailableForPurchase = [Purchases.Package]()
    var offerViews = [OfferView]()
    var activeOfferTag: Int?
    var topStackConstant = CGFloat(0)
    var statusBarShouldBeHidden = false
    var statusBarAnimationStyle: UIStatusBarAnimation = .slide

    override func viewDidLoad() { // swiftlint:disable:this function_body_length
        super.viewDidLoad()

        Analytics.logEvent("show_purchase_offer_view", parameters: [
          "name": "show_purchase_offer_view" as NSObject,
          ])

        view.backgroundColor = .systemBackground
        // MARK: - Scroll View
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        scrollView.isScrollEnabled = true
        // MARK: - Close Image View subview
        self.view.addSubview(self.closeImageView)
        closeImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeImageView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor,
                                            constant: 20).isActive = true
        closeImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        let gestureClose = UITapGestureRecognizer(target: self, action: #selector(self.closeViewTapped(_:)))
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(gestureClose)
        // MARK: - Content View
        scrollView.addSubview(contentView)
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        // MARK: - Main Stack View
        contentView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        mainStackView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -40).isActive = true
        // MARK: - Main Title
        mainStackView.addArrangedSubview(titleView)
        let titleSpacing = CGFloat(7.0)
        let titleViewWidth = titleLabel.intrinsicContentSize.width + proBadgeView.getWidth() + titleSpacing
        let titleViewHeight = proBadgeView.getHeight()
        titleView.widthAnchor.constraint(equalToConstant: titleViewWidth).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: titleViewHeight).isActive = true
        titleView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 0).isActive = true
        titleView.addSubview(proBadgeView)
        proBadgeView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor,
                                              constant: titleSpacing).isActive = true
        // MARK: - Description Stack View
        descriptionArray.forEach({item in
            configureDescriptionItem(item)
        })
        mainStackView.addArrangedSubview(descriptionStackView)
        mainStackView.setCustomSpacing(30, after: descriptionStackView)
        // MARK: - Loader View
        mainStackView.addArrangedSubview(loaderView)
        loaderView.heightAnchor.constraint(equalToConstant: 386).isActive = true
        // MARK: - Activity Indicator Image View
        loaderView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: loaderView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: loaderView.centerYAnchor,
                                                            constant: -386/4).isActive = true
        activityIndicator.alpha = 1
        // MARK: - Fetching Purchase Products
        fetchPurchaseProudcts()
    }

    private func configureDescriptionItem(_ item: (String, String)) {
        let descriptionItemStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.spacing = 8.0
            stackView.backgroundColor = UIColor(white: 1, alpha: 0)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()

        let emojiLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.text = item.0
            label.textColor = .label
            label.font = UIFont.boldSystemFont(ofSize: 30.0)
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .left
            label.text = NSLocalizedString(item.1, tableName: Constants.Localizable.purchaseOfferVC, comment: "")
            label.textColor = .label
            label.font = UIFont.boldSystemFont(ofSize: 16.0)
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        emojiLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        descriptionLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 360).isActive = true
        descriptionItemStackView.addArrangedSubview(emojiLabel)
        descriptionItemStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(descriptionItemStackView)
    }

    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: contentView.frame.size.height)
    }

    func fetchPurchaseProudcts() {
        Purchases.shared.offerings { (offerings, _) in
            if let offerings = offerings {
                let activeOffer = RemoteConfigValues.shared.getActiveOffer()

                guard let packages = offerings.offering(identifier: activeOffer)?.availablePackages else {return}
                // Add package
                self.packagesAvailableForPurchase = packages
                var minMonthPrice: NSDecimalNumber = 0.0
                var productIdentifiers: [String] = []
                for package in self.packagesAvailableForPurchase {
                    productIdentifiers.append(package.product.productIdentifier)
                    if package.product.subscriptionPeriod?.unit == .month
                        && package.product.subscriptionPeriod?.numberOfUnits == 1 {
                        minMonthPrice = package.product.price
                    }
                }
                Purchases.shared.checkTrialOrIntroductoryPriceEligibility(productIdentifiers,
                                                                          completionBlock: { result in
                    self.mainStackView.addArrangedSubview(self.offerStackView)

                    for index in 0...self.packagesAvailableForPurchase.count - 1 {
                        // Get the package
                        let package = self.packagesAvailableForPurchase[index]

                        // Add The Offer View
                        let offerView = OfferView()
                        self.offerStackView.addArrangedSubview(offerView)
                        offerView.tag = index
                        let gesture = OfferUITapGestureRecognizer(target: self,
                                                                  action: #selector(self.offerViewTapped(_:)))
                        offerView.addGestureRecognizer(gesture)
                        gesture.tappedOffer = offerView

                        // Set the current package to The Offer View
                        offerView.setCurrentPackage(package: package,
                                                    isEligible: result[package.product.productIdentifier]?.status != .ineligible, // swiftlint:disable:this line_length
                                                    minMonthPrice: minMonthPrice)
                        self.offerViews.append(offerView)
                        if offerView.isActive {
                            self.activeOfferTag = offerView.tag
                            self.subscriptionLabel.text = offerView.offerDisclaimerLabel
                            self.purchaseButon.setTitle(offerView.purchaseButonTitle.uppercased(), for: .normal)
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                    self.loaderView.removeFromSuperview()
                    self.mainStackView.setCustomSpacing(40, after: self.offerStackView)

                    // MARK: - Purchase Button
                    self.addPurchaseButton()

                    // MARK: - Bottom Description
                    self.addBottomDescription()
                })
            }
        }
    }

    func addPurchaseButton() {
        let widthBtn = CGFloat(UIScreen.main.bounds.width - 25 * 2)
        purchaseButon.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        purchaseButon.widthAnchor.constraint(equalToConstant: widthBtn).isActive = true
        purchaseButon.layer.cornerRadius = Constants.Size.cornerButtonRadius

        let gradientView = GradientView(frame: purchaseButon.bounds, colorTop: .systemBlue, colorBottom: .systemYellow)
        gradientView.layer.cornerRadius = Constants.Size.cornerButtonRadius

        // Add the activity indicator to the button
        gradientView.addSubview(purchaseButtonActivityIndicatorImageView)
        let horizontalBtnConstraint = NSLayoutConstraint(item: purchaseButtonActivityIndicatorImageView,
                                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                                         toItem: gradientView,
                                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                                         multiplier: 1,
                                                         constant: 0)
        let verticalBtnConstraint = NSLayoutConstraint(item: purchaseButtonActivityIndicatorImageView,
                                                       attribute: NSLayoutConstraint.Attribute.centerY,
                                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                                       toItem: gradientView,
                                                       attribute: NSLayoutConstraint.Attribute.centerY,
                                                       multiplier: 1,
                                                       constant: 0)
        NSLayoutConstraint.activate([horizontalBtnConstraint, verticalBtnConstraint])

        purchaseButon.insertSubview(gradientView, at: 0)
        purchaseButon.layer.masksToBounds = false
        mainStackView.addArrangedSubview(purchaseButon)

        gradientView.addTarget(self, action: #selector(purchaseButtonTouchDown), for: .touchDown)
        gradientView.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
    }

    func addBottomDescription() {
        mainStackView.addArrangedSubview(iHavePaidAcccessActivityIndicator)
        mainStackView.addArrangedSubview(iHavePaidAcccessLabel)
        mainStackView.addArrangedSubview(subscriptionLabel)
        mainStackView.addArrangedSubview(termsLabel)
        mainStackView.setCustomSpacing(10, after: termsLabel)
        mainStackView.addArrangedSubview(policyLabel)

        let iHavePaidAcccessTap = UITapGestureRecognizer(target: self, action: #selector(self.restorePurchases))
        iHavePaidAcccessLabel.isUserInteractionEnabled = true
        iHavePaidAcccessLabel.addGestureRecognizer(iHavePaidAcccessTap)

        let termsTap = UITapGestureRecognizer(target: self, action: #selector(self.termsLabelTapped(_:)))
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(termsTap)

        let policyTap = UITapGestureRecognizer(target: self, action: #selector(self.policyLabelTapped(_:)))
        policyLabel.isUserInteractionEnabled = true
        policyLabel.addGestureRecognizer(policyTap)
    }

    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarAnimationStyle
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc func offerViewTapped(_ sender: OfferUITapGestureRecognizer? = nil) {
        guard sender != nil else {return}
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if let tappedOffer = sender!.tappedOffer {
            let currentOfferTag = tappedOffer.tag
            self.activeOfferTag = currentOfferTag
            for offer in self.offerViews {
                if offer.tag == self.activeOfferTag && !offer.isActive {
                    offer.isActive = true
                    offer.makeViewActive()
                    self.subscriptionLabel.text = offer.offerDisclaimerLabel
                    self.purchaseButon.setTitle(offer.purchaseButonTitle.uppercased(), for: .normal)
                } else if offer.tag != self.activeOfferTag {
                    offer.isActive = false
                    offer.makeViewInactive()
                }
            }
        }
    }

    @objc func closeViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        guard sender != nil else {
            return
        }
        Analytics.logEvent("dismiss_purchase_button_tapped", parameters: [
          "name": "dismiss_purchase_button_tapped" as NSObject,
          ])
        self.dismiss(animated: true, completion: nil)
    }

    @objc func cancelButtonTapped(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func purchaseButtonTouchDown(_ sender: UIButton) {
        //        UICustomization.animateScaleButtonTouchDown(button: purchaseButon)
    }

    @objc func purchaseButtonTapped(_ sender: UIButton) {
        
        Analytics.logEvent("purchase_button_tapped", parameters: [
          "name": "purchase_button_tapped" as NSObject,
          ])
        
        self.disablePurchaseButton()

        if let tag = activeOfferTag {
            if let package = self.offerViews[tag].packageForPurchase {
                Purchases.shared.purchasePackage(package) { (_, purchaserInfo, _, userCancelled) in
                    if userCancelled {
                        self.enablePurchaseButton()
                    }
                    let isActive = purchaserInfo?.entitlements["pro"]!.isActive
                    if isActive == true {
                        NotificationCenter.default.post(name: .receivedProAccessData, object: nil)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.enablePurchaseButton()
                    }
                }
            }
        }
    }

    @objc func restorePurchases() {
        self.iHavePaidAcccessActivityIndicator.startAnimating()
        self.iHavePaidAcccessActivityIndicator.alpha = 1

        var message = ""

        Purchases.shared.restoreTransactions {[weak self] (purchaserInfo, error) in

            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                message = NSLocalizedString("We found active subscriptions. We wish you a pleasant use",
                                            tableName: Constants.Localizable.purchaseOfferVC,
                                            comment: "")
            } else {
                message = NSLocalizedString("We found no active subscriptions",
                                            tableName: Constants.Localizable.purchaseOfferVC,
                                            comment: "")
            }

            NotificationCenter.default.post(name: .receivedProAccessData, object: nil)

            let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "ОК", style: .default, handler: nil)

            alert.addAction(cancelAction)
            self?.present(alert, animated: true)

            self?.iHavePaidAcccessActivityIndicator.alpha = 0
            self?.iHavePaidAcccessActivityIndicator.stopAnimating()
        }
    }

    func disablePurchaseButton() {
        purchaseButon.isUserInteractionEnabled = false
        purchaseButon.titleLabel?.alpha = 0
        self.purchaseButtonActivityIndicatorImageView.startAnimating()
        self.purchaseButtonActivityIndicatorImageView.alpha = 1
    }

    func enablePurchaseButton() {
        purchaseButon.isUserInteractionEnabled = true
        purchaseButon.titleLabel?.alpha = 1
        self.purchaseButtonActivityIndicatorImageView.alpha = 0
        self.purchaseButtonActivityIndicatorImageView.stopAnimating()
    }

    @objc func termsLabelTapped(_ sender: UITapGestureRecognizer? = nil) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: Constants.URL.termsOfUse)
        let webVC = WebViewController(url: url!, configuration: config)
        self.present(webVC, animated: true, completion: nil)
    }

    @objc func policyLabelTapped(_ sender: UITapGestureRecognizer? = nil) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let url = URL(string: Constants.URL.privacyPolicy)
        let webVC = WebViewController(url: url!, configuration: config)
        self.present(webVC, animated: true, completion: nil)
    }
}
