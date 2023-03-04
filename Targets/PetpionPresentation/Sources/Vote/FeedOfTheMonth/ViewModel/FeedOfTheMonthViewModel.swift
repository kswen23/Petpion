//
//  FeedOfTheMonthViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/03/04.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionDomain


protocol FeedOfTheMonthViewModelInput {
    func fetchFeedOfTheMonth(isFirst: Bool)
}

protocol FeedOfTheMonthViewModelOutput {
    func makeWaterfallLayoutConfiguration() -> UICollectionLayoutWaterfallConfiguration
    func makePetFeedCollectionViewDataSource(collectionView: UICollectionView, listener: PetFeedCollectionViewCellListener) -> UICollectionViewDiffableDataSource<Int, PetpionFeed>
}

protocol FeedOfTheMonthViewModelProtocol: FeedOfTheMonthViewModelInput, FeedOfTheMonthViewModelOutput {
    
    var targetDate: Date { get }
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var feedOfTheMonthSubject: CurrentValueSubject<[PetpionFeed], Never> { get }
    var isFirstFetching: Bool { get set }
}

final class FeedOfTheMonthViewModel: FeedOfTheMonthViewModelProtocol {
    
    var targetDate: Date
    var fetchFeedUseCase: FetchFeedUseCase
    var feedOfTheMonthSubject: CurrentValueSubject<[PetpionFeed], Never> = .init([])
    var isFirstFetching: Bool = true
    
    init(targetDate: Date,
         fetchFeedUseCase: FetchFeedUseCase) {
        self.targetDate = targetDate
        self.fetchFeedUseCase = fetchFeedUseCase
    }
    
    // MARK: - Input
    func fetchFeedOfTheMonth(isFirst: Bool) {
        Task {
            let fetchedFeeds = await fetchFeedUseCase.fetchSpecificMonthFeeds(with: targetDate, isFirst: isFirst)
            guard fetchedFeeds.isEmpty == false else { return }
            await MainActor.run(body: {
                var resultFeed = feedOfTheMonthSubject.value
                resultFeed = resultFeed + fetchedFeeds
                feedOfTheMonthSubject.send(resultFeed)
            })
        }
    }
    
    // MARK: - Output
    func makeWaterfallLayoutConfiguration() -> UICollectionLayoutWaterfallConfiguration {
        return UICollectionLayoutWaterfallConfiguration(
            columnCount: 2,
            spacing: 5,
            contentInsetsReference: UIContentInsetsReference.automatic) { [self] indexPath in
                feedOfTheMonthSubject.value[indexPath.row].feedSize
            }
    }
    
    func makePetFeedCollectionViewDataSource(collectionView: UICollectionView, listener: PetFeedCollectionViewCellListener) -> UICollectionViewDiffableDataSource<Int, PetpionFeed> {
        let registration = makePetFeedCollectionViewCellRegistration(listener: listener)
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func makePetFeedCollectionViewCellRegistration(listener: PetFeedCollectionViewCellListener) -> UICollectionView.CellRegistration<PetFeedCollectionViewCell, PetpionFeed> {
        UICollectionView.CellRegistration { [weak self] cell, indexPath, item in
            guard let viewModel = self?.makeViewModel(for: item) else { return }
            cell.configure(with: viewModel)
            cell.listener = listener
        }
    }
    
    private func makeViewModel(for item: PetpionFeed) -> PetFeedCollectionViewCell.ViewModel {
        return PetFeedCollectionViewCell.ViewModel(petpionFeed: item)
    }
}
