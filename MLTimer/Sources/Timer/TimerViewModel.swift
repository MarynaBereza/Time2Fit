//
//  TimerViewModel.swift
//  MLTimer
//
//  Created by Maryna Bereza on 16.01.2025.
//

import Foundation
import Combine
import QuartzCore
import AVFoundation
import UIKit

protocol TimerViewModelProtocol {
    var remainingTimePublisher: AnyPublisher<Time, Never> { get }
    var progressPublisher: AnyPublisher<Double, Never> { get }
    var roundPartPublisher: AnyPublisher<String, Never> { get }
    var currentNumberRoundPublisher: AnyPublisher<Int, Never> { get }
    var isContinuePublisher: AnyPublisher<Bool, Never> { get }
    var totalRoundPublisher: AnyPublisher<Int, Never> { get }
    var settingsViewModel: RoundSettingsViewModelProtocol { get }
    var stopPublisher: AnyPublisher<Bool, Never> { get }
    
    func playPause()
    func stop()
}

struct Time: Equatable, Codable, Hashable {
    var minutes: Int
    var seconds: Int
}

extension Time {
    init(seconds: Double) {
        let roundedSeconds = seconds.rounded(.up)
        let min = Int(roundedSeconds / 60)
        let sec = Int(roundedSeconds) % 60
        self.minutes = min
        self.seconds = sec
    }
}

enum RoundPart: String {
    case work = "WORK"
    case rest = "REST"
}

class TimerViewModel: TimerViewModelProtocol {

    // MARK: State
    private var isStoppedByUser = false
    private var preparingTime = 3.0
    private var cancellables = Set<AnyCancellable>()
    private lazy var _settingsViewModel = RoundSettingsViewModel(router: router)
    let displayLinkTimer = DisplayLinkTimer()
    let router: TimerScreenRouterProtocol
    var settingsViewModel: RoundSettingsViewModelProtocol { _settingsViewModel }

    @Published private(set) var roundPart: RoundPart = .rest
    @Published private(set) var currentNumberRound = 0
    @Published private(set) var workTime = 0.0
    @Published private(set) var restTime = 0.0
    @Published private(set) var totalRounds = 1
    @Published private(set) var stopTapped = false
 
    // MARK: Initialization
    
    init(router: TimerScreenRouterProtocol) {
        self.router = router
        setupSettings() 
        self.setupTimer()
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [unowned self] _ in
                if displayLinkTimer.state == .started {
                    displayLinkTimer.pause()
                }
            }
            .store(in: &cancellables)
    }
    
    var remainingTimePublisher: AnyPublisher<Time, Never> {
        displayLinkTimer.$remainingTime
            .combineLatest($workTime)
            .map { [unowned self] remainingTime, workTime in
                if remainingTime == preparingTime {
                    return Time(seconds: workTime)
                } else {
                    return Time(seconds: remainingTime)
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var workTimePublisher: AnyPublisher<Time, Never> {
        $workTime
            .map { Time(seconds: $0) }
            .eraseToAnyPublisher()
    }

    var restTimePublisher: AnyPublisher<Time, Never> {
        $restTime
            .map { Time(seconds: $0) }
            .eraseToAnyPublisher()
    }
    
    var progressPublisher: AnyPublisher<Double, Never> {
        displayLinkTimer.$progress
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    var roundPartPublisher: AnyPublisher<String, Never> {
        $roundPart
            .combineLatest($currentNumberRound)
            .map { part, round in
                if round == 0 {
                    ""
                } else {
                    part.rawValue
                }
            }
            .eraseToAnyPublisher()
    }
    
    var currentNumberRoundPublisher: AnyPublisher<Int, Never> {
        $currentNumberRound
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    var totalRoundPublisher: AnyPublisher<Int, Never> {
        $totalRounds
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    var isContinuePublisher: AnyPublisher<Bool, Never> {
        displayLinkTimer.$state
            .removeDuplicates()
            .map { $0 == .started }
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    var stopPublisher: AnyPublisher<Bool, Never> {
        $stopTapped
            .map { $0 }
            .eraseToAnyPublisher()
    }

    // MARK: Actions

    func playPause() {
        if displayLinkTimer.state == .started {
            displayLinkTimer.pause()
        } else {
            displayLinkTimer.start()
            _settingsViewModel.disable(true)
        }
    }
        
    func stop() {
        isStoppedByUser = true
        displayLinkTimer.setup(duration: preparingTime)
        _settingsViewModel.disable(false)
    }
    
    // MARK: Private methods
    
    private func setupSettings() {
        _settingsViewModel.$work
            .sink { [unowned self] value in
                let totalSeconds = value.minutes * 60 + value.seconds
                workTime = Double(totalSeconds)
                displayLinkTimer.setup(duration: preparingTime)
            }
            .store(in: &cancellables)
        _settingsViewModel.$rest
            .sink { [unowned self] value in
                let totalSeconds = value.minutes * 60 + value.seconds
                restTime = Double(totalSeconds)
            }
            .store(in: &cancellables)
        _settingsViewModel.$round
            .sink(receiveValue: { [unowned self] round in
                self.totalRounds = round
            })
            .store(in: &cancellables)
    }
    
    private func setupTimer() {
        displayLinkTimer.setup(duration: preparingTime)
        displayLinkTimer.$state
            .removeDuplicates()
            .filter { $0 == .stopped }
            .dropFirst()
            .delay(for: 0.01, scheduler: RunLoop.main)
            .sink { [unowned self] _ in
                if roundPart == .rest {
                    currentNumberRound += 1
                }
                roundPart = roundPart == .work ? .rest : .work
                let duration = roundPart == .work ? workTime : restTime
                if !isStoppedByUser {
                    displayLinkTimer.setup(duration: duration)
                }
                let isLastRound = currentNumberRound == totalRounds
                if isLastRound && roundPart == .rest {
                    stop()
                }
                if (isLastRound && roundPart == .rest) || isStoppedByUser {
                    roundPart = .rest
                    currentNumberRound = 0
                    stopTapped = true
                }
                guard !isStoppedByUser else {
                    isStoppedByUser = false
                    return
                }
                if !isLastRound || roundPart == .work {
                    displayLinkTimer.start()
                }
            }
            .store(in: &cancellables)
    }
}
