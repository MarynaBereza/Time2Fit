//
//  TimerViewController.swift
//  MLTimer
//
//  Created by Maryna Bereza on 16.01.2025.
//

import UIKit
import Combine
import AVFoundation

class TimerViewController: UIViewController {
    
    let viewModel: TimerViewModelProtocol
    let mainStackView = UIStackView()
    lazy var roundSettingsVC = RoundSettingsViewController(viewModel: viewModel.settingsViewModel)
    let roundPartLable = UILabel()
    let countRoundStackView = UIStackView()
    let currentRoundLable = UILabel()
    let deviderLable = UILabel()
    let totalRoundsLable = UILabel()
    let timeStackView = UIStackView()
    let minutesLabel = UILabel()
    let colonLabel = UILabel()
    let secondsLabel = UILabel()
    let progressView = CircleProgressView()
    let spacerViewBeforeProgress = UIView()
    let spacerViewAfterProgress = UIView()
    let buttonsStackView = UIStackView()
    let startPauseButton = UIButton()
    let stopButton = UIButton()
    var cancellables = Set<AnyCancellable>()
    var soundPlayer: AVAudioPlayer?
    
    init(viewModel: TimerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupView()
        bindViewModel()
        stopButton.isEnabled = false
    }
    
    func playSound(name: String) {
        DispatchQueue.global().async {
            self.soundPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "mp3")!))
            self.soundPlayer?.play()
        }
    }
    
    func bindViewModel() {
        
        Publishers.CombineLatest(viewModel.remainingTimePublisher,
                                 viewModel.roundPartPublisher)
        .sink { [unowned self] time, part in
            if time.seconds == 0 && time.minutes == 0 {
                if part == RoundPart.work.rawValue {
                    playSound(name: "rest")
                } else if part == RoundPart.rest.rawValue || part.isEmpty {
                    playSound(name: "bell")
                }
            } else {
                if time.seconds == 3 && time.minutes == 0 {
                    playSound(name: "tick3")
                }
                minutesLabel.text = time.minutes.formattedTime
                secondsLabel.text = time.seconds.formattedTime
            }
        }
        .store(in: &cancellables)
  
        viewModel.settingsViewModel.workTimerPublisher
            .sink { [unowned self] time in
                minutesLabel.text = time.minutes.formattedTime
                secondsLabel.text = time.seconds.formattedTime
            }
            .store(in: &cancellables)
        
        viewModel.progressPublisher
            .sink { [unowned self] progress in
                progressView.progress = progress
            }
            .store(in: &cancellables)
        
        viewModel.roundPartPublisher
            .sink { [unowned self] partRound in
                roundPartLable.text = partRound
                progressView.progressColor = partRound == RoundPart.work.rawValue ?
                UIColor(resource: .accent).cgColor : UIColor(resource: .stop).cgColor
            }
            .store(in: &cancellables)
        
        viewModel.currentNumberRoundPublisher
            .sink { [unowned self] currentRound in
                if currentRound == 0 {
                    countRoundStackView.alpha = 0
                } else {
                    currentRoundLable.text = "\(currentRound)"
                    countRoundStackView.alpha = 1
                }
            }
            .store(in: &cancellables)
        
        viewModel.isContinuePublisher
            .sink { [unowned self] isContinue in
                UIApplication.shared.isIdleTimerDisabled = isContinue
                startPauseButton.configuration = isContinue == true ? .pause : .play
            }
            .store(in: &cancellables)
        
        viewModel.totalRoundPublisher
            .sink { [unowned self] round in
                totalRoundsLable.text = "\(round)"
            }
            .store(in: &cancellables)
        
        viewModel.stopPublisher
            .sink { [unowned self] isFinish in
                if isFinish {
                    stopButton.isEnabled = false
                    soundPlayer = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func setupHierarchy() {
        view.addSubview(mainStackView)
        self.addChild(roundSettingsVC)
        mainStackView.addArrangedSubview(roundSettingsVC.view)
        roundSettingsVC.didMove(toParent: self)

        mainStackView.addArrangedSubview(spacerViewBeforeProgress)
        mainStackView.addArrangedSubview(countRoundStackView)
        
        countRoundStackView.addArrangedSubview(currentRoundLable)
        countRoundStackView.addArrangedSubview(deviderLable)
        countRoundStackView.addArrangedSubview(totalRoundsLable)

        mainStackView.addArrangedSubview(progressView)
        
        progressView.addSubview(roundPartLable)
        progressView.addSubview(timeStackView)
        timeStackView.addArrangedSubview(minutesLabel)
        timeStackView.addArrangedSubview(colonLabel)
        timeStackView.addArrangedSubview(secondsLabel)

        mainStackView.addArrangedSubview(spacerViewAfterProgress)
        mainStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(startPauseButton)
        buttonsStackView.addArrangedSubview(stopButton)
    }
    
    func setupLayout() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        roundSettingsVC.view.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor).isActive = true
        roundSettingsVC.view.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true

        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        progressView.widthAnchor.constraint(equalTo: progressView.heightAnchor).isActive = true
        
        let progresLeading = progressView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 20)
        progresLeading.priority = .defaultHigh
        progresLeading.isActive = true
        progressView.widthAnchor.constraint(lessThanOrEqualToConstant: 350).isActive = true

        roundPartLable.translatesAutoresizingMaskIntoConstraints = false
        roundPartLable.bottomAnchor.constraint(equalTo: timeStackView.topAnchor, constant: -20).isActive = true
        roundPartLable.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        
        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        timeStackView.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
        timeStackView.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true

        startPauseButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        startPauseButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stopButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        stopButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
 
        minutesLabel.widthAnchor.constraint(equalTo: secondsLabel.widthAnchor).isActive = true
        colonLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        spacerViewAfterProgress.heightAnchor.constraint(equalTo: spacerViewBeforeProgress.heightAnchor, multiplier: 1).isActive = true
    }
    
    func setupView() {
        view.backgroundColor = .secondarySystemBackground
        mainStackView.alignment = .center
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        
        countRoundStackView.axis = .horizontal
        countRoundStackView.alignment = .fill
        countRoundStackView.spacing = 16

        deviderLable.text = "/"
        roundPartLable.font = UIFont.preferredFont(forTextStyle: .title2)
        currentRoundLable.font = UIFont.preferredFont(forTextStyle: .title1, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        totalRoundsLable.font = UIFont.preferredFont(forTextStyle: .title3, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        deviderLable.font = UIFont.preferredFont(forTextStyle: .title3, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        
        buttonsStackView.alignment = .center
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 50
        
        startPauseButton.configuration = .play
        stopButton.configuration = .stop
        
        timeStackView.alignment = .fill
        timeStackView.axis = .horizontal
        timeStackView.spacing = 0
        
        minutesLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .light)
        minutesLabel.textAlignment = .right
        
        colonLabel.text = ":"
        colonLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .light)
        colonLabel.textAlignment = .center
        
        secondsLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .light)
        secondsLabel.textAlignment = .left

        startPauseButton.addTarget(self, action: #selector(handleStartPauseDidTap), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(handleStopButtonDidTap), for: .touchUpInside)
    }
    
    @objc func handleStartPauseDidTap() {
        stopButton.isEnabled = true
        viewModel.playPause()
    }
    
    @objc func handleStopButtonDidTap() {
        viewModel.stop()
        stopButton.isEnabled = false
    }
}

extension UIButton.Configuration {
    
    static var play: Self {
        var config = Self.borderedProminent()
        config.image = .init(systemName: "play.fill")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 40)
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(resource: .accent)
        
        config.cornerStyle = .capsule
        return config
    }
    
    static var pause: Self {
        var config = Self.borderedProminent()
        config.image = .init(systemName: "pause.fill")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 30)
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(resource: .accent)
        config.cornerStyle = .capsule
        return config
    }
        
    static var stop: Self {
        var config = Self.borderedProminent()
        config.image = .init(systemName: "stop.fill")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 20)
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(resource: .stop)
        config.cornerStyle = .capsule
        return config
    }
}

extension Int {
    
    var formattedTime: String {
        self <= 9 ? "0\(self)" : "\(self)"
    }
}
