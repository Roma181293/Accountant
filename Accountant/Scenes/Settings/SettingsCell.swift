//
//  SettingsTableViewCell.swift
//  Accountant
//
//  Created by Roman Topchii on 10.09.2021.
//

import UIKit
import LocalAuthentication

class SettingsCell: UITableViewCell {

    private var dataItem: SettingsViewController.DataSource!
    private var delegate: SettingsViewController!

    private let iconImangeView: UIImageView = {
        let imageView  = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView .translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let badgeView: BadgeView = {
        let view = BadgeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.Size.cornerButtonRadius
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.Main.defaultCellTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.Main.defaultCellTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        badgeView.isHidden = true
        iconImangeView.isHidden = false
        switcher.isHidden = true
        detailLabel.text = nil
        activityIndicator.isHidden = true
        accessoryType = .none
    }

    func configureCell(for dataItem: SettingsViewController.DataSource, with delegate: SettingsViewController) { // swiftlint:disable:this cyclomatic_complexity function_body_length line_length
        self.delegate = delegate
        self.dataItem = dataItem

        badgeView.isHidden = true
        iconImangeView.isHidden = false
        switcher.isHidden = true
        detailLabel.text = nil
        activityIndicator.isHidden = true
        accessoryType = .none
        titleLabel.text = NSLocalizedString(dataItem.rawValue,
                                            tableName: Constants.Localizable.settingsVC,
                                            comment: "")
        switch dataItem {
        case .offer:
            if delegate.isUserHasPaidAccess {
                titleLabel.text = NSLocalizedString("PRO access",
                                                    tableName: Constants.Localizable.settingsVC,
                                                    comment: "")
            } else {
                titleLabel.text = NSLocalizedString("Get PRO access",
                                                    tableName: Constants.Localizable.settingsVC,
                                                    comment: "")
            }
            if delegate.isUserHasPaidAccess && delegate.proAccessExpirationDate != nil {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .none
                formatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")") // swiftlint:disable:this line_length
                detailLabel.text = NSLocalizedString("till", comment: "") + " " + formatter.string(from: delegate.proAccessExpirationDate!) // swiftlint:disable:this line_length
            }
            badgeView.proBadge()
            badgeView.isHidden = false
            iconImangeView.isHidden = true
        case .auth:
            switcher.isHidden = false
            let context = LAContext()
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
                if context.biometryType == .faceID {
                    titleLabel.text = "FaceID"
                    iconImangeView.image = UIImage(systemName: "faceid")
                } else if context.biometryType == .touchID {
                    titleLabel.text = "TouchID"
                    iconImangeView.image = UIImage(systemName: "touchid")
                } else if context.biometryType == .none {
                    titleLabel.text = NSLocalizedString("Pin code",
                                                        tableName: Constants.Localizable.settingsVC,
                                                        comment: "")
                    iconImangeView.image = UIImage(systemName: "lock.fill")
                }

                switch UserProfile.getUserAuth() {
                case .bioAuth:
                    switcher.isOn = true
                case .none:
                    switcher.isOn = false
                }
            }
            iconImangeView.tintColor = .systemOrange
        case .envirement:
            switcher.isHidden = false
            if CoreDataStack.shared.activeEnviroment() == .prod {
                switcher.isOn = false
            } else if CoreDataStack.shared.activeEnviroment() == .test {
                switcher.isOn = true
            }
            iconImangeView.image = UIImage(systemName: "gamecontroller")
            iconImangeView.tintColor = .systemYellow
        case .accountingCurrency:
            if let currency = CurrencyHelper.getAccountingCurrency(context: delegate.context) {
                detailLabel.text = currency.code
            } else {
                detailLabel.text = "No currency"
            }
            iconImangeView.image = UIImage(systemName: "dollarsign.circle")
            iconImangeView.tintColor = .systemGreen
        case .archive:
            iconImangeView.image = UIImage(systemName: "archivebox")
            iconImangeView.tintColor = .systemBrown
            accessoryType = .disclosureIndicator
        case .accountsManager:
            iconImangeView.image = UIImage(systemName: "list.bullet.indent")
            iconImangeView.tintColor = .systemRed
            accessoryType = .disclosureIndicator
        case.multiItemTransaction:
            switcher.isHidden = false
            iconImangeView.image = UIImage(systemName: "list.number")
            iconImangeView.tintColor = .blue
            switcher.isOn = UserProfile.isUseMultiItemTransaction(environment: delegate.environment)
            accessoryType = .none
        case .importTransactions:
            iconImangeView.image = UIImage(systemName: "square.and.arrow.down.on.square")
            iconImangeView.tintColor = .systemIndigo
        case .importAccounts:
            iconImangeView.image = UIImage(systemName: "tray.and.arrow.down")
            iconImangeView.tintColor = .systemTeal
        case .exportTransactions:
            iconImangeView.image = UIImage(systemName: "square.and.arrow.up.on.square")
            iconImangeView.tintColor = .systemPurple
        case .exportAccounts:
            iconImangeView.image = UIImage(systemName: "tray.and.arrow.up")
            iconImangeView.tintColor = .cyan
        case .termsOfUse:
            iconImangeView.image = UIImage(systemName: "doc")
            iconImangeView.tintColor = .systemBlue
            accessoryType = .disclosureIndicator
        case .privacyPolicy:
            iconImangeView.image = UIImage(systemName: "lock.shield.fill")
            iconImangeView.tintColor = .systemBlue
            accessoryType = .disclosureIndicator
        case .startAccounting:
            iconImangeView.image = UIImage(systemName: "paperplane.fill")
            iconImangeView.tintColor = .systemYellow
            accessoryType = .disclosureIndicator
        case .userGuides:
            iconImangeView.image = UIImage(systemName: "info.circle.fill")
            iconImangeView.tintColor = .systemRed
            accessoryType = .none
        case .bankProfiles:
            iconImangeView.image = UIImage(systemName: "building.columns.fill")
            iconImangeView.tintColor = .orange
            accessoryType = .disclosureIndicator
        case .exchangeRates:
            badgeView.exchangeBadge()
            badgeView.isHidden = false
            iconImangeView.isHidden = true
            accessoryType = .disclosureIndicator
        }

        contentView.addSubview(iconImangeView)
        iconImangeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        iconImangeView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        iconImangeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true
        iconImangeView.widthAnchor.constraint(equalTo: iconImangeView.heightAnchor).isActive = true

        contentView.addSubview(badgeView)
        badgeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        badgeView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        badgeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true
        badgeView.widthAnchor.constraint(equalTo: iconImangeView.heightAnchor).isActive = true

        contentView.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: iconImangeView.trailingAnchor, constant: 8).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        contentView.addSubview(detailLabel)
        detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        detailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        contentView.addSubview(switcher)
        switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22).isActive = true
        switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        switcher.addTarget(self, action: #selector(self.switching(_:)), for: .valueChanged)

        contentView.addSubview(activityIndicator)
        activityIndicator.trailingAnchor.constraint(equalTo: switcher.leadingAnchor, constant: -8).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    @objc private func switching(_ sender: UISwitch) {
        if dataItem == .auth {
            if sender.isOn {
                UserProfile.setUserAuth(.bioAuth)
            } else {
                UserProfile.setUserAuth(.none)
            }
        } else if dataItem == .multiItemTransaction {
            UserProfile.useMultiItemTransaction(sender.isOn, environment: delegate.environment)
        } else if dataItem == .envirement {
            activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            delegate.setEnvironmentToTest(sender.isOn)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
}
