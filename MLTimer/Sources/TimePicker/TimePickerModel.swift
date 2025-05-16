//
//  TimePickerModel.swift
//  MLTimer
//
//  Created by Maryna Bereza on 12.02.2025.
//

import Foundation
import UIKit

protocol TimePickerModelProtocol {
        
    var initialSelectedIndices: [Int] { get }
    var rows: [[String]] { get }
    
    func confirm()
    func updateSelectedRow(_ row: Int, inComponent component: Int)
    func checkSelection(row: Int, comp: Int) -> (row: Int, component: Int)
}

class TimePickerModel: TimePickerModelProtocol {
    
    enum Component: Int {
        case min = 0
        case sec = 1
    }
    
    private let router: TimePickerRouterProtocol
    
    private var value: Time
    
    private(set) lazy var initialSelectedIndices: [Int] = [
        minutes.firstIndex(of: value.minutes) ?? 0,
        seconds.firstIndex(of: value.seconds) ?? 0
    ]
    
    private(set) lazy var rows: [[String]] = [minutes.map { "\($0)" }, seconds.map { "\($0)" }]
    
    init(router: TimePickerRouterProtocol, value: Time) {
        self.router = router
        self.value = value
    }
    
    func confirm() {
        router.closeTimePickerWith(value: value)
    }
    
    func updateSelectedRow(_ row: Int, inComponent component: Int) {
        if component == 0 {
            value.minutes = minutes[row]
            initialSelectedIndices[0] = row
        } else {
            value.seconds = seconds[row]
            initialSelectedIndices[1] = row
        }
    }
    
    func checkSelection(row: Int, comp: Int) -> (row: Int, component: Int) {
        if (initialSelectedIndices[Component.min.rawValue] == 0 && initialSelectedIndices[Component.sec.rawValue] == 0) ||
            initialSelectedIndices[Component.sec.rawValue] == 0 && initialSelectedIndices[Component.min.rawValue] == 0 {
            
            updateSelectedRow(1, inComponent: 1)
            return (row: 1, component: 1)
        } else {
            return (row,comp)
        }
    }
}

extension TimePickerModel {
    var minutes: [Int] { (0..<30).map { $0 } }
    var seconds: [Int] { Array(stride(from: 0, through: 55, by: 5))}
}
