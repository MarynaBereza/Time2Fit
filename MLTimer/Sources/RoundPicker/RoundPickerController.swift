//
//  RoundPickerController.swift
//  MLTimer
//
//  Created by Maryna Bereza on 13.02.2025.
//

import Foundation
import UIKit

class RoundPickerController: UIViewController {
    
    let viewModel: RoundPickerModelProtocol
    let pickerView = UIPickerView()
    
    init(viewModel: RoundPickerModelProtocol) {
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
        view.backgroundColor = .systemBackground
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        pickerView.selectRow(viewModel.value - 1, inComponent: 0, animated: false)
    }

    func setupHierarchy() {
        view.addSubview(pickerView)
    }
    
    func setupLayout() {
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -20).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }
    
    func setupView() {
//        pickerStackView.alignment = .fill
//        pickerStackView.axis = .vertical
//        pickerStackView.spacing = 10
    }
    
    @objc func buttonAction() {
        self.dismiss(animated: true)
    }
    
    @objc func okAction() {
//        viewModel.confirm()
    }
}

extension RoundPickerController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.rounds.count
    }
}

extension RoundPickerController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return "\(viewModel.rounds[row])"

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.updateSelectedRow(row: row)
        viewModel.confirm()
    }
}


