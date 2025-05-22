//
//  RoundPickerModel.swift
//  MLTimer
//
//  Created by Maryna Bereza on 13.02.2025.
//

import Foundation

protocol RoundPickerModelProtocol {
    var rounds: [Int] { get }
    var value: Int { get }
    func confirm()
    func updateSelectedRow(row: Int)
}

class RoundPickerModel: RoundPickerModelProtocol {
    let router: RoundPickerRouterProtocol
    var value: Int
    
    init(router: RoundPickerRouterProtocol, value: Int) {
        self.router = router
        self.value = value
    }
    
    func confirm() {
        router.closeRoundsPickerWith(value: value)
    }
    
    func updateSelectedRow(row: Int) {
        value = rounds[row]
    }
}

extension RoundPickerModel {
    var rounds: [Int] { (1...50).map { $0 } }
}

