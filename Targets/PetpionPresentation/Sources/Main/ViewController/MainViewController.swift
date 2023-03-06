//
//  MainViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import UIKit

import Lottie
import PetpionCore
import PetpionDomain

enum NavigationItemType: String, CaseIterable {
    case myPage = "person"
    case uploadFeed = "camera"
    case vote = "crown"
}

final class MainViewController: HasCoordinatorViewController {
        
    lazy var mainCoordinator: MainCoordinator? = {
        return coordinator as? MainCoordinator
    }()
    private var viewModel: MainViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    lazy var baseCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                             collectionViewLayout: UICollectionViewLayout())
    private lazy var popularBarButton = UIBarButtonItem(title: "#인기", style: .done, target: self, action: #selector(popularDidTapped))
    private lazy var latestBarButton = UIBarButtonItem(title: "#최신", style: .done, target: self, action: #selector(latestDidTapped))
    private lazy var baseCollectionViewDataSource = viewModel.makeBaseCollectionViewDataSource(parentViewController: self, collectionView: baseCollectionView)
    
    private let mainLoadingView: MainLoadingView = .init(frame: .zero)
    
    // MARK: - Initialize
    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .black
        configureNavigationItem()
        if viewModel.willRefresh == false {
            if viewModel.isFirstFetching {
                viewModel.initializeEssentialAppData()
            } else {
                viewModel.updateCurrentFeeds()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutBaseCollectionView()
        layoutMainLoadingView()
    }
    
    private func layoutBaseCollectionView() {
        view.addSubview(baseCollectionView)
        baseCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            baseCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            baseCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            baseCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        baseCollectionView.contentInsetAdjustmentBehavior = .never
        baseCollectionView.alwaysBounceVertical = false
    }
    
    
    private func layoutMainLoadingView() {
        view.addSubview(mainLoadingView)
        mainLoadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainLoadingView.topAnchor.constraint(equalTo: view.topAnchor),
            mainLoadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainLoadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainLoadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Configure
    private func configure() {
        configureBaseCollectionView()
    }
    
    private func configureNavigationItem() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItems = [latestBarButton, popularBarButton]
        navigationItem.rightBarButtonItems = NavigationItemType.allCases.map { makeNavigationBarButtonItem(type: $0) }
    }
    
    private func configureBaseCollectionView() {
        baseCollectionView.setCollectionViewLayout(viewModel.configureBaseCollectionViewLayout(), animated: true)
        var snapshot = NSDiffableDataSourceSnapshot<MainViewModel.Section, SortingOption>()
        snapshot.appendSections([.base])
        snapshot.appendItems(SortingOption.allCases)
        baseCollectionViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureLeftBarButton(with option: SortingOption) {
        let font = UIFont.systemFont(ofSize: 27, weight: .heavy)
        switch option {
            
        case .popular:
            popularBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .normal)
            popularBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .highlighted)
            latestBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
            latestBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .highlighted)

        case .latest:
            popularBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
            popularBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .highlighted)
            latestBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .normal)
            latestBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .highlighted)
        }
    }
    
    private func makeNavigationBarButtonItem(type: NavigationItemType) -> UIBarButtonItem {
        var barButton = UIBarButtonItem()
        switch type {
        case .vote:
            barButton = UIBarButtonItem(image: UIImage(systemName: type.rawValue), style: .done, target: self, action: #selector(crownButtonDidTapped))
        case .uploadFeed:
            barButton = UIBarButtonItem(image: UIImage(systemName: type.rawValue), style: .done, target: self, action: #selector(cameraButtonDidTapped))
        case .myPage:
            barButton = UIBarButtonItem(image: UIImage(systemName: type.rawValue), style: .done, target: self, action: #selector(personButtonDidTapped))
        }
        return barButton
    }
    
    @objc private func popularDidTapped() {
        viewModel.sortingOptionWillChange(with: .popular)
    }
    
    @objc private func latestDidTapped() {
        viewModel.sortingOptionWillChange(with: .latest)
    }
    
    @objc private func cameraButtonDidTapped() {
        mainCoordinator?.presentFeedImagePicker()
    }
    
    @objc private func personButtonDidTapped() {
        mainCoordinator?.pushUserPageView(user: User.currentUser,
                                          userPageStyle: .myPageWithSettings)
    }
    
    @objc private func crownButtonDidTapped() {
        mainCoordinator?.pushVoteMainView()
    }
    
    // MARK: - binding
    private func binding() {
        bindFirstFetchLoading()
        bindSortingOption()
    }
    
    private func bindFirstFetchLoading() {
        viewModel.firstFetchLoading.sink { [weak self] loadingFinish in
            guard let strongSelf = self else { return }
            if loadingFinish == true {
                strongSelf.mainLoadingView.isHidden = true
                strongSelf.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }.store(in: &cancellables)
    }
    
    private func bindSortingOption() {
        viewModel.sortingOptionSubject.sink { [weak self] sortingOption in
            self?.configureLeftBarButton(with: sortingOption)
            if self?.viewModel.baseCollectionViewNeedToScroll == false {
                self?.baseCollectionView.scrollToItem(at: IndexPath(item: sortingOption.rawValue, section: 0), at: [], animated: true)
                self?.viewModel.sortingOptionDidChanged()
            }
        }.store(in: &cancellables)
    }
}

extension MainViewController: BaseCollectionViewCellDelegation {

    func baseCollectionViewNeedNewFeed() {
        viewModel.fetchNextFeed()
    }
    
    func baseCollectionViewCellDidTapped(index: IndexPath, feed: PetpionFeed) {
        let baseCellIndexPath: IndexPath = .init(row: viewModel.sortingOptionSubject.value.rawValue, section: 0)
        let transitionDependency: FeedTransitionDependency = .init(baseCellIndexPath: baseCellIndexPath,
                                                                   feedCellIndexPath: index)
        mainCoordinator?.presentDetailFeed(transitionDependency: transitionDependency, feed: feed)
    }
    
    func refreshBaseCollectionView() {
        viewModel.refetchFeeds()
    }
    
    func profileStackViewDidTapped(with user: User) {
        if User.currentUser?.id == user.id {
            mainCoordinator?.pushUserPageView(user: user, userPageStyle: .myPageWithOutSettings)
        } else {
            mainCoordinator?.pushUserPageView(user: user, userPageStyle: .otherUserPage)
        }
        
    }
}

extension MainViewController: NotificationObservable {
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserProfileDidChange), name: Notification.Name(NotificationName.profileUpdated), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: Notification.Name(NotificationName.dataDidChange), object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName.profileUpdated), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName.dataDidChange), object: nil)
    }
    
    @objc func handleUserProfileDidChange(notification: Notification) {
        guard let updatedUserProfile = notification.userInfo?["profile"] as? User else { return }
        viewModel.userDidUpdated(to: updatedUserProfile)
    }
    
    @objc func updateData(notification: Notification) {
        guard let userInfo = notification.userInfo, let action = userInfo["action"] as? String else {
            return
        }
        
        switch action {
        case "refresh":
            viewModel.willRefresh = true
            viewModel.refetchFeeds()
        default:
            break
        }
    }

}
