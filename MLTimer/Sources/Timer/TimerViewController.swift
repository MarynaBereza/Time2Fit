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
    var cancelables = Set<AnyCancellable>()
    
    var player: AVAudioPlayer!
    
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
    }
    
    func playSound(name: String, type: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            return }
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func bindViewModel() {
        viewModel.remainingTimePublisher
            .sink { [unowned self] time in
                
                if time.seconds == 3 || time.seconds == 2 || time.seconds == 1 {
                    playSound(name: "tick", type: "mp3")
                }
                if time.seconds == 0 {
                    playSound(name: "bell", type: "mp3")
                }
                if time.seconds != 0 {
                    minutesLabel.text = time.minutes.formattedTime
                    secondsLabel.text = time.seconds.formattedTime
                }
            }
            .store(in: &cancelables)
        
        viewModel.settingsViewModel.workTimerPublisher
            .sink { [unowned self] time in
                minutesLabel.text = time.minutes.formattedTime
                secondsLabel.text = time.seconds.formattedTime
            }
            .store(in: &cancelables)
        
        viewModel.progressPublisher
            .sink { [unowned self] progress in
                progressView.progress = progress
            }
            .store(in: &cancelables)
        
        viewModel.roundPartPublisher
            .sink { [unowned self] partRound in
                roundPartLable.text = partRound
                progressView.progressColor = partRound == RoundPart.work.rawValue ?
                UIColor(red: 0.471, green: 0.627, blue: 0.431, alpha: 1).cgColor :
                UIColor.systemPink.cgColor
            }
            .store(in: &cancelables)
        
        viewModel.currentNumberRoundPublisher
            .sink { [unowned self] currentRound in
                currentRoundLable.text = "\(currentRound)"
            }
            .store(in: &cancelables)
        
        viewModel.isContinuePublisher
            .sink { [unowned self] isContinue in
                startPauseButton.configuration = isContinue == true ? .pause : .play
            }
            .store(in: &cancelables)
        
        viewModel.totalRoundPublisher
            .sink { [unowned self] round in
                totalRoundsLable.text = "\(round)"
            }
            .store(in: &cancelables)
        
        viewModel.stopPublisher
            .sink { [unowned self] isFinish in
                if isFinish {
                    roundSettingsVC.workView.isEnabled = true
                    roundSettingsVC.restView.isEnabled = true
                    roundSettingsVC.roundView.isEnabled = true
                }
            }
            .store(in: &cancelables)
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
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        roundSettingsVC.view.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor).isActive = true
        roundSettingsVC.view.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true

        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        progressView.widthAnchor.constraint(equalTo: progressView.heightAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor).isActive = true

        roundPartLable.translatesAutoresizingMaskIntoConstraints = false
        roundPartLable.bottomAnchor.constraint(equalTo: timeStackView.topAnchor, constant: -20).isActive = true
        roundPartLable.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        
        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        timeStackView.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
        timeStackView.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        
        buttonsStackView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        startPauseButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        minutesLabel.widthAnchor.constraint(equalTo: secondsLabel.widthAnchor).isActive = true
        colonLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        spacerViewAfterProgress.heightAnchor.constraint(equalTo: spacerViewBeforeProgress.heightAnchor, multiplier: 1).isActive = true
    }
    
    func setupView() {
        view.backgroundColor = UIColor.systemBackground
        mainStackView.alignment = .center
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        
        countRoundStackView.axis = .horizontal
        countRoundStackView.alignment = .fill
        countRoundStackView.spacing = 20

        deviderLable.text = "/"
        roundPartLable.font = UIFont.preferredFont(forTextStyle: .title2)
        currentRoundLable.font = UIFont.preferredFont(forTextStyle: .largeTitle, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        totalRoundsLable.font = UIFont.preferredFont(forTextStyle: .title2, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        deviderLable.font = UIFont.preferredFont(forTextStyle: .title2, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        
        buttonsStackView.alignment = .fill
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 50
        buttonsStackView.distribution = .fillEqually
        
        startPauseButton.configuration = .play
        stopButton.configuration = .stop
        
        timeStackView.alignment = .fill
        timeStackView.axis = .horizontal
        timeStackView.spacing = 0
        
        minutesLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 90)
        minutesLabel.textAlignment = .right
        
        colonLabel.text = ":"
        colonLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 90)
        colonLabel.textAlignment = .center
        
        secondsLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 90)
        secondsLabel.textAlignment = .left

        startPauseButton.addTarget(self, action: #selector(handleStartPauseDidTap), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(handleStopButtonDidTap), for: .touchUpInside)
    }
    
    @objc func handleStartPauseDidTap() {
        roundSettingsVC.workView.isEnabled = false
        roundSettingsVC.restView.isEnabled = false
        roundSettingsVC.roundView.isEnabled = false
        viewModel.playPause()
    }
    
    @objc func handleStopButtonDidTap() {
        roundSettingsVC.workView.isEnabled = true
        roundSettingsVC.restView.isEnabled = true
        roundSettingsVC.roundView.isEnabled = true
        viewModel.stop()
    }
}

extension UIButton.Configuration {
    
    static var play: Self {
        var config = Self.borderedProminent()
        config.image = .init(systemName: "play.fill")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 30)
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(red: 0.471, green: 0.627, blue: 0.431, alpha: 1)
        config.cornerStyle = .capsule
        return config
    }
    
    static var pause: Self {
        var config = Self.borderedProminent()
        config.image = .init(systemName: "pause.fill")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 30)
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(red: 0.471, green: 0.627, blue: 0.431, alpha: 1)
        config.cornerStyle = .capsule
        return config
    }
        
    static var stop: Self {
        var config = Self.borderedProminent()
        config.image = .init(systemName: "stop.fill")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 30)
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemPink.withAlphaComponent(0.8)
        config.cornerStyle = .capsule
        return config
    }
}

extension Int {
    
    var formattedTime: String {
        self <= 9 ? "0\(self)" : "\(self)"
    }
}
