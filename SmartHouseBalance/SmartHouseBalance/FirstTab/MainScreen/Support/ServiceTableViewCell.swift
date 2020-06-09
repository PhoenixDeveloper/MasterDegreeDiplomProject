//
//  ServiceTableViewCell.swift
//  SmartHouseBalance
//
//  Created by Михаил Беленко on 10.05.2020.
//  Copyright © 2020 Михаил Беленко. All rights reserved.
//

import UIKit
import DTModelStorage
import SnapKit

class ServiceTableViewCell: UITableViewCell, ModelTransfer {

    private lazy var nameOrganizationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    private lazy var typeServiceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()

    private lazy var datePaymentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()

    private let bottomContainer = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with model: ServiceModel) {
        nameOrganizationLabel.text = model.nameOrganization
        typeServiceLabel.text = model.typeService?.nameType
        priceLabel.attributedText = setRedPartText(redText: "\(model.price) руб.", blackText: (model.metersData.value != nil ? " (Показания счетчиков: \(model.metersData.value!))" : ""))
        datePaymentLabel.text = dateFormatter(date: model.datePayment)
    }
    
    private func setRedPartText(redText: String, blackText: String) -> NSMutableAttributedString {
        let firstAttributedString = NSAttributedString(
            string: redText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        )
        let secondAttributedString = NSAttributedString(string: blackText)

        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(firstAttributedString)
        attributedString.append(secondAttributedString)
        
        return attributedString
    }

    private func dateFormatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date)
    }

    private func addSubviews() {
        bottomContainer.addSubview(priceLabel)
        bottomContainer.addSubview(datePaymentLabel)

        contentView.addSubview(nameOrganizationLabel)
        contentView.addSubview(typeServiceLabel)
        contentView.addSubview(bottomContainer)

        setupConstraints()
    }

    private func setupConstraints() {
        nameOrganizationLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        typeServiceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameOrganizationLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(typeServiceLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }

        datePaymentLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(priceLabel.snp.trailing).offset(8)
            make.top.trailing.bottom.equalToSuperview()
        }
    }
}
