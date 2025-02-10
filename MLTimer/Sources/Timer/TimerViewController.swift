//
//  TimerViewController.swift
//  MLTimer
//
//  Created by Maryna Bereza on 16.01.2025.
//

import UIKit
import Combine


class TimerViewController: UIViewController {
    
    let viewModel: TimerViewModelProtocol
    let startPauseButton = UIButton()
    let stopButton = UIButton()
    
    let mainStackView = UIStackView()
    
    let settingsStackView = UIStackView()
    let workView = PickerSouceView()
    let restView = PickerSouceView()
    let roundsView = PickerSouceView()
    
    let roundPartLable = UILabel()
    
    let countRoundStackView = UIStackView()
    let roundTitleLable = UILabel()
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
    var cancelables = Set<AnyCancellable>()

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
    
    func bindViewModel() {
        viewModel.remainingTimePublisher
            .sink { [unowned self] time in
                minutesLabel.text = time.minutes.formattedTime
                secondsLabel.text = time.seconds.formattedTime
            }
            .store(in: &cancelables)
        
        viewModel.workTimePublisher
            .sink { [unowned self] workTime in
                workView.value = "\(workTime.minutes.formattedTime) : \(workTime.seconds.formattedTime)"
            }
            .store(in: &cancelables)
        
        viewModel.restTimePublisher
            .sink { [unowned self] restTime in
                restView.value = "\(restTime.minutes.formattedTime) : \(restTime.seconds.formattedTime)"
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
            }
            .store(in: &cancelables)
        
        viewModel.currentNumberRoundPublisher
            .sink { [unowned self] currentRound in
                currentRoundLable.text = "\(currentRound)"
            }
            .store(in: &cancelables)
        
        viewModel.totalRoundPublisher
            .sink { [unowned self] n in
                totalRoundsLable.text = n
                roundsView.value = n
            }
            .store(in: &cancelables)
        
        viewModel.isContinuePublisher
            .sink { [unowned self] isContinue in
                startPauseButton.configuration = isContinue == true ? .pause : .play
            }
            .store(in: &cancelables)
    }
    
    func setupHierarchy() {
        
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(settingsStackView)
        settingsStackView.addArrangedSubview(workView)
        settingsStackView.addArrangedSubview(restView)
        settingsStackView.addArrangedSubview(roundsView)
        mainStackView.addArrangedSubview(spacerViewBeforeProgress)
        mainStackView.addArrangedSubview(progressView)
        
        progressView.addSubview(roundPartLable)
        progressView.addSubview(timeStackView)
        timeStackView.addArrangedSubview(minutesLabel)
        timeStackView.addArrangedSubview(colonLabel)
        timeStackView.addArrangedSubview(secondsLabel)
        
        mainStackView.addArrangedSubview(countRoundStackView)
        countRoundStackView.addArrangedSubview(roundTitleLable)
        countRoundStackView.addArrangedSubview(currentRoundLable)
        countRoundStackView.addArrangedSubview(deviderLable)
        countRoundStackView.addArrangedSubview(totalRoundsLable)
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

        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        progressView.widthAnchor.constraint(equalTo: progressView.heightAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor).isActive = true

        roundPartLable.translatesAutoresizingMaskIntoConstraints = false
        roundPartLable.topAnchor.constraint(equalTo: progressView.topAnchor, constant: 50).isActive = true
        roundPartLable.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        
        timeStackView.translatesAutoresizingMaskIntoConstraints = false
        timeStackView.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
        timeStackView.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        
        buttonsStackView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        startPauseButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        minutesLabel.widthAnchor.constraint(equalTo: secondsLabel.widthAnchor).isActive = true
        spacerViewAfterProgress.heightAnchor.constraint(equalTo: spacerViewBeforeProgress.heightAnchor, multiplier: 1).isActive = true
    }
    
    func setupView() {
        view.backgroundColor = UIColor.systemBackground
        mainStackView.alignment = .center
        mainStackView.axis = .vertical
        mainStackView.spacing = 20

        settingsStackView.alignment = .fill
        settingsStackView.axis = .horizontal
        settingsStackView.spacing = 20
        workView.title = "Work"
        restView.title = "Rest"
        roundsView.title = "Rounds"

        roundPartLable.font = UIFont(name: "Apple SD Gothic Neo", size: 30)
        currentRoundLable.font = UIFont(name: "Apple SD Gothic Neo", size: 20)

        countRoundStackView.axis = .horizontal
        countRoundStackView.alignment = .fill
        countRoundStackView.spacing = 20
        roundTitleLable.text = "ROUND"
        
        deviderLable.text = "/"

        buttonsStackView.alignment = .fill
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 50
        buttonsStackView.distribution = .fillEqually
        
        startPauseButton.configuration = .play
        stopButton.configuration = .stop
        
        timeStackView.alignment = .fill
        timeStackView.axis = .horizontal
        timeStackView.spacing = 10
        
        minutesLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 90)
        minutesLabel.textAlignment = .left
        
        colonLabel.text = ":"
        colonLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 90)
        colonLabel.textAlignment = .center
        
        secondsLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 90)
        secondsLabel.textAlignment = .right

        startPauseButton.addTarget(self, action: #selector(handleStartPauseDidTap), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(handleStopButtonDidTap), for: .touchUpInside)
    }
    
    @objc func handleStartPauseDidTap() {
        viewModel.playPause()
    }
    
    @objc func handleStopButtonDidTap() {
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
