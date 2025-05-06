//
//  RoundSettingsViewController.swift
//  MLTimer
//
//  Created by Maryna Bereza on 12.02.2025.
//

import Foundation
import UIKit
import Combine

struct InfoSetData: Hashable, Equatable, Codable {
    let title: String
    let work: Time
    let rest: Time
    let round: Int
}

class RoundSettingsViewController: UIViewController {
    let viewModel: RoundSettingsViewModelProtocol
    let sets = UserDefaults.workoutSets
    
    let verticalStackView = UIStackView()
    let horizontalStackView = UIStackView()
    let workView = PickerSouceView()
    let restView = PickerSouceView()
    let roundView = PickerSouceView()
    var cancelables = Set<AnyCancellable>()
    
    let horizontalSetStackView = UIStackView()
    let addButton = UIButton()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
    lazy var dataSource: DataSource = configureDataSource()
    
    enum Section: Int, CaseIterable {
        case main
    }
    typealias DataSource = UICollectionViewDiffableDataSource<Section, InfoSetData>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, InfoSetData>
    typealias SetCell = Cell<SetSettingsCell>
    
    var savedSets = UserDefaults.workoutSets {
        didSet {
            let snapshot = createSnapshot(infoSets: savedSets)
            dataSource.apply(snapshot)
        }
    }

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
        
        let snapshot = createSnapshot(infoSets: savedSets)
        dataSource.apply(snapshot)
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
        
        viewModel.isEnabledPublisher
            .sink { [unowned self] isEnabled in
                workView.isEnabled = isEnabled
                restView.isEnabled = isEnabled
                roundView.isEnabled = isEnabled
                collectionView.isUserInteractionEnabled = isEnabled
                collectionView.alpha = isEnabled ? 1 : 0.5
                addButton.isEnabled = isEnabled
            }
            .store(in: &cancelables)
    }
    
    @objc func addTapped() {
        let alert = UIAlertController(title: "Set title", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            let setTitle = alert.textFields![0].text
            let newSet = InfoSetData(title: setTitle ?? "Set", work: viewModel.work, rest: viewModel.rest, round: viewModel.round)
            var workoutSets = UserDefaults.workoutSets
            workoutSets.insert(newSet, at: 0)
            UserDefaults.workoutSets = workoutSets
            savedSets = workoutSets
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func setupHierarchy() {
        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.addArrangedSubview(horizontalSetStackView)
        
        horizontalStackView.addArrangedSubview(workView)
        horizontalStackView.addArrangedSubview(restView)
        horizontalStackView.addArrangedSubview(roundView)
        
        horizontalSetStackView.addArrangedSubview(addButton)
        horizontalSetStackView.addArrangedSubview(collectionView)
    }
    
    func setupLayout() {
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        collectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupView() {
        SetCell.register(in: collectionView)
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.bouncesVertically = false
        
        addButton.layer.cornerRadius = 8
        
        verticalStackView.alignment = .fill
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 24
        
        horizontalStackView.alignment = .fill
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 16
        horizontalStackView.distribution = .fillEqually
        
        horizontalSetStackView.alignment = .center
        horizontalSetStackView.axis = .horizontal
        horizontalSetStackView.spacing = 16

        addButton.setImage(UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 20))), for: .normal)
        addButton.backgroundColor = .systemFill
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        workView.title = "WORK"
        workView.image = UIImage(systemName: "timer")?.withConfiguration(UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 20)))
        workView.color = UIColor(resource: .accent)
        workView.onDidTap = { [weak self] in
            self?.viewModel.showWorkTimePicker()
        }
        restView.title = "REST"
        restView.image = UIImage(systemName: "timer")?.withConfiguration(UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 20)))
        restView.color = UIColor(resource: .stop)
        restView.onDidTap = { [weak self] in
            self?.viewModel.showRestTimePicker()
        }
        roundView.title = "ROUNDS"
        
        roundView.image = UIImage(systemName: "xmark")?.withConfiguration(UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 20)))
        roundView.color = .secondaryLabel
        roundView.onDidTap = { [weak self] in
            self?.viewModel.showRoundPicker()
        }
    }
    
    // MARK: - CollectionView
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(1), heightDimension: .fractionalHeight(1))
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
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = SetCell.dequeue(from: collectionView, for: indexPath)
            cell.rootView.updateData(info: item)
            return cell
        }
        return dataSource
    }
}

extension RoundSettingsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.updateCurrentSet(to: item)
    }
}
