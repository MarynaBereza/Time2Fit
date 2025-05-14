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
    let verticalStackView = UIStackView()
    let horizontalStackView = UIStackView()
    let workView = PickerSouceView()
    let restView = PickerSouceView()
    let roundView = PickerSouceView()
    var cancelables = Set<AnyCancellable>()

    let horizontalEditStackView = UIStackView()
    let titleSetSectionLabel = UILabel()
    let editButton = UIButton()
    
    let horizontalSetStackView = UIStackView()
    let saveWorkoutSetLabel = UILabel()
    let addButton = UIButton()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
    lazy var dataSource: DataSource = configureDataSource()
    
    enum Section: Int, CaseIterable {
        case main
    }
    typealias DataSource = UICollectionViewDiffableDataSource<Section, InfoSetData>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, InfoSetData>
    typealias SetCell = Cell<SetSettingsCell>

    init(viewModel: RoundSettingsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
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
        
        viewModel.isEnabledPublisher.combineLatest(viewModel.savedSetsPublisher.map{ $0.isEmpty })
            .sink { [unowned self] isEnambled, isEmpty in
                editButton.titleLabel?.alpha = (!isEmpty && isEnambled) ? 1 : 0
            }
            .store(in: &cancelables)
        
        viewModel.isEnabledPublisher
            .sink { [unowned self] isEnabled in
                workView.isEnabled = isEnabled
                restView.isEnabled = isEnabled
                roundView.isEnabled = isEnabled
                collectionView.isUserInteractionEnabled = isEnabled
                collectionView.alpha = isEnabled ? 1 : 0.5
                
                addButton.isEnabled = isEnabled
                editButton.isUserInteractionEnabled = isEnabled
                editButton.titleLabel?.textColor = isEnabled ? UIColor(resource: .stop) : .secondaryLabel
                if editButton.isSelected {
                    editButton.setTitle("Edit", for: .normal)
                    editButton.isSelected.toggle()
                    collectionView.reloadData()
                }
            }
            .store(in: &cancelables)
        
        viewModel.savedSetsPublisher
            .sink { [unowned self] savedSets in
                let snapshot = createSnapshot(infoSets: savedSets)
                dataSource.apply(snapshot, animatingDifferences: !savedSets.isEmpty)
                editButton.isHidden = savedSets.isEmpty
                saveWorkoutSetLabel.isHidden = !savedSets.isEmpty
                editButton.titleLabel?.alpha = savedSets.isEmpty ? 0 : 1
                saveWorkoutSetLabel.isHidden = !savedSets.isEmpty
                if savedSets.isEmpty {
                    editButton.isSelected = false
                    addButton.isEnabled = true
                    editButton.setTitle("Edit", for: .normal)
                }
                saveWorkoutSetLabel.isHidden = !savedSets.isEmpty
            }
            .store(in: &cancelables)
    }

    @objc func addNewWorkoutSetTapped() {
        let alert = UIAlertController(title: "Set title", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            let setTitle = alert.textFields?[0].text ?? ""
            viewModel.saveSet(withTitle: setTitle)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc func editHandleTap(sender: UIButton) {
        editButton.isSelected.toggle()
        collectionView.reloadData()
        addButton.isEnabled = sender.isSelected ? false : true
        
        let title = sender.isSelected ? "Done" : "Edit"
        editButton.setTitle(title, for: .normal)
    }
    
    func setupHierarchy() {
        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.addArrangedSubview(horizontalEditStackView)
        verticalStackView.addArrangedSubview(horizontalSetStackView)
    
        horizontalStackView.addArrangedSubview(workView)
        horizontalStackView.addArrangedSubview(restView)
        horizontalStackView.addArrangedSubview(roundView)
        
        horizontalEditStackView.addArrangedSubview(titleSetSectionLabel)
        horizontalEditStackView.addArrangedSubview(editButton)

        horizontalSetStackView.addArrangedSubview(addButton)
        horizontalSetStackView.addArrangedSubview(saveWorkoutSetLabel)
        horizontalSetStackView.addArrangedSubview(collectionView)
    }
    
    func setupLayout() {
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        horizontalEditStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupView() {
        SetCell.register(in: collectionView)
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.bouncesVertically = false
    
        horizontalEditStackView.axis = .horizontal
        horizontalEditStackView.spacing = 10
        horizontalEditStackView.alignment = .fill
        
        titleSetSectionLabel.text = "Workout sets"
        titleSetSectionLabel.textColor = .secondaryLabel
        titleSetSectionLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(editHandleTap), for: .touchUpInside)
        editButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        editButton.setTitleColor(UIColor(resource: .stop), for: .normal)
        
        saveWorkoutSetLabel.text = "Tap plus to save current settings workout set."
        saveWorkoutSetLabel.numberOfLines = 2
        saveWorkoutSetLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        saveWorkoutSetLabel.textColor = .secondaryLabel
        
        verticalStackView.alignment = .fill
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 8
        verticalStackView.setCustomSpacing(0, after: horizontalEditStackView)
        
        horizontalStackView.alignment = .fill
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 16
        horizontalStackView.distribution = .fillEqually
        
        horizontalSetStackView.alignment = .center
        horizontalSetStackView.axis = .horizontal
        horizontalSetStackView.spacing = 16

        addButton.layer.cornerRadius = 8
        addButton.setImage(UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 20))), for: .normal)
        addButton.backgroundColor = .systemFill
        addButton.addTarget(self, action: #selector(addNewWorkoutSetTapped), for: .touchUpInside)

        workView.title = "WORK"
        workView.image = UIImage(systemName: "timer")?.withConfiguration(UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 15)))
        workView.color = UIColor(resource: .accent)
        workView.onDidTap = { [weak self] in
            self?.viewModel.showWorkTimePicker()
        }
        restView.title = "REST"
        restView.image = UIImage(systemName: "timer")?.withConfiguration(UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 15)))
        restView.color = UIColor(resource: .stop)
        restView.onDidTap = { [weak self] in
            self?.viewModel.showRestTimePicker()
        }
        roundView.title = "ROUNDS"
        
        roundView.image = UIImage(systemName: "xmark")?.withConfiguration(UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 15)))
        roundView.color = .secondaryLabel
        roundView.onDidTap = { [weak self] in
            self?.viewModel.showRoundPicker()
        }
    }
    
    // MARK: - CollectionView
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(120), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(120), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10

        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func createSnapshot(infoSets: [InfoSetData]) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([Section.main])
        let sets = infoSets.map { $0 }
        snapshot.appendItems(sets, toSection: .main)
        return snapshot
    }
    
    func configureDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            let cell = SetCell.dequeue(from: collectionView, for: indexPath)
            cell.rootView.updateData(info: item)
            cell.rootView.isEditingMode = self?.editButton.isSelected ?? false
            return cell
        }
        return dataSource
    }
}

extension RoundSettingsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
 
        if editButton.isSelected {
            viewModel.removeWorkoutSet(index: indexPath.row)
        } else {
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            viewModel.updateCurrentSet(to: item)
        }
    }
}
