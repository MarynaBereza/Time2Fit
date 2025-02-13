//
//  DisplayLinkTimer.swift
//  MLTimer
//
//  Created by Maryna Bereza on 17.01.2025.
//

import Foundation
import Combine
import QuartzCore

class DisplayLinkTimer {

    // MARK: State

    private var displayLink: CADisplayLink?
    private var startTime: Double?
    private(set) var duration: Double?
    @Published private(set) var progress: Double = 0
    @Published private(set) var remainingTime: Double = 0
    @Published private(set) var state: State = .stopped

    // MARK: Public methods

    func setup(duration: Double, progress: Double = 0) {
        self.duration = duration
        stopDisplayLink()
        state = .stopped
        self.remainingTime = duration
        self.progress = progress
    }

    func start() {
        guard state != .started else {
            assertionFailure("Started twice")
            return
        }
        startDisplayLink()
        state = .started
    }

    func pause() {
        guard state == .started else {
            assertionFailure("Paused twice")
            return
        }
        stopDisplayLink()
        state = .paused
    }

    func stop() {
        guard state != .stopped else { return }
        stopDisplayLink()
        progress = 0
        remainingTime = duration ?? 0
        state = .stopped
    }
    
    // MARK: Display link

    private func startDisplayLink() {
        stopDisplayLink()
        if let duration {
            startTime = CACurrentMediaTime().advanced(by: -progress * duration) // reset start time
        } else {
            startTime = CACurrentMediaTime() // reset start time
        }
        /// create displayLink and add it to the run-loop
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }

    @objc private func displayLinkDidFire(_ displayLink: CADisplayLink) {
        
        guard let duration, let startTime else { return }
        var elapsedTime = CACurrentMediaTime() - startTime
        
        if elapsedTime > duration {
            stopDisplayLink()
            elapsedTime = duration /// clamp the elapsed time to the animation length
        }
        
        remainingTime = duration - elapsedTime
        
        let progress = elapsedTime / duration
        self.progress = progress
        if progress == 1 {
            stop()
        }
    }

    /// invalidate display link if it's non-nil, then set to nil
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        startTime = nil
    }
}

extension DisplayLinkTimer {
    
    enum State: Hashable {
        case started
        case paused
        case stopped
    }
}
