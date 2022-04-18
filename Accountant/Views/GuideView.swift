//
//  GuideView.swift
//  Accountant
//
//  Created by Roman Topchii on 31.10.2021.
//

import UIKit

class GuideView: UIView {

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let guideItemStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mainStackView)
        mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        mainStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true

        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(bodyLabel)
        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(guideItemStackView)
    }

    func setGuide(_ guide: Guide) {
        bodyLabel.text = guide.body

        if let imageName = guide.image, let image = UIImage(named: imageName) {
            imageView.image = image
            imageView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
            imageView.heightAnchor.constraint(equalTo: mainStackView.widthAnchor,
                               multiplier: imageView.image!.size.height/imageView.image!.size.width).isActive = true
        }
        titleLabel.text = guide.title

        // MARK: - Description Stack View
        guide.items.forEach({item in
            let itemStackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.alignment = .fill
                stackView.distribution = .fill
                stackView.spacing = 8.0
                stackView.backgroundColor = UIColor(white: 1, alpha: 0)
                stackView.translatesAutoresizingMaskIntoConstraints = false
                return stackView
            }()

            let coloredView: UIView = {
                let backGroundView = UIView()
                backGroundView.backgroundColor = item.backgroungColor
                backGroundView.translatesAutoresizingMaskIntoConstraints = false
                return backGroundView
            }()

            let imageView: UIImageView = {
                let imageView = UIImageView()
                if let imageName = item.image {
                    imageView.image = UIImage(systemName: imageName)
                }
                if let tintColor = item.tintColor {
                    imageView.tintColor = tintColor
                } else {
                    imageView.tintColor = .white
                }
                imageView.translatesAutoresizingMaskIntoConstraints = false
                return imageView
            }()

            let emojiLabel: UILabel = {
                let label = UILabel()
                label.textAlignment = .left
                label.text = item.emoji
                label.textColor = .label
                label.font = UIFont.systemFont(ofSize: 16.0)
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()

            let descriptionLabel: UILabel = {
                let label = UILabel()
                label.textAlignment = .left
                label.text = item.text
                label.textColor = .label
                label.font = UIFont.systemFont(ofSize: 16.0)
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()

            coloredView.widthAnchor.constraint(equalToConstant: 60).isActive = true
            coloredView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true

            if item.image != nil && item.emoji == nil {
                coloredView.addSubview(imageView)
                imageView.centerYAnchor.constraint(equalTo: coloredView.centerYAnchor).isActive = true
                imageView.centerXAnchor.constraint(equalTo: coloredView.centerXAnchor).isActive = true
            } else if item.image == nil && item.emoji != nil {
                coloredView.addSubview(emojiLabel)
                emojiLabel.centerYAnchor.constraint(equalTo: coloredView.centerYAnchor).isActive = true
                emojiLabel.centerXAnchor.constraint(equalTo: coloredView.centerXAnchor).isActive = true
            }
            descriptionLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 360).isActive = true

            itemStackView.addArrangedSubview(coloredView)
            itemStackView.addArrangedSubview(descriptionLabel)

            guideItemStackView.addArrangedSubview(itemStackView)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
