//
//  WelcomeView.swift
//  Accountant
//
//  Created by Roman Topchii on 07.05.2022.
//

import UIKit

class WelcomeView: UIView {

    let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 30.0
        stackView.backgroundColor = UIColor(white: 1, alpha: 0)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = NSLocalizedString("Welcome", tableName: Constants.Localizable.welcome, comment: "").uppercased()
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let startAccountingButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Start accounting",
                                          tableName: Constants.Localizable.welcome,
                                          comment: "").uppercased(), for: .normal)
        button.backgroundColor = UIColor.systemIndigo
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let testButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Try functionality",
                                          tableName: Constants.Localizable.welcome,
                                          comment: "").uppercased(),
                        for: .normal)
        button.backgroundColor = UIColor.systemIndigo
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    unowned var controller: WelcomeViewController

    required init(controller: WelcomeViewController) {
        self.controller = controller
        super.init(frame: CGRect.zero)
        addUIComponents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addUIComponents() {

        controller.view.backgroundColor = .systemBackground
        controller.view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        // Main Stack View
        mainView.addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20).isActive = true
        mainStackView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        mainStackView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        mainStackView.addArrangedSubview(titleLabel)
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // Start Accounting Button
        let widthBtn = CGFloat(UIScreen.main.bounds.width - 25 * 2)
        startAccountingButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        startAccountingButton.widthAnchor.constraint(equalToConstant: widthBtn).isActive = true
        startAccountingButton.layer.cornerRadius = Constants.Size.cornerButtonRadius
        let gradientTopView = GradientView(frame: startAccountingButton.bounds,
                                            colorTop: .systemPurple,
                                            colorBottom: .systemBlue)
        gradientTopView.layer.cornerRadius = Constants.Size.cornerButtonRadius
        startAccountingButton.insertSubview(gradientTopView, at: 0)
        startAccountingButton.layer.masksToBounds = false
        mainStackView.addArrangedSubview(startAccountingButton)
        gradientTopView.addTarget(controller, action: #selector(controller.startAccounting), for: .touchUpInside)

        // Test Accounting Button
        testButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        testButton.widthAnchor.constraint(equalToConstant: widthBtn).isActive = true
        testButton.layer.cornerRadius = Constants.Size.cornerButtonRadius

        let gradientBottomView = GradientView(frame: testButton.bounds,
                                              colorTop: .systemOrange,
                                              colorBottom: .systemYellow)
        gradientBottomView.layer.cornerRadius = Constants.Size.cornerButtonRadius

        testButton.insertSubview(gradientBottomView, at: 0)
        testButton.layer.masksToBounds = false

        mainStackView.addArrangedSubview(testButton)
        gradientBottomView.addTarget(controller, action: #selector(controller.tryFunctionality), for: .touchUpInside)
    }
}
