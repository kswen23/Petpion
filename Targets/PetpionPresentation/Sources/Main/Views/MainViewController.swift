//
//  MainViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import UIKit

import PetpionCore
import PetpionDomain

final class MainViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    let viewModel: MainViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    lazy var petCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: UICollectionViewLayout())
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Initialize
    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchNextFeed()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        layout()
        configure()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutPetCollectionView()
    }
    
    private func layoutPetCollectionView() {
        view.addSubview(petCollectionView)
        petCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            petCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            petCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            petCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            petCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        petCollectionView.backgroundColor = .white
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationItem()
    }
    
    private func configureNavigationItem() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: #selector(personButtonDidTap)),
            UIBarButtonItem(image: UIImage(systemName: "camera"), style: .done, target: self, action: #selector(cameraButtonDidTap)),
            UIBarButtonItem(image: UIImage(systemName: "crown"), style: .done, target: self, action: #selector(cameraButtonDidTap))
        ]
        navigationController?.navigationBar.tintColor = .black
    }
    
    @objc func cameraButtonDidTap() {
        coordinator?.presentFeedImagePicker(viewController: self)
    }
    
    @objc func personButtonDidTap() {
        
    }
    
    private func configurePetCollectionView() {
        let waterfallLayout = UICollectionViewCompositionalLayout.makeWaterfallLayout(configuration: viewModel.makeWaterfallLayoutConfiguration())
        petCollectionView.setCollectionViewLayout(waterfallLayout, animated: true)
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, PetpionFeed> {
        let registration = makeCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: petCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<PetCollectionViewCell, PetpionFeed> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            let viewModel = self.viewModel.makeViewModel(for: item)
            cell.configure(with: viewModel)
        }
    }

    
    // MARK: - binding
    
    private func binding() {
        bindSnapshot()
    }
    
    private func bindSnapshot() {
        viewModel.snapshotSubject.sink { [weak self] snapshot in
            guard let strongSelf = self else { return }
            self?.configurePetCollectionView()
            self?.dataSource.apply(snapshot)
        }.store(in: &cancellables)
    }
}
