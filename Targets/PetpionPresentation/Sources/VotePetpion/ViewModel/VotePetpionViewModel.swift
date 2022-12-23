//
//  VotePetpionViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/21.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import UIKit

import PetpionDomain

protocol VotePetpionInput {
    
}

protocol VotePetpionOutput {
    func configureVotingListCollectionViewLayout() -> UICollectionViewLayout
    func makeVotingListCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<VotePetpionViewModel.Section, PetpionVotePare>
}

protocol VotePetpionViewModelProtocol: VotePetpionInput, VotePetpionOutput {
    var makeVoteListUseCase: MakeVoteListUseCase { get }
    var petpionVotePareSubject: CurrentValueSubject<[PetpionVotePare], Never> { get }
    
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<VotePetpionViewModel.Section, PetpionVotePare>,Publishers.Map<PassthroughSubject<[PetpionVotePare], Never>,NSDiffableDataSourceSnapshot<VotePetpionViewModel.Section, PetpionVotePare>>.Failure> { get }
}

final class VotePetpionViewModel: VotePetpionViewModelProtocol {

    enum Section {
        case base
    }
    
    private var cancellables = Set<AnyCancellable>()
    var makeVoteListUseCase: MakeVoteListUseCase
    
    var petpionVotePareSubject: CurrentValueSubject<[PetpionVotePare], Never> = .init([])
    lazy var snapshotSubject = petpionVotePareSubject.map { items -> NSDiffableDataSourceSnapshot<VotePetpionViewModel.Section, PetpionVotePare> in
        var snapshot = NSDiffableDataSourceSnapshot<VotePetpionViewModel.Section, PetpionVotePare>()
        snapshot.appendSections([.base])
        snapshot.appendItems(items, toSection: .base)
        return snapshot
    }.eraseToAnyPublisher()

    // MARK: - Initialize
    init(makeVoteListUseCase: MakeVoteListUseCase) {
        self.makeVoteListUseCase = makeVoteListUseCase
        prepareVoteList()
    }
    
    private func prepareVoteList() {
        Task {
            let petpionVotePare = await makeVoteListUseCase.fetchVoteList(pare: 10)
            await MainActor.run {
                petpionVotePareSubject.send(petpionVotePare)
            }
        }
    }
    // MARK: - Input
    
    // MARK: - Output
    func configureVotingListCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
            //            guard self?.baseCollectionViewNeedToScroll == true else { return }
            //            let index = Int(max(0, round(point.x / environment.container.contentSize.width)))
            //            self?.baseCollectionViewDidScrolled(to: index)
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
        
    }
    
    func makeVotingListCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<VotePetpionViewModel.Section, PetpionVotePare> {
        let registration = makeVotingListCollectionViewCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func makeVotingListCollectionViewCellRegistration() -> UICollectionView.CellRegistration<VotingListCollectionViewCell, PetpionVotePare> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            // detailImage fetch in here
            cell
        }
    }
    
}
