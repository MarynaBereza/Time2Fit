//
//  TimePickerController.swift
//  MLTimer
//
//  Created by Maryna Bereza on 12.02.2025.
//

import UIKit

class TimePickerController: UIViewController {
    
    let viewModel: TimePickerModelProtocol
    let pickerView = UIPickerView()
    init(viewModel: TimePickerModelProtocol) {
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
        view.backgroundColor = .systemBackground
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.initialSelectedIndices.enumerated().forEach { component, row in
            pickerView.selectRow(row, inComponent: component, animated: false)
        }
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
}

extension TimePickerController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        viewModel.rows.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.rows[component].count
    }
}

extension TimePickerController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.rows[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.updateSelectedRow(row, inComponent: component)
        if row == 0 {
            let newSelection = viewModel.checkSelection(row: row, comp: component)
            let newRow = newSelection.row
            let newComponent = newSelection.component
            
            pickerView.selectRow(newRow, inComponent: newComponent, animated: true)
        }
        viewModel.confirm()
    }
}

