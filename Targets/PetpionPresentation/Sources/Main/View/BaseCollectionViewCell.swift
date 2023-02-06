//
//  BaseCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/05.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import UIKit

import PetpionDomain

protocol BaseCollectionViewCellDelegation {
    func baseCollectionViewNeedNewFeed()
    func baseCollectionViewCellDidTapped(index: IndexPath, feed: PetpionFeed)
}

class BaseCollectionViewCell: UICollectionViewCell {
    
    var parentViewController: BaseCollectionViewCellDelegation?
    var viewModel: BaseViewModelProtocol?
    private var cancellables = Set<AnyCancellable>()
    lazy var petFeedCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: UICollectionViewLayout())
    private lazy var petFeedDataSource: UICollectionViewDiffableDataSource<Int, PetpionFeed>? = self.viewModel?.makePetFeedCollectionViewDataSource(collectionView: petFeedCollectionView)
    
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
        petFeedCollectionView.backgroundColor = .systemBackground
        petFeedCollectionView.showsVerticalScrollIndicator = false
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
            guard let isFirstFetching = self?.viewModel?.isFirstFetching else { return }
            if isFirstFetching {
                // viewWillAppear시 setCollectioniewLayout 계속 불리는 문제 해결, 하지만 collecionView 더 불릴시 문제있을듯
                self?.configurePetCollectionView()
                self?.viewModel?.isFirstFetching = false
            }
            self?.petFeedDataSource?.apply(snapshot, animatingDifferences: false)
        }.store(in: &cancellables)
    }
}

extension BaseCollectionViewCell: UICollectionViewDelegate {

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
}
