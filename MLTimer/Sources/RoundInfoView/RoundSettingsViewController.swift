//
//  RoundSettingsViewController.swift
//  MLTimer
//
//  Created by Maryna Bereza on 12.02.2025.
//

import Foundation
import UIKit
import Combine

class RoundSettingsViewController: UIViewController {
    let viewModel: RoundSettingsViewModelProtocol
    let horizontalStackView = UIStackView()
    let workView = PickerSouceView()
    let restView = PickerSouceView()
    let roundView = PickerSouceView()
    var cancelables = Set<AnyCancellable>()
    
    init(viewModel: RoundSettingsViewModelProtocol) {
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
        viewModel.workTimePublisher
            .sink { [unowned self] text in
                workView.value = text
            }
            .store(in: &cancelables)
        
        viewModel.restTimePublisher
            .sink { [unowned self] text in
                restView.value = text
            }
            .store(in: &cancelables)
        
        viewModel.roundPublisher
            .sink { [unowned self] rounds in
                roundView.value = rounds
            }
            .store(in: &cancelables)
    }
    
    func setupHierarchy() {
        view.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(workView)
        horizontalStackView.addArrangedSubview(restView)
        horizontalStackView.addArrangedSubview(roundView)
    }
    
    func setupLayout() {
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        horizontalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        horizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        horizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
    
    func setupView() {
        horizontalStackView.alignment = .fill
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 10
        horizontalStackView.distribution = .fillEqually
        
        workView.title = "WORK"
        workView.image = UIImage(systemName: "timer")
        workView.onDidTap = { [weak self] in
            self?.viewModel.showWorkTimePicker()
        }
        restView.title = "REST"
        restView.image = UIImage(systemName: "timer")
        restView.onDidTap = { [weak self] in
            self?.viewModel.showRestTimePicker()
        }
        roundView.title = "ROUNDS"
        roundView.image = UIImage(systemName: "arrow.2.circlepath")
        roundView.onDidTap = { [weak self] in
            self?.viewModel.showRoundPicker()
        }
    }
}
