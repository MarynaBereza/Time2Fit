//
//  TimePickerRouter.swift
//  MLTimer
//
//  Created by Maryna Bereza on 12.02.2025.
//

import Foundation
import UIKit

protocol TimePickerRouterProtocol {
    func closeTimePickerWith(value: Time)
    
}

class TimePickerRouter: TimePickerRouterProtocol {

    var completionHandler: ((Time) -> Void)?
    
    func closeTimePickerWith(value: Time) {
        completionHandler?(value)
    }
}
