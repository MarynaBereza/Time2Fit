//
//  RoundSettingsViewModel.swift
//  MLTimer
//
//  Created by Maryna Bereza on 12.02.2025.
//

import Foundation
import Combine

struct InfoSetData: Hashable, Equatable, Codable {
    let title: String
    let work: Time
    let rest: Time
    let round: Int
    var isSelected: Bool
}

protocol RoundSettingsViewModelProtocol {
    func showWorkTimePicker()
    func showRestTimePicker()
    func showRoundPicker()
    func updateCurrentSet(to set: InfoSetData?)
    func removeWorkoutSet(index: Int)
    func saveSet(withTitle title : String)
    
    var workTimePublisher: AnyPublisher<String, Never> { get }
    var restTimePublisher: AnyPublisher<String, Never> { get }
    var roundPublisher: AnyPublisher<String, Never> { get }
    
    var workTimerPublisher: AnyPublisher<Time, Never> { get }
    var roundDataPublisher: AnyPublisher<Int, Never> { get }
    
    var isEnabledPublisher: AnyPublisher<Bool, Never> { get }
    var savedSetsPublisher: AnyPublisher<[InfoSetData], Never> { get }
    
    var work: Time { get }
    var rest: Time { get }
    var round: Int { get }
}


class RoundSettingsViewModel: RoundSettingsViewModelProtocol {

    let router: TimerScreenRouterProtocol
    let displayLinkTimer = DisplayLinkTimer()
    
    @Published private(set) var work: Time
    @Published private(set) var rest: Time
    @Published private(set) var round: Int
    @Published private(set) var isEnabled: Bool = true
    @Published private(set) var savedSets = UserDefaults.workoutSets {
        didSet {
            UserDefaults.workoutSets = savedSets
        }
    }
    
    init(router: TimerScreenRouterProtocol) {
        self.router = router
        self.work = UserDefaults.work
        self.rest = UserDefaults.rest
        self.round = UserDefaults.round
    }
    
    var workTimePublisher: AnyPublisher<String, Never> {
        $work
            .compactMap { $0 }
            .map({ value in
                "\(value.minutes.formattedTime):\(value.seconds.formattedTime)"
            })
            .eraseToAnyPublisher()
    }
    
    var restTimePublisher: AnyPublisher<String, Never> {
        $rest
            .compactMap { $0 }
            .map({ value in
                "\(value.minutes.formattedTime):\(value.seconds.formattedTime)"
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
    
    var isEnabledPublisher: AnyPublisher<Bool, Never> {
        $isEnabled
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var savedSetsPublisher: AnyPublisher<[InfoSetData], Never> {
        $savedSets
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func showWorkTimePicker() {
        router.routeToTimePickerWith(value: work) { [weak self] value in
            guard let self, self.work != value else { return }
            self.work = value
            UserDefaults.work = value
            self.updateCurrentSet(to: nil)
        }
    }

    func showRestTimePicker() {
        router.routeToTimePickerWith(value: rest) { [weak self] value in
            guard let self, self.rest != value else { return }
            self.rest = value
            UserDefaults.rest = value
            self.updateCurrentSet(to: nil)
        }
    }
    
    func showRoundPicker(){
        router.routeToRoundPickerWith(value: round) { [weak self] value in
            guard let self, self.round != value else { return }
            self.round = value
            UserDefaults.round = value
            self.updateCurrentSet(to: nil)
        }
    }
    
    func updateCurrentSet(to workoutSet: InfoSetData?) {
        guard let workoutSet else {
            savedSets = savedSets.map({ set in
                var updatedSet =  set
                updatedSet.isSelected = false
                return updatedSet
            })
            return
        }
        work = workoutSet.work
        rest = workoutSet.rest
        round = workoutSet.round
        
        savedSets = savedSets.map({ set in
            var updatedSet =  set
            updatedSet.isSelected = workoutSet == set
            return updatedSet
        })
    }

    func disable(_ disable: Bool) {
        isEnabled = !disable
    }
    
    func removeWorkoutSet(index: Int) {
        savedSets.remove(at: index)
    }
    
    func saveSet(withTitle title: String) {
        var title = title
        if title.isEmpty {
            title = "MySet"
        }
        if savedSets.contains(where: { $0.title == title }) {
            let filteredSets = savedSets.filter { set in
                set.title.hasPrefix("\(title) ")
            }
            
            let ints = filteredSets.compactMap { set in
                var suffix = set.title
                suffix.trimPrefix("\(title) ")
                let int = Int(suffix)
                return int
            }
            let int = ints.max() ?? 0
            title = "\(title) \(int + 1)"
        }
        let newSet = InfoSetData(title: title, work: work, rest: rest, round: round, isSelected: false)
        savedSets.insert(newSet, at: 0)
    }
}

extension UserDefaults {
    
    static var work: Time {
        get {
            guard let data = standard.data(forKey: "kWorkTime") else {
                return .init(minutes: 0, seconds: 5)
            }
            let value: Time
            do {
                let decoder = JSONDecoder()
                value = try decoder.decode(Time.self, from: data)
            } catch {
                value = .init(minutes: 0, seconds: 5)
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
                return .init(minutes: 0, seconds: 5)
            }
            let value: Time
            do {
                let decoder = JSONDecoder()
                value = try decoder.decode(Time.self, from: data)
            } catch {
                value = .init(minutes: 0, seconds: 5)
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
    
    static var workoutSets: [InfoSetData] {
        get {
            guard let data = standard.data(forKey: "kSets") else {
                return []
            }
            let value: [InfoSetData]
            do {
                let decoder = JSONDecoder()
                value = try decoder.decode([InfoSetData].self, from: data)
            } catch {
                value = []
            }
            return value
        }
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                standard.set(data, forKey: "kSets")
            } catch {
                print("Work did not save to UserDefaults. Error: \(error)")
            }
        }
    }
}


