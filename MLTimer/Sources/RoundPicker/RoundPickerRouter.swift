//
//  RoundPickerRouter.swift
//  MLTimer
//
//  Created by Maryna Bereza on 13.02.2025.
//

import Foundation

protocol RoundPickerRouterProtocol {
    func closeRoundsPickerWith(value: Int)
}

class RoundPickerRouter: RoundPickerRouterProtocol {
    var completionHandler: ((Int) -> Void)?
    
    func closeRoundsPickerWith(value: Int) {
        completionHandler?(value)
    }
}

