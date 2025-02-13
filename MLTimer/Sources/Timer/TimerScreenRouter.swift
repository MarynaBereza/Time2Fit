//
//  TimerScreenRounter.swift
//  MLTimer
//
//  Created by Maryna Bereza on 12.02.2025.
//

import Foundation
import UIKit
protocol TimerScreenRouterProtocol {
    func routeToTimePickerWith(value: Time, completion: @escaping (Time) -> Void)
    func routeToRoundPickerWith(value: Int, completion: @escaping (Int) -> Void)
}

class TimerScreenRouter: TimerScreenRouterProtocol {
    weak var vc: UIViewController?
    
    func routeToTimePickerWith(value: Time, completion: @escaping (Time) -> Void) {
        let timePickerVC = TimePickerBuilder.buildTimePickerWith(value: value, completion: completion)
        vc?.present(timePickerVC, animated: true)
    }
    
    func routeToRoundPickerWith(value: Int, completion: @escaping (Int) -> Void) {
        let roundPickerVC = RoundPickerBuilder.buildRoundPickerWith(value: value, completion: completion)
        vc?.present(roundPickerVC, animated: true)
    }
}
