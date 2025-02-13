//
//  TimerScreenBuilder.swift
//  MLTimer
//
//  Created by Maryna Bereza on 12.02.2025.
//

import Foundation
import UIKit

class TimerScreenBuilder {
    static func buildTimerScreen() -> UIViewController {
        let r = TimerScreenRouter()
        let vm = TimerViewModel(router: r)
        let vc = TimerViewController(viewModel: vm)
        r.vc = vc
        return vc
    }
}
