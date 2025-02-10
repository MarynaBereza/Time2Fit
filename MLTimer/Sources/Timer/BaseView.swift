//
//  BaseView.swift
//  MLTimer
//
//  Created by Maryna Bereza on 03.02.2025.
//

import Foundation
import UIKit

class BaseView: UIView {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupLayout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHierarchy() {}
    func setupLayout() {}
    func setupViews() {}
}
