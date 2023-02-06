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
    func userDidUpdated(to updatedUser: User)
}

protocol MyPageViewModelOutput {
    func configureUserFeedsCollectionViewLayout() -> UICollectionViewLayout
    func makeUserFeedsCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, PetpionFeed>
}

protocol MyPageViewModelProtocol: MyPageViewModelInput, MyPageViewModelOutput {
    var user: User { get }
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var userFeedThumbnailSubject: CurrentValueSubject<[PetpionFeed], Never> { get }
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<Int, PetpionFeed>,Publishers.Map<PassthroughSubject<[PetpionFeed], Never>,NSDiffableDataSourceSnapshot<Int, PetpionFeed>>.Failure> { get }
}

final class MyPageViewModel: MyPageViewModelProtocol {
    
    var user: User
    let fetchFeedUseCase: FetchFeedUseCase
    
    lazy var userFeedThumbnailSubject: CurrentValueSubject<[PetpionFeed], Never> = {
        var petpionArr = [PetpionFeed]()
        for i in 0 ..< 12 {
            var petpionFeed: PetpionFeed = .empty
            petpionFeed.id = UUID().uuidString
            petpionArr.append(petpionFeed)
        }
        return .init(petpionArr)
    }()
    
    lazy var snapshotSubject = userFeedThumbnailSubject.map { items -> NSDiffableDataSourceSnapshot<Int, PetpionFeed> in
        var snapshot = NSDiffableDataSourceSnapshot<Int, PetpionFeed>()
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
                userFeedThumbnailSubject.send(userFeeds)
            }
        }
    }

    // MARK: - Input
    func userDidUpdated(to updatedUser: User) {
        self.user = updatedUser
    }
    
    // MARK: - Output
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
    
    func makeUserFeedsCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, PetpionFeed> {
        var dataSource: UICollectionViewDiffableDataSource<Int, PetpionFeed>! = nil
        let cellRegistration = makeCellRegistration()
        let headerRegistration = makeCellHeaderRegistration()
        dataSource = UICollectionViewDiffableDataSource<Int, PetpionFeed>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: PetpionFeed) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: index)
        }
        return dataSource
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<UserFeedsCollectionViewCell, PetpionFeed> {
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
