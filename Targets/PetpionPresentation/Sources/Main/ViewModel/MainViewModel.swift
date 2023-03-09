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
    func initializeEssentialAppData()
    func fetchInit() async
    func fetchNextFeed()
    func refetchFeeds()
    func sortingOptionWillChange(with option: SortingOption)
    func sortingOptionDidChanged()
    func baseCollectionViewDidScrolled(to index: Int)
    func updateCurrentFeeds()
    func userDidUpdated(to updatedUser: User)
}

protocol MainViewModelOutput {
    var baseCollectionViewNeedToScroll: Bool { get }
    func configureBaseCollectionViewLayout() -> UICollectionViewLayout
    func makeBaseCollectionViewDataSource(parentViewController: UIViewController,
                                          collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<MainViewModel.Section, SortingOption>
}

protocol MainViewModelProtocol: MainViewModelInput, MainViewModelOutput {
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var fetchUserUseCase: FetchUserUseCase { get }
    var calculateVoteChanceUseCase: CalculateVoteChanceUseCase { get }
    var checkPreviousMonthRanking: CheckPreviousMonthRankingUseCase { get }
    var reportUseCase: ReportUseCase { get }
    var blockUseCase: BlockUseCase { get }
    var firstFetchLoading: PassthroughSubject<Bool, Never> { get }
    var sortingOptionSubject: CurrentValueSubject<SortingOption, Never> { get }
    var popularFeedSubject: CurrentValueSubject<[PetpionFeed], Never> { get }
    var latestFeedSubject: CurrentValueSubject<[PetpionFeed], Never> { get }
    var isFirstFetching: Bool { get set }
    var willRefresh: Bool { get set }
}

final class MainViewModel: MainViewModelProtocol {
    
    enum Section {
        case base
    }
    
    var baseCollectionViewNeedToScroll: Bool = true
    let firstFetchLoading: PassthroughSubject<Bool, Never> = .init()
    let popularFeedSubject: CurrentValueSubject<[PetpionFeed], Never> = .init([.empty])
    let latestFeedSubject: CurrentValueSubject<[PetpionFeed], Never> = .init([.empty])
    let sortingOptionSubject: CurrentValueSubject<SortingOption, Never> = .init(.latest)
    var isFirstFetching: Bool = true
    var willRefresh: Bool = false
    
    // MARK: - Initialize
    let fetchFeedUseCase: FetchFeedUseCase
    let fetchUserUseCase: FetchUserUseCase
    let calculateVoteChanceUseCase: CalculateVoteChanceUseCase
    let checkPreviousMonthRanking: CheckPreviousMonthRankingUseCase
    let reportUseCase: ReportUseCase
    let blockUseCase: BlockUseCase
    
    init(fetchFeedUseCase: FetchFeedUseCase,
         fetchUserUseCase: FetchUserUseCase,
         calculateVoteChanceUseCase: CalculateVoteChanceUseCase,
         checkPreviousMonthRanking: CheckPreviousMonthRankingUseCase,
         reportUseCase: ReportUseCase,
         blockUseCase: BlockUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
        self.fetchUserUseCase = fetchUserUseCase
        self.calculateVoteChanceUseCase = calculateVoteChanceUseCase
        self.checkPreviousMonthRanking = checkPreviousMonthRanking
        self.reportUseCase = reportUseCase
        self.blockUseCase = blockUseCase
    }
    
    func fetchInit() async {
        let initialFeed = await fetchFeedUseCase.fetchInitialFeedPerSortingOption()
        await MainActor.run {
            if isFirstFetching {
                firstFetchLoading.send(true)
            }
            latestFeedSubject.send(initialFeed[SortingOption.latest.rawValue])
            popularFeedSubject.send(initialFeed[SortingOption.popular.rawValue])
            isFirstFetching = false
        }
    }
    
    func initializeEssentialAppData() {
        Task {
            await checkPreviousMonthRanking.checkPreviousMonthRankingDidUpdated()
            guard let uid = UserDefaults.standard.string(forKey: UserInfoKey.firebaseUID.rawValue) else {
                return await fetchInit()
            }
            let fetchedUser = await fetchUserUseCase.fetchUser(uid: uid)
            User.currentUser = fetchedUser
            await initializeUserActionData()
            await fetchInit()
            await fetchBlockedUser()
            if await calculateVoteChanceUseCase.initializeUserVoteChance(user: fetchedUser) {
                fetchUserUseCase.bindUser { fetchedUser in
                    User.currentUser = fetchedUser
                }
            }
        }
    }
    
    private func initializeUserActionData() async {
        User.reportedUserIDArray = await reportUseCase.getReportedArray(type: .user)
        User.reportedFeedIDArray = await reportUseCase.getReportedArray(type: .feed)
        User.blockedUserIDArray = await blockUseCase.getBlockedArray(type: .user)
        User.blockedFeedIDArray = await blockUseCase.getBlockedArray(type: .feed)
    }
    
    private func fetchBlockedUser() async {
        guard let blockedUserIDArray = User.blockedUserIDArray else { return }
        User.blockedUserArray = await fetchUserUseCase.fetchBlockedUser(with: blockedUserIDArray)
    }
    
    
    // MARK: - Input
    func refetchFeeds() {
        Task {
            let refreshedLatestFeed = await fetchFeedUseCase.fetchFeed(isFirst: true, option: .latest)
            let refreshedPopularFeed = await fetchFeedUseCase.fetchFeed(isFirst: true, option: .popular)
            await MainActor.run {
                latestFeedSubject.send(refreshedLatestFeed)
                popularFeedSubject.send(refreshedPopularFeed)
            }
            willRefresh = false
        }
    }
    
    func updateFeedSubject(origin: [PetpionFeed]) -> [PetpionFeed] {
        var resultFeedArray = origin
        for i in 0 ..< resultFeedArray.count {
            if resultFeedArray[i].uploaderID == User.currentUser?.id {
                resultFeedArray[i].uploader = User.currentUser!
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
        User.currentUser?.nickname = updatedUser.nickname
        User.currentUser?.profileImage = updatedUser.profileImage
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
    
    func makeBaseCollectionViewDataSource(parentViewController: UIViewController,
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
    
    private func makeBaseCollectionViewCellRegistration(parentViewController: UIViewController) -> UICollectionView.CellRegistration<BaseCollectionViewCell, SortingOption> {
        UICollectionView.CellRegistration { [weak self] cell, indexPath, item in
            cell.parentViewController = parentViewController as? any BaseCollectionViewCellDelegation
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
