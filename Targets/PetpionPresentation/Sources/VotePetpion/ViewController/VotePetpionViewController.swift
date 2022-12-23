//
//  VotePetpionViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/21.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import UIKit

import PetpionCore
import PetpionDomain

final class VotePetpionViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: VotePetpionCoordinator?
    private let viewModel: VotePetpionViewModelProtocol
    
    private lazy var votingListCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                             collectionViewLayout: UICollectionViewLayout())
    private lazy var votingListCollectionViewDataSource = viewModel.makeVotingListCollectionViewDataSource(collectionView: votingListCollectionView)
    
    // MARK: - Initialize
    init(viewModel: VotePetpionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutVotingListCollectionView()
    }
    
    private func layoutVotingListCollectionView() {
        view.addSubview(votingListCollectionView)
        votingListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            votingListCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            votingListCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            votingListCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            votingListCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        votingListCollectionView.contentInsetAdjustmentBehavior = .never
        votingListCollectionView.alwaysBounceVertical = false
    }
    
    // MARK: - Configure
    private func configure() {
        configureVotingListCollectionView()
    }

    private func configureVotingListCollectionView() {
        votingListCollectionView.setCollectionViewLayout(viewModel.configureVotingListCollectionViewLayout(), animated: true)
    }

    private func binding() {
        bindSnapshotSubject()
    }
    
    private func bindSnapshotSubject() {
        viewModel.snapshotSubject.sink { [weak self] snapshot in
            self?.votingListCollectionViewDataSource.apply(snapshot)
        }.store(in: &cancellables)
    }
}
