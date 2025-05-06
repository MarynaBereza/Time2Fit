//
//  PickerSouceView.swift
//  MLTimer
//
//  Created by Maryna Bereza on 03.02.2025.
//

import Foundation
import UIKit

class PickerSouceView: BaseView {

    private let stackView = UIStackView()
    private let timeStackView = UIStackView()
    private let titleLabel = UILabel()
    private let timeImageView = UIImageView()
    private let timeLabel = UILabel()
    var isEnabled = true {
        didSet {
            updateUI()
        }
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var value: String? {
        get { timeLabel.text }
        set { timeLabel.text = newValue }
    }
    
    var image: UIImage? {
        get { timeImageView.image}
        set { timeImageView.image = newValue }
    }

    var color: UIColor? {
        get { timeImageView.tintColor}
        set { timeImageView.tintColor = newValue }
    }
    
    var onDidTap: (() -> Void)?
    
    override func setupHierarchy() {
        super.setupHierarchy()
        addSubview(stackView)
        timeStackView.addArrangedSubview(timeImageView)
        timeStackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(timeStackView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6).isActive = true
        
        timeImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        timeImageView.heightAnchor.constraint(equalTo: timeImageView.widthAnchor).isActive = true
    }
    
    override func setupViews() {
        super.setupViews()
        let actionTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(actionTap)
        updateUI()
        layer.cornerRadius = 5
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        
        timeStackView.alignment = .fill
        timeStackView.axis = .horizontal
        timeStackView.spacing = 5
        
        titleLabel.textColor = .secondaryLabel
        timeLabel.textColor = .label
        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1, compatibleWith:  UITraitCollection(legibilityWeight: .regular))
        timeLabel.font = UIFont.preferredFont(forTextStyle: .headline, compatibleWith:  UITraitCollection(legibilityWeight: .regular))
    }
    
    private func updateUI() {
        backgroundColor = isEnabled ? .systemFill : .systemGray5
        titleLabel.textColor = isEnabled ? .secondaryLabel : .tertiaryLabel
        timeLabel.textColor = isEnabled ? .label : .tertiaryLabel
    }
    
    @objc private func handleTap() {
        
        guard isEnabled else {
            return
        }
        onDidTap?()
    }
}
