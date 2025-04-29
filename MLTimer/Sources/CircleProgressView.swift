//
//  CircleProgressView.swift
//  MLTimer
//
//  Created by Maryna Bereza on 31.01.2025.
//

import Foundation
import UIKit

final class CircleProgressView: UIView {
    
    override class var layerClass: AnyClass { CAShapeLayer.self }
    
    // MARK: - State
    
    private var shapeLayer: CAShapeLayer { layer as! CAShapeLayer }
    private var circleLayer = CAShapeLayer()
    
    var progress: Double = 0 {
        didSet {
            guard progress != oldValue else { return }
            CATransaction.withoutAnimations { [weak self, progress] in
                self?.shapeLayer.strokeEnd = progress
            }
        }
    }
    
    var progressColor = UIColor(resource: .accent).cgColor
    // MARK: - Path

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }

    private func updatePath() {
        let path = UIBezierPath(arcCenter: .init(x: bounds.width / 2, y: bounds.height / 2), radius: bounds.width / 2 - 10, startAngle: .pi / -2, endAngle: 3 / 2 * .pi, clockwise: true)
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 20
        shapeLayer.lineCap = .round

        shapeLayer.strokeColor = progressColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.cornerRadius = bounds.width / 2
        shapeLayer.masksToBounds = true
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = progress
        
        circleLayer.path = path.cgPath
        circleLayer.lineWidth = 20
        circleLayer.strokeEnd = 1
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.secondarySystemFill.cgColor
        shapeLayer.addSublayer(circleLayer)
    }
}

extension CATransaction {

    static func withoutAnimations(_ action: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        action()
        CATransaction.commit()
    }
}

