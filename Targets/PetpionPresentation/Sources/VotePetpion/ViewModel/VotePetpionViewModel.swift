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

protocol VotePetpionViewModelInput {
    func petpionFeedDidSelected(to section: ImageCollectionViewSection)
}

protocol VotePetpionViewModelOutput {
    func configureVotingListCollectionViewLayout() -> UICollectionViewLayout
    func makeVotingListCollectionViewDataSource(collectionView: UICollectionView,
                                                cellDelegate: VotingListCollectionViewCellDelegate) -> UICollectionViewDiffableDataSource<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare>
}

protocol VotePetpionViewModelProtocol: VotePetpionViewModelInput, VotePetpionViewModelOutput {
    var fetchedVotePare: [PetpionVotePare] { get }
    var votePetpionUseCase: VotePetpionUseCase { get }
    var petpionVotePareArraySubject: CurrentValueSubject<[PetpionVotePare], Never> { get }
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare>,Publishers.Map<PassthroughSubject<[PetpionVotePare], Never>,NSDiffableDataSourceSnapshot<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare>>.Failure> { get }
    var voteIndexSubject: PassthroughSubject<Int, Never> { get }
    var needToPopViewController: Int { get }
}

final class VotePetpionViewModel: VotePetpionViewModelProtocol {
    
    enum VoteCollectionViewSection {
        case base
    }
    
    let fetchedVotePare: [PetpionVotePare]
    let votePetpionUseCase: VotePetpionUseCase
    
    lazy var petpionVotePareArraySubject: CurrentValueSubject<[PetpionVotePare], Never> = .init(fetchedVotePare)

    lazy var snapshotSubject = petpionVotePareArraySubject.map { items -> NSDiffableDataSourceSnapshot<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare> in
        var snapshot = NSDiffableDataSourceSnapshot<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare>()
        snapshot.appendSections([.base])
        snapshot.appendItems(items, toSection: .base)
        return snapshot
    }.eraseToAnyPublisher()
    
    var voteIndexSubject: PassthroughSubject<Int, Never> = .init()
    private var currentIndex = 0
    let needToPopViewController: Int = .max
    
    // MARK: - Initialize
    init(fetchedVotePare: [PetpionVotePare],
         votePetpionUseCase: VotePetpionUseCase) {
        self.fetchedVotePare = fetchedVotePare
        self.votePetpionUseCase = votePetpionUseCase
    }
    
    // MARK: - Input
    func petpionFeedDidSelected(to section: ImageCollectionViewSection) {
        let nextIndex = currentIndex + 1
        guard nextIndex < petpionVotePareArraySubject.value.count else {
            return voteIndexSubject.send(needToPopViewController)
        }
        Task {
            await uploadVoteResultOnServer(section: section)
            await MainActor.run {
                currentIndex = nextIndex
                voteIndexSubject.send(nextIndex)
            }
        }
    }
    
    // MARK: - Output
    func configureVotingListCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
        
    }
    
    func makeVotingListCollectionViewDataSource(collectionView: UICollectionView,
                                                cellDelegate: VotingListCollectionViewCellDelegate) -> UICollectionViewDiffableDataSource<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare> {
        let registration = makeVotingListCollectionViewCellRegistration(cellDelegate: cellDelegate)
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func makeVotingListCollectionViewCellRegistration(cellDelegate: VotingListCollectionViewCellDelegate) -> UICollectionView.CellRegistration<VotingListCollectionViewCell, PetpionVotePare> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            cell.configureItem(item: item)
            cell.parentableViewController = cellDelegate
        }
    }
    
    private func uploadVoteResultOnServer(section: ImageCollectionViewSection) async {
        var selectedFeedDidUpdated: Bool = false
        var deselectedFeedDidUpdated: Bool = false
        
        switch section {
        case .top:
            selectedFeedDidUpdated = await votePetpionUseCase.feedSelected(feed: petpionVotePareArraySubject.value[currentIndex].topFeed)
            deselectedFeedDidUpdated = await votePetpionUseCase.feedDeselected(feed: petpionVotePareArraySubject.value[currentIndex].bottomFeed)
        case .bottom:
            deselectedFeedDidUpdated = await votePetpionUseCase.feedDeselected(feed: petpionVotePareArraySubject.value[currentIndex].topFeed)
            selectedFeedDidUpdated = await votePetpionUseCase.feedSelected(feed: petpionVotePareArraySubject.value[currentIndex].bottomFeed)
        }
        
        if selectedFeedDidUpdated, deselectedFeedDidUpdated == false {
            print("VoteResult didn't uploaded!")
        }
    }
}
