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
    func fetchInit()
    func fetchNextFeed()
    func refreshCurrentFeed()
    func sortingOptionWillChange(with option: SortingOption)
    func sortingOptionDidChanged()
    func baseCollectionViewDidScrolled(to index: Int)
    func updateCurrentFeeds()
    func userDidUpdated(to updatedUser: User)
}

protocol MainViewModelOutput {
    var baseCollectionViewNeedToScroll: Bool { get }
    func configureBaseCollectionViewLayout() -> UICollectionViewLayout
    func makeBaseCollectionViewDataSource(parentViewController: BaseCollectionViewCellDelegation,
                                          collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<MainViewModel.Section, SortingOption>
}

protocol MainViewModelProtocol: MainViewModelInput, MainViewModelOutput {
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var fetchUserUseCase: FetchUserUseCase { get }
    var calculateVoteChanceUseCase: CalculateVoteChanceUseCase { get }
    var user: User { get }
    var sortingOptionSubject: CurrentValueSubject<SortingOption, Never> { get }
    var popularFeedSubject: CurrentValueSubject<[PetpionFeed], Never> { get }
    var latestFeedSubject: CurrentValueSubject<[PetpionFeed], Never> { get }
    var isFirstFetching: Bool { get }
}

final class MainViewModel: MainViewModelProtocol {
    
    enum Section {
        case base
    }
    
    var baseCollectionViewNeedToScroll: Bool = true
    let popularFeedSubject: CurrentValueSubject<[PetpionFeed], Never> = .init([.empty])
    let latestFeedSubject: CurrentValueSubject<[PetpionFeed], Never> = .init([.empty])
    let sortingOptionSubject: CurrentValueSubject<SortingOption, Never> = .init(.latest)
    var isFirstFetching: Bool = true
    var user: User = .empty
    
    // MARK: - Initialize
    let fetchFeedUseCase: FetchFeedUseCase
    let fetchUserUseCase: FetchUserUseCase
    let calculateVoteChanceUseCase: CalculateVoteChanceUseCase
    
    init(fetchFeedUseCase: FetchFeedUseCase,
         fetchUserUseCase: FetchUserUseCase,
         calculateVoteChanceUseCase: CalculateVoteChanceUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
        self.fetchUserUseCase = fetchUserUseCase
        self.calculateVoteChanceUseCase = calculateVoteChanceUseCase
        initializeUserVoteChance()
    }
    
    func fetchInit() {
        Task {
            let initialFeed = await fetchFeedUseCase.fetchInitialFeedPerSortingOption()
            await MainActor.run {
                latestFeedSubject.send(initialFeed[SortingOption.latest.rawValue])
                popularFeedSubject.send(initialFeed[SortingOption.popular.rawValue])
                isFirstFetching = false
            }
        }
    }
    
    private func initializeUserVoteChance() {
        Task {
            guard let uid = UserDefaults.standard.string(forKey: UserInfoKey.firebaseUID.rawValue) else { return }
            let fetchedUser = await fetchUserUseCase.fetchUser(uid: uid)
            let initUserInfoResult = await calculateVoteChanceUseCase.initializeUserVoteChance(user: fetchedUser)
            self.user = fetchedUser
            
            // voteMain 에서 언제만 바뀌는게 필요한지 체크후 notification으로 처리
            if initUserInfoResult {
                fetchUserUseCase.bindUser { [weak self] fetchedUser in
                    self?.user.nickname = fetchedUser.nickname
                    self?.user.voteChanceCount = fetchedUser.voteChanceCount
                    self?.user.latestVoteTime = fetchedUser.latestVoteTime
                }
            }
        }
    }

    // MARK: - Input
    func refreshCurrentFeed() {
        let currentOption = sortingOptionSubject.value
        Task {
            let refreshedFeed = await fetchFeedUseCase.fetchFeed(isFirst: true, option: currentOption)
            await MainActor.run {
                switch currentOption {
                case .latest:
                    latestFeedSubject.send(refreshedFeed)
                case .popular:
                    popularFeedSubject.send(refreshedFeed)
                }
            }
        }
    }
    
    func updateFeedSubject(origin: [PetpionFeed]) -> [PetpionFeed] {
        var resultFeedArray = origin
        for i in 0 ..< resultFeedArray.count {
            if resultFeedArray[i].uploaderID == user.id {
                resultFeedArray[i].uploader = user
            }
        }
        return resultFeedArray
    }
    
    func fetchNextFeed() {
        Task {
            var resultFeed = getCurrentFeed()
            let fetchedFeed = await fetchFeedUseCase.fetchFeed(isFirst: false,
                                                               option: sortingOptionSubject.value)
            guard fetchedFeed.count != 0 else { return }
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
            sortingOptionSubject.send(.latest)
        case 1:
            sortingOptionSubject.send(.popular)
        default: break
        }
    }
     
    func updateCurrentFeeds() {
        Task {
            let popularFeeds = await fetchFeedUseCase.updateFeeds(origin: popularFeedSubject.value)
            let latestFeeds = await fetchFeedUseCase.updateFeeds(origin: latestFeedSubject.value)
            
            await MainActor.run { [popularFeeds, latestFeeds] in
                popularFeedSubject.send(popularFeeds)
                latestFeedSubject.send(latestFeeds)
            }
        }
    }
    
    func userDidUpdated(to updatedUser: User) {
        user.nickname = updatedUser.nickname
        user.profileImage = updatedUser.profileImage
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
    
    func makeBaseCollectionViewDataSource(parentViewController: BaseCollectionViewCellDelegation,
                                          collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<MainViewModel.Section, SortingOption> {
        let registration = makeBaseCollectionViewCellRegistration(parentViewController: parentViewController)
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func makeBaseCollectionViewCellRegistration(parentViewController: BaseCollectionViewCellDelegation) -> UICollectionView.CellRegistration<BaseCollectionViewCell, SortingOption> {
        UICollectionView.CellRegistration { [weak self] cell, indexPath, item in
            cell.parentViewController = parentViewController
            cell.viewModel = self?.makeChildViewModel(item: item)
            cell.bindSnapshot()
        }
    }
    
    private func makeChildViewModel(item: SortingOption) -> BaseViewModel {
        let baseViewModel = BaseViewModel()
        switch item {
        case .popular:
            baseViewModel.petpionFeedSubject = self.popularFeedSubject
        case .latest:
            baseViewModel.petpionFeedSubject = self.latestFeedSubject
        }
        return baseViewModel
    }
    
}
