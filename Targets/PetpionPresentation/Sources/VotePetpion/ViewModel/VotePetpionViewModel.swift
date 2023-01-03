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
    
    private lazy var prefetchedPareArray: [PetpionVotePare] = []
    
    // MARK: - Initialize
    init(makeVoteListUseCase: MakeVoteListUseCase,
         fetchFeedUseCase: FetchFeedUseCase,
         votePetpionUseCase: VotePetpionUseCase) {
        self.makeVoteListUseCase = makeVoteListUseCase
        self.fetchFeedUseCase = fetchFeedUseCase
        self.votePetpionUseCase = votePetpionUseCase
        prepareVoteList()
    }
    
    private func prepareVoteList() {
        Task {
            let petpionVotePareArr = await makeVoteListUseCase.fetchVoteList(pare: 10)
            prefetchPareDetailImage(index: 0, with: petpionVotePareArr)
            prefetchPareDetailImage(index: 1, with: petpionVotePareArr)
            // loading Finish 타이밍
            await MainActor.run {
                petpionVotePareArraySubject.send(petpionVotePareArr)
            }
        }
    }
    
    // MARK: - Input
    func petpionFeedSelected(to section: ImageCollectionViewSection) {
        // send to usecase
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
        UICollectionView.CellRegistration { [weak self] cell, indexPath, item in
            guard let strongSelf = self else { return }
            if strongSelf.prefetchedPareArray.indices.contains(indexPath.item) {
                cell.viewModel = VotingListCollectionViewCellViewModel(votePare: strongSelf.prefetchedPareArray[indexPath.item])
                cell.parentableViewController = cellDelegate
                cell.bindViewModel()
            } else {
                print("prefetchedPare not contained")
            }
            strongSelf.prefetchPareDetailImage(index: indexPath.item+2,
                                               with: strongSelf.petpionVotePareArraySubject.value)
        }
    }
    
    private func prefetchPareDetailImage(index: Int, with arr: [PetpionVotePare]) {
        Task {
            guard index < arr.count else { return }
            prefetchedPareArray.append(await fetchFeedUseCase.fetchVotePareDetailImages(pare: arr[index]))
        }
    }
}
