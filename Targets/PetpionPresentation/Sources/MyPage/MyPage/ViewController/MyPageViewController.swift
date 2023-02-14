//
//  MyPageViewController.swift
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
import Lottie

final class MyPageViewController: HasCoordinatorViewController {
    
    private var cancellables = Set<AnyCancellable>()

    lazy var myPageCoordinator: MyPageCoordinator? = {
        return coordinator as? MyPageCoordinator
    }()
    private let viewModel: MyPageViewModelProtocol
    
    private lazy var userFeedsCollectionView: UICollectionView = {
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: viewModel.configureUserFeedsCollectionViewLayout())
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    private lazy var userFeedsCollectionViewDataSource: UICollectionViewDiffableDataSource<Int, PetpionFeed> = viewModel.makeUserFeedsCollectionViewDataSource(collectionView: userFeedsCollectionView)
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        return refreshControl
    }()
    
    @objc private func refreshCollectionView() {
        viewModel.fetchUserTotalFeeds()
    }
    
    private let lazyCatAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: LottieJson.lazyCat)
        animationView.loopMode = .loop
        return animationView
    }()
    
    private let emptyFeedLabel: UILabel = {
        let label = UILabel()
        label.text = "게시물이 없습니다."
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    // MARK: - Initialize
    init(viewModel: MyPageViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        addObserver()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver()
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "내 정보"
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutUserFeedsCollectionView()
        layoutEmptyFeedLabel()
        layoutLazyCatAnimationView()
    }
    
    private func layoutUserFeedsCollectionView() {
        view.addSubview(userFeedsCollectionView)
        userFeedsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userFeedsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            userFeedsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userFeedsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userFeedsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        userFeedsCollectionView.showsVerticalScrollIndicator = false
    }
    
    private func layoutEmptyFeedLabel() {
        userFeedsCollectionView.addSubview(emptyFeedLabel)
        emptyFeedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyFeedLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            emptyFeedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        emptyFeedLabel.isHidden = true
    }
    
    private func layoutLazyCatAnimationView() {
        userFeedsCollectionView.addSubview(lazyCatAnimationView)
        lazyCatAnimationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lazyCatAnimationView.bottomAnchor.constraint(equalTo: emptyFeedLabel.topAnchor),
            lazyCatAnimationView.centerXAnchor.constraint(equalTo: userFeedsCollectionView.centerXAnchor),
            lazyCatAnimationView.heightAnchor.constraint(equalToConstant: 300),
            lazyCatAnimationView.widthAnchor.constraint(equalToConstant: 300)
        ])
        lazyCatAnimationView.isHidden = true
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationItem()
    }
    
    private func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(settingButtonDidTapped))
    }
    
    @objc private func settingButtonDidTapped() {
        myPageCoordinator?.pushSettingViewController()
    }
    
    private func configureUserFeedsCollectionViewHeader(with user: User) {
        guard let headerView = userFeedsCollectionView.supplementaryView(forElementKind: UserCardCollectionReusableView.identifier, at: IndexPath.init(item: 0, section: 0)) as? UserCardCollectionReusableView else { return }
        headerView.configureUserCardView(with: user)
    }
    
    // MARK: - Binding
    private func binding() {
        bindSnapshotSubject()
    }
    
    private func bindSnapshotSubject() {
        viewModel.snapshotSubject.sink { [weak self] snapshot in
            guard let isRefreshing = self?.userFeedsCollectionView.refreshControl?.isRefreshing else { return }
            if isRefreshing {
                self?.userFeedsCollectionView.refreshControl?.endRefreshing()
            }
            
            if snapshot.numberOfItems(inSection: 0) == 0 {
                self?.emptyFeedLabel.isHidden = false
                self?.lazyCatAnimationView.isHidden = false
                self?.lazyCatAnimationView.play()
            } else {
                self?.lazyCatAnimationView.stop()
                self?.emptyFeedLabel.isHidden = true
                self?.lazyCatAnimationView.isHidden = true
            }
            
            self?.userFeedsCollectionViewDataSource.apply(snapshot)
        }.store(in: &cancellables)
    }
}

extension MyPageViewController: NotificationObservable {
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserProfileDidChange), name: Notification.Name(NotificationName.profileUpdated), object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName.profileUpdated), object: nil)
    }
    
    @objc func handleUserProfileDidChange(notification: Notification) {
        guard let updatedUserProfile = notification.userInfo?["profile"] as? User else { return }
        viewModel.userDidUpdated(to: updatedUserProfile)
        configureUserFeedsCollectionViewHeader(with: updatedUserProfile)
    }
    
}

extension MyPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFeed = viewModel.userFeedSubject.value[indexPath.item]
        myPageCoordinator?.pushDetailFeedViewController(selected: selectedFeed)
    }
}
