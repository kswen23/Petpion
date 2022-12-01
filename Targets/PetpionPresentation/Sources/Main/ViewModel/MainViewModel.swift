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
    func sortingOptionDidChanged(with option: SortingOption)
}

protocol MainViewModelOutput {
    func makeWaterfallLayoutConfiguration() -> UICollectionLayoutWaterfallConfiguration
    func makeViewModel(for item: PetpionFeed) -> PetCollectionViewCell.ViewModel
}

protocol MainViewModelProtocol: MainViewModelInput, MainViewModelOutput {
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<Int, PetpionFeed>,Publishers.Map<PassthroughSubject<[PetpionFeed], Never>,NSDiffableDataSourceSnapshot<Int, PetpionFeed>>.Failure> { get }
    var sortingOptionSubject: CurrentValueSubject<SortingOption, Never> { get }
    var petpionFeedSubject: CurrentValueSubject<[PetpionFeed], Never> { get }

}

public final class MainViewModel: MainViewModelProtocol {
    
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
    }
    
    func fetchNextFeed() {
        Task {
            let result = await fetchFeedUseCase.fetchFeeds(sortBy: sortingOptionSubject.value)
            await MainActor.run {
                petpionFeedSubject.send(result)
            }
        }
    }
    
    func sortingOptionDidChanged(with option: SortingOption) {
        guard option != sortingOptionSubject.value else { return }
        switch option {
        case .popular:
            sortingOptionSubject.send(.popular)
        case .latest:
            sortingOptionSubject.send(.latest)
        }
        fetchNextFeed()
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
    
    func makeViewModel(for item: PetpionFeed) -> PetCollectionViewCell.ViewModel {
        return PetCollectionViewCell.ViewModel(petpionFeed: item)
    }

}

