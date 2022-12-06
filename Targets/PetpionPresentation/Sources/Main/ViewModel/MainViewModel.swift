//
//  MainViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionCore
import PetpionDomain

protocol MainViewModelInput {
    func fetchNextFeed()
    func sortingOptionWillChange(with option: SortingOption)
    func sortingOptionDidChanged()
    func baseCollectionViewDidScrolled(to index: Int)
}

protocol MainViewModelOutput {
    var baseCollectionViewType: [SortingOption] { get }
    var baseCollectionViewNeedToScroll: Bool { get set }
    func makeBaseCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<MainViewModel.Section, SortingOption>
    func makeWaterfallLayoutConfiguration() -> UICollectionLayoutWaterfallConfiguration
    func makePetFeedCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, PetpionFeed>
}

protocol MainViewModelProtocol: MainViewModelInput, MainViewModelOutput {
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<Int, PetpionFeed>,Publishers.Map<PassthroughSubject<[PetpionFeed], Never>,NSDiffableDataSourceSnapshot<Int, PetpionFeed>>.Failure> { get }
    var sortingOptionSubject: CurrentValueSubject<SortingOption, Never> { get }
    var petpionFeedSubject: CurrentValueSubject<[PetpionFeed], Never> { get }

}

public final class MainViewModel: MainViewModelProtocol {
    enum Section {
        case main
    }
    
    let baseCollectionViewType: [SortingOption] = SortingOption.allCases
    var baseCollectionViewNeedToScroll: Bool = true
    let petpionFeedSubject: CurrentValueSubject<[PetpionFeed], Never> = .init([])
    let sortingOptionSubject: CurrentValueSubject<SortingOption, Never> = .init(.popular)
    lazy var snapshotSubject = petpionFeedSubject.map { items -> NSDiffableDataSourceSnapshot<Int, PetpionFeed> in
        var snapshot = NSDiffableDataSourceSnapshot<Int, PetpionFeed>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        return snapshot
    }.eraseToAnyPublisher()
    
    let fetchFeedUseCase: FetchFeedUseCase
    
    init(fetchFeedUseCase: FetchFeedUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
        fetchNextFeed()
    }
    
    func fetchNextFeed() {
        Task {
            var resultFeed = petpionFeedSubject.value
            let fetchedFeed = await fetchFeedUseCase.fetchFeeds(sortBy: sortingOptionSubject.value)
            resultFeed = resultFeed + fetchedFeed
            await MainActor.run { [resultFeed] in
                petpionFeedSubject.send(resultFeed)
            }
        }
    }
    
    func sortingOptionWillChange(with option: SortingOption) {
        guard option != sortingOptionSubject.value else { return }
        baseCollectionViewNeedToScroll = false
        switch option {
        case .popular:
            sortingOptionSubject.send(.popular)
        case .latest:
            sortingOptionSubject.send(.latest)
        }
    }
    
    func sortingOptionDidChanged() {
        baseCollectionViewNeedToScroll = true
    }
    
    func baseCollectionViewDidScrolled(to index: Int) {
        guard index != sortingOptionSubject.value.rawValue else { return }
        switch index {
        case 0:
            sortingOptionSubject.send(.popular)
        case 1:
            sortingOptionSubject.send(.latest)
        default: break
        }
    }
    // MARK: - Output
    func makeWaterfallLayoutConfiguration() -> UICollectionLayoutWaterfallConfiguration {
        return UICollectionLayoutWaterfallConfiguration(
            columnCount: 2,
            spacing: 5,
            contentInsetsReference: UIContentInsetsReference.automatic) { [self] indexPath in
                petpionFeedSubject.value[indexPath.row].feedSize
            }
    }
    
    func makeBaseCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<MainViewModel.Section, SortingOption> {
        let registration = makeBaseCollectionViewCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    func makePetFeedCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, PetpionFeed> {
        let registration = makePetFeedCollectionViewCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func makeBaseCollectionViewCellRegistration() -> UICollectionView.CellRegistration<BaseCollectionViewCell, SortingOption> {
        UICollectionView.CellRegistration { [self] cell, indexPath, item in
            cell.backgroundColor = .blue
            cell.viewModel = self
            cell.bindSnapshot()
        }
    }
    
    private func makePetFeedCollectionViewCellRegistration() -> UICollectionView.CellRegistration<PetFeedCollectionViewCell, PetpionFeed> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            let viewModel = self.makeViewModel(for: item)
            cell.configure(with: viewModel)
        }
    }

    
    private func makeViewModel(for item:  PetpionFeed) -> PetFeedCollectionViewCell.ViewModel {
        return PetFeedCollectionViewCell.ViewModel(petpionFeed: item)
    }

}
