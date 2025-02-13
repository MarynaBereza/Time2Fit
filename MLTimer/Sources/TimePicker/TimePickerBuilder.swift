//
//  TimePickerBuilder.swift
//  MLTimer
//
//  Created by Maryna Bereza on 12.02.2025.
//

import Foundation
import UIKit

class TimePickerBuilder {
    static func buildTimePickerWith(value: Time, completion: @escaping (Time) -> Void) -> UIViewController {
        let r = TimePickerRouter()
        let viewModel = TimePickerModel(router: r, value: value)
        let pickerVC = TimePickerController(viewModel: viewModel)
        if let sheet = pickerVC.sheetPresentationController{
            sheet.detents = [.custom(resolver: { context in
                250
            })]
            sheet.prefersGrabberVisible = true
        }
        r.completionHandler = completion
        return pickerVC
    }
}
