//
//  MITransactionEditorView.swift
//  Accountant
//
//  Created by Roman Topchii on 04.06.2022.
//

import UIKit

class MITransactionEditorView: UIView {

    weak var delegate: MITransactionEditorViewDelegate?

    let mainStackViewSpacing: CGFloat = 5

    let mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let mainView: UIView = {
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        return mainView
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Date",
                                       tableName: Constants.Localizable.mITransactionEditor,
                                       comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .automatic
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let debitStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2.0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.systemBlue.cgColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let creditStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2.0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.systemBlue.cgColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let debitTitleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let creditTitleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let debitLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("To:",
                                       tableName: Constants.Localizable.mITransactionEditor,
                                       comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let creditLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("From:",
                                       tableName: Constants.Localizable.mITransactionEditor,
                                       comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let debitAddButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let creditAddButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let debitTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let creditTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 200
        textField.placeholder = NSLocalizedString("Comment",
                                                  tableName: Constants.Localizable.mITransactionEditor,
                                                  comment: "")
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .systemBackground

        addConstraints()
        addTargets()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func changeDate(_ sender: UIDatePicker) {
        delegate?.changeDate(sender.date)
    }

    @objc private func debitAddButtonDidClick() {
        delegate?.debitAddButtonDidClick()
    }

    @objc private func creditAddButtonDidClick() {
        delegate?.creditAddButtonDidClick()
    }

    private func addTargets() {
        datePicker.addTarget(self,
                             action: #selector(self.changeDate(_:)),
                             for: .valueChanged)
        debitAddButton.addTarget(self,
                                 action: #selector(self.debitAddButtonDidClick),
                                 for: .touchUpInside)
        creditAddButton.addTarget(self,
                                  action: #selector(self.creditAddButtonDidClick),
                                  for: .touchUpInside)
    }

    private func addConstraints() { // swiftlint:disable:this function_body_length

        addSubview(mainScrollView)
        mainScrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true

        mainScrollView.addSubview(mainView)
        mainView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: mainScrollView.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor).isActive = true
        mainView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor).isActive = true
        mainView.heightAnchor.constraint(equalTo: mainScrollView.heightAnchor).isActive = true

        mainView.addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 40).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 18).isActive = true

        mainView.addSubview(datePicker)
        datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8).isActive = true

        mainView.addSubview(commentTextField)
        commentTextField.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -20).isActive = true
        commentTextField.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 8).isActive = true
        commentTextField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -8).isActive = true
        commentTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true

        mainView.addSubview(mainStackView)
        mainStackView.spacing = mainStackViewSpacing
        mainStackView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 40).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 8).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -8).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: commentTextField.topAnchor, constant: -20).isActive = true

        mainStackView.addArrangedSubview(creditStackView)
        creditStackView.addArrangedSubview(creditTitleView)

        creditTitleView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        creditTitleView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        creditTitleView.addSubview(creditLabel)
        creditLabel.leadingAnchor.constraint(equalTo: creditTitleView.leadingAnchor, constant: 10).isActive = true
        creditLabel.centerYAnchor.constraint(equalTo: creditTitleView.centerYAnchor).isActive = true

        creditTitleView.addSubview(creditAddButton)
        creditAddButton.trailingAnchor.constraint(equalTo: creditTitleView.trailingAnchor).isActive = true
        creditAddButton.centerYAnchor.constraint(equalTo: creditTitleView.centerYAnchor).isActive = true
        creditAddButton.widthAnchor.constraint(equalTo: creditTitleView.heightAnchor).isActive = true
        creditAddButton.heightAnchor.constraint(equalTo: creditTitleView.heightAnchor).isActive = true

        creditStackView.addArrangedSubview(creditTableView)
        creditTableView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        creditTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5,
                                                constant: -30 - mainStackViewSpacing).isActive = true

        mainStackView.addArrangedSubview(debitStackView)
        debitStackView.addArrangedSubview(debitTitleView)

        debitTitleView.widthAnchor.constraint(equalToConstant: mainStackView.frame.width).isActive = true
        debitTitleView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        debitTitleView.addSubview(debitLabel)
        debitLabel.leadingAnchor.constraint(equalTo: debitTitleView.leadingAnchor, constant: 10).isActive = true
        debitLabel.centerYAnchor.constraint(equalTo: debitTitleView.centerYAnchor).isActive = true

        debitTitleView.addSubview(debitAddButton)
        debitAddButton.trailingAnchor.constraint(equalTo: debitTitleView.trailingAnchor).isActive = true
        debitAddButton.centerYAnchor.constraint(equalTo: debitTitleView.centerYAnchor).isActive = true
        debitAddButton.widthAnchor.constraint(equalTo: debitTitleView.heightAnchor).isActive = true
        debitAddButton.heightAnchor.constraint(equalTo: debitTitleView.heightAnchor).isActive = true

        debitStackView.addArrangedSubview(debitTableView)
        debitTableView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        debitTableView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5,
                                               constant: -30 - mainStackViewSpacing).isActive = true
    }

    func scrollContent(contentInset: UIEdgeInsets) {
        mainScrollView.contentInset = contentInset
        mainScrollView.scrollIndicatorInsets = mainScrollView.contentInset
    }
}
