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
    func petpionFeedSelected(to section: ImageCollectionViewSection)
    func fetchVoteList()
}

protocol VotePetpionViewModelOutput {
    func configureVotingListCollectionViewLayout() -> UICollectionViewLayout
    func makeVotingListCollectionViewDataSource(collectionView: UICollectionView,
                                                cellDelegate: VotingListCollectionViewCellDelegate) -> UICollectionViewDiffableDataSource<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare>
}

protocol VotePetpionViewModelProtocol: VotePetpionViewModelInput, VotePetpionViewModelOutput {
    var makeVoteListUseCase: MakeVoteListUseCase { get }
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var votePetpionUseCase: VotePetpionUseCase { get }
    var petpionVotePareArraySubject: CurrentValueSubject<[PetpionVotePare], Never> { get }
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare>,Publishers.Map<PassthroughSubject<[PetpionVotePare], Never>,NSDiffableDataSourceSnapshot<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare>>.Failure> { get }
    var voteIndexSubject: PassthroughSubject<Int, Never> { get }
}

final class VotePetpionViewModel: VotePetpionViewModelProtocol {
    
    enum VoteCollectionViewSection {
        case base
    }
    
    private var cancellables = Set<AnyCancellable>()
    var makeVoteListUseCase: MakeVoteListUseCase
    var fetchFeedUseCase: FetchFeedUseCase
    var votePetpionUseCase: VotePetpionUseCase
    
    var petpionVotePareArraySubject: CurrentValueSubject<[PetpionVotePare], Never> = .init([])

    lazy var snapshotSubject = petpionVotePareArraySubject.map { items -> NSDiffableDataSourceSnapshot<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare> in
        var snapshot = NSDiffableDataSourceSnapshot<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare>()
        snapshot.appendSections([.base])
        snapshot.appendItems(items, toSection: .base)
        return snapshot
    }.eraseToAnyPublisher()
    
    var voteIndexSubject: PassthroughSubject<Int, Never> = .init()
    private var currentIndex = 0
    
    // MARK: - Initialize
    init(makeVoteListUseCase: MakeVoteListUseCase,
         fetchFeedUseCase: FetchFeedUseCase,
         votePetpionUseCase: VotePetpionUseCase) {
        self.makeVoteListUseCase = makeVoteListUseCase
        self.fetchFeedUseCase = fetchFeedUseCase
        self.votePetpionUseCase = votePetpionUseCase
        // fetch user PlayLog
        // 3시간 이전 접속 -> 저장된voteList, 3시간 이후 접속 -> 새로 voteList생성
//        prepareVoteList()
    }
    
    // MARK: - Input
    func fetchVoteList() {
        currentIndex = 0
        Task {
            let petpionVotePareArr = await makeVoteListUseCase.fetchVoteList(pare: 10)
            let fetchedVotePare = await prefetchAllPareDetailImage(origin: petpionVotePareArr)

            // loading Finish 타이밍
            await MainActor.run {
                petpionVotePareArraySubject.send(fetchedVotePare)
                voteIndexSubject.send(currentIndex)
            }
        }
    }
    
    func petpionFeedSelected(to section: ImageCollectionViewSection) {
        let nextIndex = currentIndex + 1
        guard nextIndex < petpionVotePareArraySubject.value.count else { return }
        Task {
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
            
            if selectedFeedDidUpdated, deselectedFeedDidUpdated == true {
                print("updated")
            } else {
                print("error")
            }
            currentIndex = nextIndex
            await MainActor.run {
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
    
    private func prefetchAllPareDetailImage(origin: [PetpionVotePare]) async -> [PetpionVotePare] {
        var resultArr = [PetpionVotePare]()
        for pare in origin {
            resultArr.append(await fetchFeedUseCase.fetchVotePareDetailImages(pare: pare))
        }
        return resultArr
    }
}
