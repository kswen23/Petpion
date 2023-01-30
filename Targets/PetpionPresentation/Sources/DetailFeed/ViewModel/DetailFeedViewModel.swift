//
//  DetailFeedViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/13.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionDomain

protocol DetailFeedViewModelInput {
    var currentPageChangedByPageControl: Bool { get }
    func pageControlValueChanged(_ count: Int)
    func collectionViewDidScrolled()
}

protocol DetailFeedViewModelOutput {
    func configureDetailFeedImageCollectionViewLayout() -> UICollectionViewLayout
    func makeDetailFeedImageCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, URL>
    func getWinRate() -> Double
}

protocol DetailFeedViewModelProtocol: DetailFeedViewModelInput, DetailFeedViewModelOutput {
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var feed: PetpionFeed { get }
    var urlSubject: CurrentValueSubject<[URL], Never> { get }
    var currentPageSubject: CurrentValueSubject<Int, Never> { get }
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<Int, URL>,Publishers.Map<PassthroughSubject<[URL], Never>,NSDiffableDataSourceSnapshot<Int, URL>>.Failure> { get }
}

final class DetailFeedViewModel: DetailFeedViewModelProtocol {
    
    let fetchFeedUseCase: FetchFeedUseCase
    var feed: PetpionFeed
    
    lazy var urlSubject: CurrentValueSubject<[URL], Never> = .init([self.feed.imageURLArr![0]])
    // no data일시 
//    lazy var urlSubject: CurrentValueSubject<[URL], Never> = .init([])
    let currentPageSubject: CurrentValueSubject<Int, Never> = .init(0)
    var currentPageChangedByPageControl = false
    lazy var snapshotSubject = urlSubject.map { items -> NSDiffableDataSourceSnapshot<Int, URL> in
        var snapshot = NSDiffableDataSourceSnapshot<Int, URL>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        return snapshot
    }.eraseToAnyPublisher()
    private var currentPage: Int = 0
    
    // MARK: - Initialize
    init(feed: PetpionFeed, fetchFeedUseCase: FetchFeedUseCase) {
        self.feed = feed
        self.fetchFeedUseCase = fetchFeedUseCase
        fetchFeedImages()
    }
    
    func fetchFeedImages() {
        Task {
            guard let thumbnailImage = feed.imageURLArr?[0] else { return }
            var detailImages = await fetchFeedUseCase.fetchFeedDetailImages(feed: feed)
            detailImages.insert(thumbnailImage, at: 0)
            await MainActor.run { [detailImages] in
                urlSubject.send(detailImages)
            }
        }
    }
    // MARK: - Input
    
    func pageControlValueChanged(_ count: Int) {
        currentPageChangedByPageControl = true
        currentPageSubject.send(count)
    }
    
    func collectionViewDidScrolled() {
        currentPageChangedByPageControl = false
    }
    // MARK: - Output
    func configureDetailFeedImageCollectionViewLayout() -> UICollectionViewLayout {
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
            if self?.currentPageChangedByPageControl == false {
                let changingPage = Int(max(0, round(point.x / environment.container.contentSize.width)))
                guard changingPage != self?.currentPage else { return }
                self?.currentPageSubject.send(changingPage)
                self?.currentPage = changingPage
            }
            self?.collectionViewDidScrolled()
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func makeDetailFeedImageCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, URL> {
        let cellRegistration = makeCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                         for: indexPath,
                                                         item: itemIdentifier)
        }
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<DetailFeedImageCollection, URL> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            cell.configureDetailImageView(item)
        }
    }
    
    func getWinRate() -> Double {
        let winRate = ((Double(feed.likeCount)/Double(feed.battleCount))*100).roundDecimal(to: 1)
        return winRate.isNaN ? 0 : winRate
    }
}
