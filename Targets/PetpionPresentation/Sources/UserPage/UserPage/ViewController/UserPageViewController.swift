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

final class UserPageViewController: HasCoordinatorViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    lazy var userPageCoordinator: UserPageCoordinator? = {
        return coordinator as? UserPageCoordinator
    }()
    private let viewModel: UserPageViewModelProtocol
    
    private lazy var userFeedsCollectionView: UICollectionView = {
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: viewModel.configureUserFeedsCollectionViewLayout())
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    private lazy var userFeedsCollectionViewDataSource: UICollectionViewDiffableDataSource<Int, PetpionFeed> = viewModel.makeUserFeedsCollectionViewDataSource(collectionView: userFeedsCollectionView)
    
    private var settingBarButton: UIBarButtonItem?
    private var ellipsisBarButton: UIBarButtonItem?
    
    private var userAlertController: UIAlertController?
    
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
    
    private let toastAnimationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = .black
        label.textAlignment = .center
        label.textColor = .white
        label.alpha = 0.9
        label.isHidden = true
        return label
    }()
    private let toastAnimationLabelHeightConstant: CGFloat = 40
    private lazy var toastAnimationLabelTopAnchor: NSLayoutConstraint? = toastAnimationLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: toastAnimationLabelHeightConstant)
    
    // MARK: - Initialize
    init(viewModel: UserPageViewModelProtocol) {
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
        configureNavigationTitle()
        viewModel.fetchUserTotalFeeds()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        binding()
        configureNavigationItem()
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
    
    private func layoutToastAnimationLabel() {
        userFeedsCollectionView.addSubview(toastAnimationLabel)
        NSLayoutConstraint.activate([
            toastAnimationLabel.centerXAnchor.constraint(equalTo: userFeedsCollectionView.centerXAnchor),
            toastAnimationLabel.widthAnchor.constraint(equalToConstant: view.frame.width*0.7),
            toastAnimationLabel.heightAnchor.constraint(equalToConstant: toastAnimationLabelHeightConstant)
        ])
        toastAnimationLabelTopAnchor?.isActive = true
        toastAnimationLabel.roundCorners(cornerRadius: 15)
    }
    
    // MARK: - Configure
    private func configureNavigationTitle() {
        switch viewModel.userPageStyle {
        case .myPageWithSettings:
            self.navigationItem.title = "내 정보"
        case .myPageWithOutSettings:
            self.navigationItem.title = viewModel.user.nickname
        case .otherUserPage:
            self.navigationItem.title = viewModel.user.nickname
        }
    }
    private func configureNavigationItem() {
        switch viewModel.userPageStyle {
        case .myPageWithSettings:
            configureMyPageWithSettings()
        case .myPageWithOutSettings:
            navigationItem.rightBarButtonItem = nil
        case .otherUserPage:
            layoutToastAnimationLabel()
            configureEllipsisBarButton()
            configureUserAlertViewController()
            bindBlockUserStateSubject()
        }
    }
    
    private func configureMyPageWithSettings() {
        settingBarButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(settingButtonDidTapped))
        if let settingBarButton = settingBarButton {
            settingBarButton.tintColor = .black
            navigationItem.rightBarButtonItem = settingBarButton
        }
    }
    
    @objc private func settingButtonDidTapped() {
        userPageCoordinator?.pushSettingViewController()
    }
    
    private func configureEllipsisBarButton() {
        ellipsisBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(ellipsisButtonDidTapped))
        if let ellipsisBarButton = ellipsisBarButton {
            ellipsisBarButton.tintColor = .black
            navigationItem.rightBarButtonItem = ellipsisBarButton
        }
    }
    
    @objc func ellipsisButtonDidTapped() {
        guard let userAlertController = userAlertController else { return }
        present(userAlertController, animated: true)
    }
    
    private func configureUserAlertViewController() {
        userAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let userAlertController = userAlertController {
            
            let blockUser = UIAlertAction(title: "유저 차단", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                if User.isBlockedUser(user: strongSelf.viewModel.user) {
                    self?.configureToastAnimationLabel(actionType: .block)
                    self?.startToastLabelAnimation()
                } else {
                    self?.viewModel.blockUser()
                }
            })
            let reportUser = UIAlertAction(title: "유저 신고", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                if User.isReportedUser(user: strongSelf.viewModel.user) {
                    self?.configureToastAnimationLabel(actionType: .report)
                    self?.startToastLabelAnimation()
                } else {
                    self?.userPageCoordinator?.presentReportUserViewController()
                }
            })
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            
            [blockUser, reportUser, cancel].forEach { userAlertController.addAction($0) }
        }
    }
    
    private func configureUserFeedsCollectionViewHeader(with user: User) {
        guard let headerView = userFeedsCollectionView.supplementaryView(forElementKind: UserCardCollectionReusableView.identifier, at: IndexPath.init(item: 0, section: 0)) as? UserCardCollectionReusableView else { return }
        headerView.configureUserCardView(with: user)
    }
    
    private func configureToastAnimationLabel(actionType: UserActionType) {
        switch actionType {
        case .block:
            toastAnimationLabel.text = "이미 차단한 유저입니다."
        case .report:
            toastAnimationLabel.text = "이미 신고한 유저입니다."
        }
    }
    
    private func startToastLabelAnimation() {
        toastAnimationLabel.isHidden = false
        toastAnimationLabelTopAnchor?.isActive = false
        toastAnimationLabelTopAnchor = toastAnimationLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -(toastAnimationLabelHeightConstant*2))
        toastAnimationLabelTopAnchor?.isActive = true
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.popToastLabelAnimation()
        })
    }
    
    private func popToastLabelAnimation() {
        toastAnimationLabelTopAnchor?.isActive = false
        toastAnimationLabelTopAnchor = toastAnimationLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: toastAnimationLabelHeightConstant)
        toastAnimationLabelTopAnchor?.isActive = true
        UIView.animate(withDuration: 0.5,
                       delay: 2.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.toastAnimationLabel.isHidden = true
        })
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
    
    private func bindBlockUserStateSubject() {
        viewModel.blockUserStateSubject.sink { [weak self] blockState in
            guard let userNickname = self?.viewModel.user.nickname else { return }
            switch blockState {
            case .done:
                self?.toastAnimationLabel.text = "\(userNickname) 님을 차단했습니다."
                self?.startToastLabelAnimation()
            case .error:
                self?.toastAnimationLabel.text = "에러가 발생했습니다."
                self?.startToastLabelAnimation()
            }
        }.store(in: &cancellables)
    }
}

extension UserPageViewController: NotificationObservable {
    
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

extension UserPageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFeed = viewModel.userFeedSubject.value[indexPath.item]
        var detailFeedStyle: DetailFeedStyle!
        switch viewModel.userPageStyle {
        case .myPageWithSettings:
            detailFeedStyle = .editableUserDetailFeed
        case .myPageWithOutSettings:
            detailFeedStyle = .uneditableUserDetailFeed
        case .otherUserPage:
            detailFeedStyle = .otherUserDetailFeed
        }
        userPageCoordinator?.pushDetailFeedViewController(selected: selectedFeed, detailFeedStyle: detailFeedStyle)
    }
}
