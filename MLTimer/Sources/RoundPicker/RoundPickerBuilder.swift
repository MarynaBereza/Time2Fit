//
//  RoundPickerBuilder.swift
//  MLTimer
//
//  Created by Maryna Bereza on 13.02.2025.
//

import Foundation
import UIKit

class RoundPickerBuilder {
    
    static func buildRoundPickerWith(value: Int, completion: @escaping (Int) -> Void) -> UIViewController {
        let r = RoundPickerRouter()
        let viewModel = RoundPickerModel(router: r, value: value)
        let pickerVC = RoundPickerController(viewModel: viewModel)
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
