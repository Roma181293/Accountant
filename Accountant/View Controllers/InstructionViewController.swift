//
//  InstructionViewController.swift
//  Accountant
//
//  Created by Roman Topchii on 30.10.2021.
//

import UIKit

class InstructionViewController: UIViewController, UIScrollViewDelegate {

    private var slides: [UIView] = []
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.tintColor = .opaqueSeparator
        pageControl.currentPageIndicatorTintColor = .gray
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
//        scrollView.alwaysBounceHorizontal = true
//        scrollView.bounces = false
        scrollView.isPagingEnabled = true
//        scrollView.axis = .horizontal
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let closeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.lightGray
        return imageView
    }()
    
    
    let skipButton : UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Skip", comment: "").uppercased(), for: .normal)
        button.backgroundColor = UIColor.systemIndigo
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.layer.cornerRadius = Constants.Size.cornerButtonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    @objc func closeViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        guard sender != nil else {
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    var showSkipButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        //MARK: - Close Image View subview
        if !showSkipButton {
            view.addSubview(self.closeImageView)
            closeImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            closeImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            closeImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
            closeImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
            closeImageView.isUserInteractionEnabled = true
            let gestureClose = UITapGestureRecognizer(target: self, action: #selector(self.closeViewTapped(_:)))
            closeImageView.addGestureRecognizer(gestureClose)
        }
        
        if showSkipButton {
            view.addSubview(skipButton)
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            skipButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
            let gradientPinkView = GradientView(frame: skipButton.bounds, colorTop: .systemPink, colorBottom: .systemRed)
            gradientPinkView.layer.cornerRadius = Constants.Size.cornerButtonRadius
            skipButton.insertSubview(gradientPinkView, at: 0)
            skipButton.layer.masksToBounds = false;
        }
        
        view.addSubview(pageControl)
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        if showSkipButton {
            pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor,constant: -10).isActive = true
        }
        else {
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -20).isActive = true
        }
        
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        if !showSkipButton {
            scrollView.topAnchor.constraint(equalTo: closeImageView.bottomAnchor,constant: 10).isActive = true
        }
        else {
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 10).isActive = true
        }
        scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor).isActive = true
        
        updateUI()
    }
    

    
    public func updateUI() {
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        pageControl.numberOfPages = slides.count
        pageControl.hidesForSinglePage = true
    }
    
    
    
    private func createSlides() -> [UIView] {
        var result : [UIView] = []
        let guideList = [Guide(title: NSLocalizedString("Change category/account structure", comment: ""),
                               image: "editCategory",
                               body: nil,
                               items: [GuideItem(image: "plus", backgroungColor: UIColor.systemGreen, text: NSLocalizedString("Add subcategory to the selected item", comment: "")),
                                       GuideItem(image: "pencil", backgroungColor: UIColor.systemBlue, text: NSLocalizedString("Rename selected item", comment: "")),
                                       GuideItem(image: "trash", backgroungColor: UIColor.systemRed, text: NSLocalizedString("Delete selected item", comment: "")),
                                       GuideItem(image: "eye.slash", backgroungColor: UIColor.systemGray, text: NSLocalizedString("Hide selected item", comment: "")),
                                       GuideItem(image: "eye", backgroungColor: UIColor.systemIndigo, text: NSLocalizedString("Unhide selected item", comment: ""))])
                         ,Guide(title: "Accounting principle", image: nil, body: "When you add an transaction, the balance simultaneously changes for at least of two accounts/categories at once:", items: [
                            GuideItem(emoji: "📥", text: NSLocalizedString("Income:\nFrom:Income:Salary +1000\nTo:Money:Bank card +1000", comment: ""))
                            ,GuideItem(emoji: "📤", text: NSLocalizedString("Expense:\nFrom:Money:Bank card -1000\nTo:Expenses:Food +1000", comment: ""))
                            ,GuideItem(emoji: "📤📥", text: NSLocalizedString("Transfer:\nFrom:Money:Bank card -1000\nTo:Money:Cash +1000", comment: ""))
                            ,GuideItem(emoji: "💸", text: NSLocalizedString("Lend or open deposit:\nFrom:Money:Bank card -1000\nTo:Debtors:John Smit +1000", comment: ""))
                            ,GuideItem(emoji: "🏦", text: NSLocalizedString("Borrow or increase credit limit:\nFrom:Credits:Bank +1000\nTo:Money:Bank card +1000", comment: ""))
//                            ,GuideItem(emoji: "📤📥", text: NSLocalizedString("Repayment of a credit OR decrease credit limit:\nFrom:Money:Bank card -1000\nTo:Credits:Bank -1000", comment: ""))
                         ])
                         
                         ,Guide(title: NSLocalizedString("Multi item transaction", comment: ""),
                                image: "multiItemTransaction",
                                body: "Create transaction that represent your receipt from the market or distribute your income for different subcategories in single place",
                                items: [GuideItem(emoji:"🤔",backgroungColor: UIColor.systemIndigo, text: NSLocalizedString("You can create transaction with single \"From\" item and multiple \"To\" items\nOR\nmultiple \"From\" items and single \"To\" item", comment: "")),
                                        GuideItem(image: "trash", backgroungColor: UIColor.systemRed, text: NSLocalizedString("Delete selected item", comment: "")),
                                        GuideItem(image: "plus", backgroungColor: UIColor.systemGreen, text: NSLocalizedString("Add transaction item", comment: ""))
                                       ])
                         ,Guide(title: NSLocalizedString("Monobank sync", comment: ""),
                                image: nil,
                                body: NSLocalizedString("Now you can sync your Monobank transaction", comment: ""),
                                items: [GuideItem(emoji:"🤖", text: NSLocalizedString("Easy to use. No need to add thansactions manually", comment: "")),
                                        GuideItem(emoji:"👨‍🎓", text: NSLocalizedString("First time you need specify which category this transaction relates. But for the next time we automatically fill this category/account. You just need to check this transaction and confirm correctness", comment: "")),
                                        GuideItem(emoji:"🔒", text: NSLocalizedString("All bank data hosts only on your device locally", comment: "")),
                                        GuideItem(emoji:"🥺", text: NSLocalizedString("Privacy. You can delete all data related to your bank", comment: "")),
                                        
                                        
                                       ])
                         //                         ,Guide(title: NSLocalizedString("Settings", comment: ""),
                         //                                image: nil,
                         //                                body: nil,
                         //                                items: [
                         //                                    GuideItem(image: "list.number", tintColor: UIColor.blue, text: NSLocalizedString("Change switcher position to on state when you need to create multi item transaction", comment: ""))
                         //                                ,GuideItem(image: "list.bullet.indent", backgroungColor: UIColor.systemRed, text: NSLocalizedString("Here you can change account and category structure. Unhide hidden elements", comment: ""))])
        ]
        
        for index in 0...guideList.count-1 {
            let slide : GuideView = GuideView(frame: CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: view.frame.height*0.7))
            
            slide.setGuide(guideList[index])
            result.append(slide)
        }
        return result
    }
    
    
    private func setupSlideScrollView(slides : [UIView]) {
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height*0.7)
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height*0.7)
            scrollView.addSubview(slides[i])
            slides[i].widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
            slides[i].heightAnchor.constraint(equalToConstant: view.frame.height*0.7).isActive = true
        }
        
        slides.first!.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        
        slides[1].leadingAnchor.constraint(equalTo: slides.first!.trailingAnchor).isActive = true
        slides[1].trailingAnchor.constraint(equalTo: slides.last!.leadingAnchor).isActive = true
        slides.last!.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
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
        
//        if slides.count == 4 {
//            if(percentOffset.x > 0 && percentOffset.x <= 0.33) {
//
//                slides[0].transform = CGAffineTransform(scaleX: (0.33-percentOffset.x)/0.33, y: (0.33-percentOffset.x)/0.33)
//                slides[1].transform = CGAffineTransform(scaleX: percentOffset.x/0.33, y: percentOffset.x/0.33)
//
//            } else if(percentOffset.x > 0.33 && percentOffset.x <= 0.66) {
//                slides[1].transform = CGAffineTransform(scaleX: (0.66-percentOffset.x)/0.33, y: (0.66-percentOffset.x)/0.33)
//                slides[2].transform = CGAffineTransform(scaleX: percentOffset.x/0.66, y: percentOffset.x/0.66)
//
//            } else if(percentOffset.x > 0.66 && percentOffset.x <= 1) {
//                slides[2].transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.33, y: (1-percentOffset.x)/0.33)
//                slides[3].transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
//            }
//        }
//        else if slides.count == 3 {
//
//            if(percentOffset.x > 0 && percentOffset.x <= 0.5) {
//
//                slides[0].transform = CGAffineTransform(scaleX: (0.5-percentOffset.x)/0.5, y: (0.5-percentOffset.x)/0.5)
//                slides[1].transform = CGAffineTransform(scaleX: percentOffset.x/0.5, y: percentOffset.x/0.5)
//            } else if(percentOffset.x > 0.5 && percentOffset.x <= 1) {
//                slides[1].transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.5, y: (1-percentOffset.x)/0.5)
//                slides[2].transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
//            }
//        }
    }
}
