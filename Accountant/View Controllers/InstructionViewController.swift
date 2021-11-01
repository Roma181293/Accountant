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
    
  
    
    override func loadView() {
        super.loadView()
//        var correction : CGFloat = 0
//        switch  UIDevice.modelName {
//        case "iPhone 6","iPhone 6 Plus", "iPhone 6s","iPhone 6s Plus", "iPhone 7","iPhone 7 Plus","iPhone 8","iPhone 8 Plus","iPhone SE (2nd generation)": correction = 24
//        case "iPhone 11","iPhone XR": correction = -4
//        case "iPhone X","iPhone XS","iPhone 11 Pro", "iPhone XS Max", "iPhone 11 Pro Max": correction = 0
//        case "iPhone 12 mini": correction = -6
//        case "iPhone 12","iPhone 12 Pro","iPhone 12 Pro Max": correction = -3
//        default: break
//        }
//        scrollView.frame = CGRect(x: 0, y: scrollView.frame.origin.y, width: view.frame.width, height: view.frame.height/2-scrollView.frame.origin.y+correction)
    }
    
    @objc func closeViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        guard sender != nil else {
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
//        scrollView.backgroundColor = .yellow
        
        //MARK: - Close Image View subview
        view.addSubview(self.closeImageView)
        closeImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
        closeImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        closeImageView.isUserInteractionEnabled = true
        let gestureClose = UITapGestureRecognizer(target: self, action: #selector(self.closeViewTapped(_:)))
        closeImageView.addGestureRecognizer(gestureClose)
        
        
        view.addSubview(skipButton)
        skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        let gradientPinkView = GradientView(frame: skipButton.bounds, colorTop: .systemPink, colorBottom: .systemRed)
        gradientPinkView.layer.cornerRadius = Constants.Size.cornerButtonRadius
        skipButton.insertSubview(gradientPinkView, at: 0)
        skipButton.layer.masksToBounds = false;
        
        view.addSubview(pageControl)
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor,constant: -20).isActive = true
        
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: closeImageView.bottomAnchor,constant: 10).isActive = true
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
        let array = ["text1","text2","text3"]
        
        
        for index in 0...array.count-1 {
            let slide : InstructionView = InstructionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            slide.label.text = array[index]
            slide.addAccountInstruction()
                
//                UIView = UIView()
////            slide.backgroundColor = .red
//            slide.translatesAutoresizingMaskIntoConstraints = false
//
//            let imageView: UIImageView = {
//               let imageView = UIImageView()
//                imageView.image = UIImage(named: "account-swipe")
//                imageView.contentMode = .scaleAspectFit
//                imageView.translatesAutoresizingMaskIntoConstraints = false
//                return imageView
//            }()
//
//            let label : UILabel = UILabel()
//            label.translatesAutoresizingMaskIntoConstraints = false
//
//
//            slide.addSubview(imageView)
//            imageView.leadingAnchor.constraint(equalTo: slide.leadingAnchor, constant: 10).isActive = true
//            imageView.trailingAnchor.constraint(equalTo: slide.trailingAnchor, constant: -10).isActive = true
//            imageView.topAnchor.constraint(equalTo: slide.topAnchor, constant: 10).isActive = true
//            imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
//            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
//
//
//            slide.addSubview(label)
//            label.centerXAnchor.constraint(equalTo: slide.centerXAnchor).isActive = true
//            label.centerYAnchor.constraint(equalTo: slide.centerYAnchor).isActive = true
//            label.text = array[index]
            
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
}
