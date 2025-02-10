//
//  TimerViewModel.swift
//  MLTimer
//
//  Created by Maryna Bereza on 16.01.2025.
//

import Foundation
import Combine
import QuartzCore

protocol TimerViewModelProtocol {

    var remainingTimePublisher: AnyPublisher<Time, Never> { get }
    var roundPartPublisher: AnyPublisher<String, Never> { get }
    var currentNumberRoundPublisher: AnyPublisher<String, Never> { get }
    var totalRoundPublisher: AnyPublisher<String, Never> { get }
    var workTimePublisher: AnyPublisher<Time, Never> { get }
    var restTimePublisher: AnyPublisher<Time, Never> { get }
    var isContinuePublisher: AnyPublisher<Bool, Never> { get }
    var progressPublisher: AnyPublisher<Double, Never> { get }
    
    func playPause()
    func stop()
}

struct Time: Equatable {
    let minutes: Int
    let seconds: Int
    
    init(seconds: Double) {
        let roundedSeconds = seconds.rounded(.up)
        let min = Int(roundedSeconds / 60)
        let sec = Int(roundedSeconds) - min * 60
        self.minutes = min
        self.seconds = sec
    }
}

class TimerViewModel: TimerViewModelProtocol {

    enum RoundPart: String {
        case work = "Work"
        case rest = "Rest"
    }
    
    // MARK: State
    private var isStoppedByUser = false
    private var cancellables = Set<AnyCancellable>()
    let displayLinkTimer = DisplayLinkTimer()
    
    @Published private(set) var roundPart: RoundPart = .work
    @Published private(set) var currentNumberRound = 1
    @Published private(set) var workTime = 6.0
    @Published private(set) var restTime = 3.0
    @Published private(set) var totalRounds = 2
    
    var remainingTimePublisher: AnyPublisher<Time, Never> {
        displayLinkTimer.$remainingTime
            .filter { $0 != 0 }
            .map {
                print("TIME = \($0)")
                return Time(seconds: $0)
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
            .map { "\($0.rawValue)" }
            .eraseToAnyPublisher()
    }
    
    var currentNumberRoundPublisher: AnyPublisher<String, Never> {
        $currentNumberRound
            .map { "\($0)" }
            .eraseToAnyPublisher()
    }
    
    var totalRoundPublisher: AnyPublisher<String, Never> {
        $totalRounds
            .map { "\($0)" }
            .eraseToAnyPublisher()
    }
    
    var isContinuePublisher: AnyPublisher<Bool, Never> {
        displayLinkTimer.$state
            .removeDuplicates()
            .map { $0 == .started }
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
        
    // MARK: Initialization
    
    init() {
        setupTimer()
    }
    
    // MARK: Actions

    func playPause() {
        if displayLinkTimer.state == .started {
            displayLinkTimer.pause()
        } else {
            displayLinkTimer.start()
        }
    }
        
    func stop() {
        isStoppedByUser = true
        displayLinkTimer.setup(duration: workTime)
    }
    
    // MARK: Private methods
    
    private func setupTimer() {
        displayLinkTimer.setup(duration: workTime)
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
                    roundPart = .work
                    currentNumberRound = 1
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
