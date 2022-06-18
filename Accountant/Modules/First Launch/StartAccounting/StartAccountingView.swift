//
//  StartAccountingView.swift
//  Accountant
//
//  Created by Roman Topchii on 07.05.2022.
//

import UIKit

class StartAccountingView: UIView {

    let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.Size.cornerCardRadius
        view.backgroundColor = UIColor.systemGray5
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let goToBankProfilesButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Go to bank profiles",
                                          tableName: Constants.Localizable.startAccountingVC,
                                          comment: ""),
                        for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.Main.confirmButton
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 34
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3
        button.layer.masksToBounds =  false
        return button
    }()

    let continueButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.Main.confirmButton
        button.layer.cornerRadius = 34
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 3
        button.layer.masksToBounds =  false
        return button
    }()

    unowned var controller: StartAccountingViewController

    required init(controller: StartAccountingViewController) {
        self.controller = controller
        super.init(frame: CGRect.zero)
        addUIComponents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addUIComponents() {

        updateForCurrentStep()
        continueButton.isHidden = true

        controller.view.backgroundColor = .systemBackground
        controller.view.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        mainView.addSubview(cardView)
        cardView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 8).isActive = true
        cardView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -8).isActive = true
        cardView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true

        cardView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 110).isActive = true

        mainView.addSubview(addButton)
        addButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20).isActive = true
        addButton.topAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 40).isActive = true

        controller.view.addSubview(continueButton)
        continueButton.bottomAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -89).isActive = true
        continueButton.trailingAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.trailingAnchor,
                                             constant: -40).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        continueButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
    }

    func addContentView(_ contentView: UIView) {
        mainView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: addButton.bottomAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
    }

    func addGoToBankProfilesButton() {
        mainView.addSubview(goToBankProfilesButton)
        goToBankProfilesButton.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.9).isActive = true
        goToBankProfilesButton.heightAnchor.constraint(equalToConstant: 68).isActive = true
        goToBankProfilesButton.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        goToBankProfilesButton.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 40).isActive = true
    }

    func removeGoToBankProfilesButton() {
        goToBankProfilesButton.removeFromSuperview()
    }

    func updateForCurrentStep() {
        titleLabel.text = controller.workFlowTitleArray[controller.currentStep]
    }
}
