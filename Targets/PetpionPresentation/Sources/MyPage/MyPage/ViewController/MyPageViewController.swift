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

import Lottie

final class MyPageViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: MyPageCoordinator?
    private let viewModel: MyPageViewModelProtocol
    
    private lazy var userFeedsCollectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: viewModel.configureUserFeedsCollectionViewLayout())
    private lazy var userFeedsCollectionViewDataSource: UICollectionViewDiffableDataSource<Int, URL> = viewModel.makeUserFeedsCollectionViewDataSource(collectionView: userFeedsCollectionView)
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "내 정보"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        binding()
        view.backgroundColor = .white
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
        coordinator?.pushSettingViewController()
    }
    
    // MARK: - Binding
    private func binding() {
        bindSnapshotSubject()
    }
    
    private func bindSnapshotSubject() {
        viewModel.snapshotSubject.sink { [weak self] snapshot in
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