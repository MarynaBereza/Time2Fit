//
//  RoundSettingsViewModel.swift
//  MLTimer
//
//  Created by Maryna Bereza on 12.02.2025.
//

import Foundation
import Combine
protocol RoundSettingsViewModelProtocol {
    func showWorkTimePicker()
    func showRestTimePicker()
    func showRoundPicker()
    
    var workTimePublisher: AnyPublisher<String, Never> { get }
    var restTimePublisher: AnyPublisher<String, Never> { get }
    var roundPublisher: AnyPublisher<String, Never> { get }
    
    var workTimerPublisher: AnyPublisher<Time, Never> { get }
    var roundDataPublisher: AnyPublisher<Int, Never> { get }
}


class RoundSettingsViewModel: RoundSettingsViewModelProtocol {
    
    let router: TimerScreenRouterProtocol
    let displayLinkTimer = DisplayLinkTimer()
    
    @Published private(set) var work: Time
    @Published private(set) var rest: Time
    @Published private(set) var round: Int
    
    init(router: TimerScreenRouterProtocol) {
        self.router = router
        self.work = UserDefaults.work
        self.rest = UserDefaults.rest
        self.round = UserDefaults.round
    }
    
    var workTimePublisher: AnyPublisher<String, Never> {
        $work
            .compactMap { $0 }
            .map({ [unowned self] value in
                self.convert(minutes: value.minutes, seconds: value.seconds)
            })
            .eraseToAnyPublisher()
    }
    
    var restTimePublisher: AnyPublisher<String, Never> {
        $rest
            .compactMap { $0 }
            .map({ [unowned self] value in
                self.convert(minutes: value.minutes, seconds: value.seconds)
            })
            .eraseToAnyPublisher()
    }
    
    var workTimerPublisher: AnyPublisher<Time, Never> {
        $work
            .compactMap{ $0 }
            .eraseToAnyPublisher()
    }
    
    var roundPublisher: AnyPublisher<String, Never> {
        $round
            .compactMap{ "\($0)" }
            .eraseToAnyPublisher()
    }

    
    var roundDataPublisher: AnyPublisher<Int, Never> {
        $round
            .compactMap{ $0 }
            .eraseToAnyPublisher()
    }

    func convert(minutes: Int, seconds: Int) -> String {
        var formattedMins: String = "\(minutes)"
        var formattedSeconds: String = "\(seconds)"
        if minutes <= 9 {
            formattedMins = "0" + formattedMins
        }

        if seconds <= 9 {
            formattedSeconds = "0" + formattedSeconds
        }
        return "\(formattedMins) : \(formattedSeconds)"
    }
    
    func showWorkTimePicker() {
        router.routeToTimePickerWith(value: work) { value in
            self.work = value
            UserDefaults.work = value
        }
    }

    func showRestTimePicker() {
        router.routeToTimePickerWith(value: rest) { value in
            self.rest = value
            UserDefaults.rest = value
        }
    }
    
    func showRoundPicker(){
        router.routeToRoundPickerWith(value: round) { value in
            self.round = value
            UserDefaults.round = value
        }
    }
}


extension UserDefaults {
    
    static var work: Time {
        get {
            guard let data = standard.data(forKey: "kWorkTime") else {
                return .init(minutes: 0, seconds: 0)
            }
            let value: Time
            do {
                let decoder = JSONDecoder()
                value = try decoder.decode(Time.self, from: data)
            } catch {
                value = .init(minutes: 0, seconds: 0)
            }
            return value
        }
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                standard.set(data, forKey: "kWorkTime")
            } catch {
                print("Work did not save to UserDefaults. Error: \(error)")
            }
        }
    }
    
    static var rest: Time {
        get {
            guard let data = standard.data(forKey: "kRestTime") else {
                return .init(minutes: 0, seconds: 0)
            }
            let value: Time
            do {
                let decoder = JSONDecoder()
                value = try decoder.decode(Time.self, from: data)
            } catch {
                value = .init(minutes: 0, seconds: 0)
            }
            return value
        }
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                standard.set(data, forKey: "kRestTime")
            } catch {
                print("Rest did not save to UserDefaults. Error: \(error)")
            }
        }
    }
    
    static var round: Int {
        get {
            guard let data = standard.data(forKey: "kRoundCount") else {
                return 1
            }
            let value: Int
            do {
                let decoder = JSONDecoder()
                value = try decoder.decode(Int.self, from: data)
            } catch {
                value = 1
            }
            return value
        }
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                standard.set(data, forKey: "kRoundCount")
            } catch {
                print("Rest did not save to UserDefaults. Error: \(error)")
            }
        }
    }
}


