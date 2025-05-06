//
//  SaveSetCell.swift
//  MLTimer
//
//  Created by Maryna Bereza on 05.05.2025.
//

import Foundation
import UIKit

class SetSettingsCell: BaseView {
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    
    override func setupHierarchy() {
        super.setupHierarchy()
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(timeLabel)
    }
    
    override func setupLayout() {
        super.setupLayout()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
    }
    
    override func setupViews() {
        super.setupViews()

        layer.cornerRadius = 8
        backgroundColor = .systemFill
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2

        titleLabel.textColor = .label
        timeLabel.textColor = .secondaryLabel
        titleLabel.font = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith:  UITraitCollection(legibilityWeight: .bold))
        timeLabel.font = UIFont.preferredFont(forTextStyle: .caption1, compatibleWith:  UITraitCollection(legibilityWeight: .bold))
    }
    
    func updateData(info: InfoSetData) {
        titleLabel.text = info.title
        
        let work = "\(info.work.minutes.formattedTime):\(info.work.seconds.formattedTime)"
        let rest = "\(info.rest.minutes.formattedTime):\(info.rest.seconds.formattedTime)"
        let round = info.round
        timeLabel.text = "\(work) | \(rest) | \(round)"
    }
}
