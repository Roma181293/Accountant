//
//  ArchivingHistoryTableViewCell.swift
//  Accountant
//
//  Created by Roman Topchii on 07.07.2022.
//

import UIKit

class ArchivingHistoryTableViewCell: UITableViewCell {

    private var cellMainColor: UIColor = .systemGreen

    private let labelsAlpha: CGFloat = 0.15
    private let backGroundAlpha: CGFloat = 0.2

    private let mainView: UIView = {
        let mainView = UIView()

        mainView.layer.cornerRadius = 10
        mainView.translatesAutoresizingMaskIntoConstraints = false
        return mainView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func set(_ archivingHistory: ArchivingHistoryViewModel) {

        self.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3).isActive = true
        mainView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3).isActive = true
        mainView.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        mainView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true

        mainView.addSubview(dateLabel)
        dateLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
        dateLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 5).isActive = true

        mainView.addSubview(commentLabel)
        commentLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true

        commentLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10).isActive = true
        commentLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5).isActive = true
        commentLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -5).isActive = true

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")") // swiftlint:disable:this line_length

        dateLabel.text = formatter.string(from: archivingHistory.date)

        if archivingHistory.status == .success {
            cellMainColor = .systemGreen
            commentLabel.text = NSLocalizedString("Success", tableName: "ArchivinHistoryLocalizable", comment: "")
        } else {
            cellMainColor = .systemPink
            commentLabel.text = NSLocalizedString("Failure", tableName: "ArchivinHistoryLocalizable", comment: "") + ": " + (archivingHistory.comment ?? "")
        }
        mainView.backgroundColor = cellMainColor.withAlphaComponent(backGroundAlpha)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        mainView.backgroundColor = cellMainColor.withAlphaComponent(backGroundAlpha)
    }
}
