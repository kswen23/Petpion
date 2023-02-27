//
//  BaseCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/05.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import UIKit

import Lottie
import PetpionDomain
import PetpionCore

protocol BaseCollectionViewCellDelegation: NSObject {
    func baseCollectionViewNeedNewFeed()
    func baseCollectionViewCellDidTapped(index: IndexPath, feed: PetpionFeed)
    func refreshBaseCollectionView()
    func profileStackViewDidTapped(with user: User)
}

class BaseCollectionViewCell: UICollectionViewCell {
    
    weak var parentViewController: BaseCollectionViewCellDelegation?
    var viewModel: BaseViewModelProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    lazy var petFeedCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.refreshControl = refreshControl
        collectionView.refreshControl?.beginRefreshing()
        return collectionView
    }()
    
    private lazy var petFeedDataSource: UICollectionViewDiffableDataSource<Int, PetpionFeed>? = self.viewModel?.makePetFeedCollectionViewDataSource(collectionView: petFeedCollectionView, listener: self)
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        return refreshControl
    }()
    
    @objc private func refreshCollectionView() {
        parentViewController?.refreshBaseCollectionView()
    }
    
    private let lazyCatAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: LottieJson.lazyCat)
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.isHidden = true
        return animationView
    }()
    
    private let emptyFeedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        layoutPetCollectionView()
        layoutEmptyView()
    }
    
    private func layoutPetCollectionView() {
        self.addSubview(petFeedCollectionView)
        petFeedCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            petFeedCollectionView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            petFeedCollectionView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            petFeedCollectionView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            petFeedCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        petFeedCollectionView.backgroundColor = .white
        petFeedCollectionView.showsVerticalScrollIndicator = false
    }
    
    private func layoutEmptyView() {
        [lazyCatAnimationView ,emptyFeedLabel].forEach { petFeedCollectionView.addSubview($0) }
        NSLayoutConstraint.activate([
            lazyCatAnimationView.centerYAnchor.constraint(equalTo: petFeedCollectionView.centerYAnchor, constant: -100),
            lazyCatAnimationView.centerXAnchor.constraint(equalTo: petFeedCollectionView.centerXAnchor),
            lazyCatAnimationView.heightAnchor.constraint(equalToConstant: 300),
            lazyCatAnimationView.widthAnchor.constraint(equalToConstant: 300),
            emptyFeedLabel.bottomAnchor.constraint(equalTo: lazyCatAnimationView.bottomAnchor, constant: 20),
            emptyFeedLabel.centerXAnchor.constraint(equalTo: petFeedCollectionView.centerXAnchor)
        ])
    }
    
    // MARK: - Configure
    private func configurePetCollectionView() {
        guard let config = viewModel?.makeWaterfallLayoutConfiguration() else { return }
        let waterfallLayout = UICollectionViewCompositionalLayout.makeWaterfallLayout(configuration: config)
        petFeedCollectionView.setCollectionViewLayout(waterfallLayout, animated: true)
        petFeedCollectionView.delegate = self
        petFeedCollectionView.delaysContentTouches = false
    }
    
    
    // MARK: - Binding
    func bindSnapshot() {
        viewModel?.snapshotSubject.sink { [weak self] snapshot in
            guard let isFirstFetching = self?.viewModel?.isFirstFetching,
                  let isRefreshing = self?.petFeedCollectionView.refreshControl?.isRefreshing
            else { return }
            self?.configureEmptyView(with: snapshot.numberOfItems)
            
            if isRefreshing {
                self?.petFeedCollectionView.refreshControl?.endRefreshing()
            }
            
            if isFirstFetching {
                self?.configurePetCollectionView()
                self?.viewModel?.isFirstFetching = false
            }
            self?.petFeedDataSource?.apply(snapshot, animatingDifferences: false)
        }.store(in: &cancellables)
    }
      
    private func configureEmptyView(with numberOfItems: Int) {
        if numberOfItems == 0 {
            configureEmptyLabel()
            lazyCatAnimationView.isHidden = false
            emptyFeedLabel.isHidden = false
            lazyCatAnimationView.play()
        } else {
            lazyCatAnimationView.isHidden = true
            emptyFeedLabel.isHidden = true
            lazyCatAnimationView.stop()
        }
    }
    
    private func configureEmptyLabel() {
        let currentDateComponents: DateComponents = .currentDateTimeComponents()
        emptyFeedLabel.text = "어라.. 등록된 펫이 없네요 🥲 \n 지금 바로 \(currentDateComponents.month!)월의 첫번째 펫을 올려보세요!"
        emptyFeedLabel.sizeToFit()
    }
    
    
}

extension BaseCollectionViewCell: UICollectionViewDelegate, PetFeedCollectionViewCellListener {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let scrollViewHeight = scrollView.contentSize.height - scrollView.frame.height
        if scrollViewHeight - scrollView.contentOffset.y <= 0 {
            parentViewController?.baseCollectionViewNeedNewFeed()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedFeed = viewModel?.getSelectedFeed(index: indexPath) else { return }
        parentViewController?.baseCollectionViewCellDidTapped(index: indexPath, feed: selectedFeed)
    }
    
    func profileStackViewDidTapped(with cell: UICollectionViewCell) {
        guard let item = petFeedCollectionView.indexPath(for: cell)?.item,
              let selectedUser = viewModel?.petpionFeedSubject.value[item].uploader
        else { return }
        parentViewController?.profileStackViewDidTapped(with: selectedUser)
    }
}
