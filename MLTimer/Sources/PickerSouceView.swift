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
    private let titleLabel = UILabel()
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
    
    var onDidTap: (() -> Void)?
    
    override func setupHierarchy() {
        super.setupHierarchy()
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(timeLabel)
    }
    
    override func setupLayout() {
        super.setupLayout()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
    }
    
    override func setupViews() {
        super.setupViews()
        let actionTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(actionTap)
        updateUI()
        layer.cornerRadius = 5
        
        stackView.axis = .vertical
        stackView.alignment = .center
        
        titleLabel.textColor = .label
        timeLabel.textColor = .label
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        timeLabel.font = UIFont.preferredFont(forTextStyle: .title2)
    }
    
    private func updateUI() {
        backgroundColor = isEnabled ? UIColor(red: 0.471, green: 0.627, blue: 0.431, alpha: 0.5) : .tertiarySystemFill
        
        titleLabel.textColor = isEnabled ? .label.withAlphaComponent(0.8) : .label.withAlphaComponent(0.4)
        timeLabel.textColor = isEnabled ? .label.withAlphaComponent(0.8) : .label.withAlphaComponent(0.4)
    }
    
    @objc private func handleTap() {
        
        guard isEnabled else {
            return
        }
        onDidTap?()
    }
}
