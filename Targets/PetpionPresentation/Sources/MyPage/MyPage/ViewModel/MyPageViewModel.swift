//
//  MyPageViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionCore
import PetpionDomain

protocol MyPageViewModelInput {
    
}

protocol MyPageViewModelOutput {
    func configureUserFeedsCollectionViewLayout() -> UICollectionViewLayout
    func makeUserFeedsCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, URL>
}

protocol MyPageViewModelProtocol: MyPageViewModelInput, MyPageViewModelOutput {
    var user: User { get }
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var userFeedThumbnailSubject: CurrentValueSubject<[URL], Never> { get }
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<Int, URL>,Publishers.Map<PassthroughSubject<[URL], Never>,NSDiffableDataSourceSnapshot<Int, URL>>.Failure> { get }
}

final class MyPageViewModel: MyPageViewModelProtocol {
    
    let user: User
    let fetchFeedUseCase: FetchFeedUseCase
    lazy var userFeedThumbnailSubject: CurrentValueSubject<[URL], Never> = {
        var tempURLArr = [URL]()
        for i in 0 ..< 12 {
            tempURLArr.append(URL.init(string: "www" + "\(i)")!)
        }
        return .init(tempURLArr)
    }()
    
    lazy var snapshotSubject = userFeedThumbnailSubject.map { items -> NSDiffableDataSourceSnapshot<Int, URL> in
        var snapshot = NSDiffableDataSourceSnapshot<Int, URL>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        return snapshot
    }.eraseToAnyPublisher()
    
    // MARK: - Initialize
    init(user: User,
         fetchFeedUseCase: FetchFeedUseCase) {
        self.user = user
        self.fetchFeedUseCase = fetchFeedUseCase
        fetchUserTotalFeeds()
    }
    
    private func fetchUserTotalFeeds() {
        Task {
            var userFeeds = await fetchFeedUseCase.fetchUserTotalFeeds(user: user)
            userFeeds.sort { $0.uploadDate > $1.uploadDate }
            
            await MainActor.run { [userFeeds] in
                userFeedThumbnailSubject.send(userFeeds.map { $0.imageURLArr![0] })
            }
        }
    }
    
    // MARK: - Input
    
    // MARK: - Output
    func loadUserProfileImage() async -> UIImage  {
        guard let profileURL = user.imageURL else { return .init() }
            return await ImageCache.shared.loadImage(url: profileURL as NSURL)
    }
    
    func configureUserFeedsCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                              heightDimension: .fractionalWidth(1/3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets.init(top: 0.2, leading: 0.2, bottom: 0.2, trailing: 0.2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        let cardViewHeight: CGFloat = (UIScreen.main.bounds.size.width - 40) * 0.56
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .estimated(cardViewHeight + 50))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UserCardCollectionReusableView.identifier,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func makeUserFeedsCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, URL> {
        var dataSource: UICollectionViewDiffableDataSource<Int, URL>! = nil
        let cellRegistration = makeCellRegistration()
        let headerRegistration = makeCellHeaderRegistration()
        dataSource = UICollectionViewDiffableDataSource<Int, URL>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: URL) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: index)
        }
        return dataSource
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<UserFeedsCollectionViewCell, URL> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            cell.configureThumbnailImageView(item)
        }
    }
    
    private func makeCellHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UserCardCollectionReusableView> {
        return UICollectionView.SupplementaryRegistration
        <UserCardCollectionReusableView>(elementKind: UserCardCollectionReusableView.identifier) {
            [weak self] (supplementaryView, string, indexPath) in
            guard let strongSelf = self else { return }
            supplementaryView.configureUserCardView(with: strongSelf.user)
        }
    }


}
