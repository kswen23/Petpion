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

import PetpionDomain

protocol MainViewModelInput {
    func fetchNextFeed()
    func sortingOptionWillChange(with option: SortingOption)
    func sortingOptionDidChanged()
    func baseCollectionViewDidScrolled(to index: Int)
}

protocol MainViewModelOutput {
    var baseCollectionViewType: [SortingOption] { get }
    var baseCollectionViewNeedToScroll: Bool { get }
    func configureBaseCollectionViewLayout() -> UICollectionViewLayout
    func makeBaseCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<MainViewModel.Section, SortingOption>
    }

protocol MainViewModelProtocol: MainViewModelInput, MainViewModelOutput {
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var sortingOptionSubject: CurrentValueSubject<SortingOption, Never> { get }
    var popularFeedSubject: CurrentValueSubject<[PetpionFeed], Never> { get }
    var latestFeedSubject: CurrentValueSubject<[PetpionFeed], Never> { get }
}

final class MainViewModel: MainViewModelProtocol {
    
    enum Section {
        case main
    }
    
    let baseCollectionViewType: [SortingOption] = SortingOption.allCases
    var baseCollectionViewNeedToScroll: Bool = true
    let popularFeedSubject: CurrentValueSubject<[PetpionFeed], Never> = .init([])
    let latestFeedSubject: CurrentValueSubject<[PetpionFeed], Never> = .init([])
    let sortingOptionSubject: CurrentValueSubject<SortingOption, Never> = .init(.popular)
    
    let fetchFeedUseCase: FetchFeedUseCase
    
    init(fetchFeedUseCase: FetchFeedUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
        fetchFirstFeedPerSortingOption()
    }
    
    private func fetchFirstFeedPerSortingOption() {
        Task {
            let initialFeed = await fetchFeedUseCase.fetchInitialFeedPerSortingOption()
            await MainActor.run {
                popularFeedSubject.send(initialFeed[SortingOption.popular.rawValue])
                latestFeedSubject.send(initialFeed[SortingOption.latest.rawValue])
            }
        }
    }
    
    // MARK: - Input
    func fetchNextFeed() {
        Task {
            var resultFeed = getCurrentFeed()
            let fetchedFeed = await fetchFeedUseCase.fetchFeed(option: sortingOptionSubject.value)
            resultFeed = resultFeed + fetchedFeed
            await MainActor.run { [resultFeed] in
                sendResultFeed(feed: resultFeed)
            }
        }
    }
    
    func getCurrentFeed() -> [PetpionFeed] {
        switch sortingOptionSubject.value {
        case .popular:
            return popularFeedSubject.value
        case .latest:
            return latestFeedSubject.value
        }
    }
    
    private func sendResultFeed(feed: [PetpionFeed]) {
        switch sortingOptionSubject.value {
        case .popular:
            popularFeedSubject.send(feed)
        case .latest:
            latestFeedSubject.send(feed)
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
    func configureBaseCollectionViewLayout() -> UICollectionViewLayout {
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
            guard self?.baseCollectionViewNeedToScroll == true else { return }
            let index = Int(max(0, round(point.x / environment.container.contentSize.width)))
            self?.baseCollectionViewDidScrolled(to: index)
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
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
        
    func makeBaseCollectionViewCellRegistration() -> UICollectionView.CellRegistration<BaseCollectionViewCell, SortingOption> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            cell.viewModel = self.makeChildViewModel(index: indexPath)
            cell.bindSnapshot()
        }
    }
    
    func makeChildViewModel(index: IndexPath) -> BaseViewModel {
        let baseViewModel = BaseViewModel()
        if index.row == 0 {
            baseViewModel.petpionFeedSubject = self.popularFeedSubject
        } else {
            baseViewModel.petpionFeedSubject = self.latestFeedSubject
        }
        return baseViewModel
    }
    
}
