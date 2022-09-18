//
//  SettingsItem.swift
//  Accountant
//
//  Created by Roman Topchii on 18.09.2022.
//

import UIKit

class SettingsItem {
    private let iconView: UIView

    private let title: String

    private(set) var hasDisclosureIndicator: Bool = false

    //Detail Components
    private var detailText: String? = nil

    private var hasSpiner: Bool = false

    private var hasSwitcher: Bool = false
    private var switcherIsOn: Bool = false
    private var switcherAction: ((Bool) -> Void)? = nil

    init(imageSystemName: String, iconColor: UIColor, title: String, hasDisclosureIndicator: Bool = false) {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: imageSystemName)
        imageView.tintColor = iconColor

        iconView = imageView
        self.title = title
        self.hasDisclosureIndicator = hasDisclosureIndicator
    }

    init(imageSystemName: String, iconColor: UIColor, title: String,
         switcherState: Bool, switcherAction: ((Bool) -> Void)? = nil,
         hasSpiner: Bool = false) {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: imageSystemName)
        imageView.tintColor = iconColor

        iconView = imageView
        self.title = title
        self.hasSwitcher = true
        self.switcherIsOn = switcherState
        self.switcherAction = switcherAction
        self.hasSpiner = hasSpiner
    }

    init(iconView: UIView, title: String, detailText: String?) {
        self.iconView = iconView
        self.title = title
        self.detailText = detailText
    }

    func getIconView() -> UIView {
        return iconView
    }

    func getTitleView() -> UIView {
        let titleView = UILabel()
        titleView.text = title
        titleView.translatesAutoresizingMaskIntoConstraints = false
        return titleView
    }

    func getDetailView() -> UIView {
        if detailText != nil {
            let label = UILabel()
            label.textColor = Colors.Main.defaultCellTextColor
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = detailText
            
            return label
        } else if hasSwitcher && hasSpiner {
            let spiner = UIActivityIndicatorView()
            spiner.isHidden = true
            spiner.translatesAutoresizingMaskIntoConstraints = false

            let switcher = UISwitch()
            switcher.isOn = switcherIsOn
            switcher.translatesAutoresizingMaskIntoConstraints = false
            switcher.addTarget(self, action: #selector(self.togleSwitcher(_:)), for: .valueChanged)

            let detailView = UIView()
            detailView.translatesAutoresizingMaskIntoConstraints = false

            detailView.addSubview(spiner)
            spiner.centerYAnchor.constraint(equalTo: detailView.centerYAnchor).isActive = true
            spiner.leadingAnchor.constraint(equalTo: detailView.leadingAnchor).isActive = true

            detailView.addSubview(switcher)
            switcher.centerYAnchor.constraint(equalTo: detailView.centerYAnchor).isActive = true
            switcher.leadingAnchor.constraint(equalTo: spiner.trailingAnchor, constant: 8).isActive = true
            switcher.trailingAnchor.constraint(equalTo: detailView.trailingAnchor).isActive = true

            return detailView
        } else if hasSwitcher && !hasSpiner{
            let switcher = UISwitch()
            switcher.isOn = switcherIsOn
            switcher.translatesAutoresizingMaskIntoConstraints = false
            switcher.addTarget(self, action: #selector(self.togleSwitcher(_:)), for: .valueChanged)
            return switcher
        }
        return UIView()
    }

    @objc private func togleSwitcher(_ sender: UISwitch) {
        guard let switcherAction = switcherAction else {return}
        switcherAction(sender.isOn)
    }
}
