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
    private let horizontalStackView = UIStackView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let deleteImageView = UIImageView()
    
    var isEditingMode: Bool = false {
        didSet {
            deleteImageView.isHidden = !isEditingMode
        }
    }

    override func setupHierarchy() {
        super.setupHierarchy()
        addSubview(stackView)
        stackView.addArrangedSubview(horizontalStackView)
        stackView.addArrangedSubview(timeLabel)
        horizontalStackView.addArrangedSubview(titleLabel)
        horizontalStackView.addArrangedSubview(deleteImageView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        deleteImageView.widthAnchor.constraint(equalTo: deleteImageView.heightAnchor, multiplier: 1).isActive = true
    }
    
    override func setupViews() {
        super.setupViews()
        
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 8
        
        deleteImageView.image = UIImage(systemName: "minus.circle")
        deleteImageView.tintColor = UIColor(resource: .stop)
        deleteImageView.contentMode = .center
        
        clipsToBounds = true
        layer.cornerRadius = 8
        backgroundColor = .systemFill
        
        stackView.axis = .vertical
        stackView.alignment = .fill
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
        updateUI(isSelected: info.isSelected)
    }
    
    func updateUI(isSelected: Bool) {
        if isSelected {
            layer.borderWidth = 1
            layer.borderColor = UIColor.secondaryLabel.cgColor
        } else {
            layer.borderWidth = 0
        }
    }
}
