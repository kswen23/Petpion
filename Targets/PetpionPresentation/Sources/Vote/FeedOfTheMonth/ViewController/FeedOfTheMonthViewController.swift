//
//  FeedOfTheMonthViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/03/04.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionDomain

final class FeedOfTheMonthViewController: HasCoordinatorViewController {
    
    private lazy var feedOfTheMonthCoordinator: FeedOfTheMonthCoordinator? = {
        self.coordinator as? FeedOfTheMonthCoordinator
    }()
    
    private var viewModel: FeedOfTheMonthViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var feedCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    private lazy var feedDataSource: UICollectionViewDiffableDataSource<Int, PetpionFeed> = viewModel.makePetFeedCollectionViewDataSource(collectionView: feedCollectionView, listener: self)
    
    // MARK: - Initialize
    init(viewModel: FeedOfTheMonthViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationTitle()
        viewModel.fetchFeedOfTheMonth(isFirst: true)
    }
    
    private func configureNavigationTitle() {
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .bold)
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        navigationItem.title = dateFormatter.string(from: viewModel.targetDate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutFeedCollectionView()
    }
    
    private func layoutFeedCollectionView() {
        view.addSubview(feedCollectionView)
        feedCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            feedCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            feedCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            feedCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        feedCollectionView.backgroundColor = .white
        feedCollectionView.showsVerticalScrollIndicator = false
    }
    
    // MARK: - Configure
    private func configurePetCollectionView() {
        let config = viewModel.makeWaterfallLayoutConfiguration()
        let waterfallLayout = UICollectionViewCompositionalLayout.makeWaterfallLayout(configuration: config)
        feedCollectionView.setCollectionViewLayout(waterfallLayout, animated: true)
        feedCollectionView.delegate = self
    }
    
    // MARK: - Binding
    private func binding() {
        bindFeedOfTheMonthSubject()
    }
    
    private func bindFeedOfTheMonthSubject() {
        viewModel.feedOfTheMonthSubject.sink { [weak self] feedArray in
            guard let strongSelf = self,
                  feedArray.isEmpty == false else { return }
            
            if strongSelf.viewModel.isFirstFetching == true {
                self?.configurePetCollectionView()
                strongSelf.viewModel.isFirstFetching = false
            }
            
            var snapshot = NSDiffableDataSourceSnapshot<Int, PetpionFeed>()
            snapshot.appendSections([0])
            snapshot.appendItems(feedArray, toSection: 0)
            self?.feedDataSource.apply(snapshot, animatingDifferences: true)
        }.store(in: &cancellables)
    }
}

extension FeedOfTheMonthViewController: UICollectionViewDelegate, PetFeedCollectionViewCellListener {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFeed = viewModel.feedOfTheMonthSubject.value[indexPath.item]
        feedOfTheMonthCoordinator?.pushPushableDetailFeedView(with: selectedFeed)
    }
    
    func profileStackViewDidTapped(with cell: UICollectionViewCell) {
        guard let selectedItemIndexPath = feedCollectionView.indexPath(for: cell)?.item else { return }
        let selectedUser = viewModel.feedOfTheMonthSubject.value[selectedItemIndexPath].uploader
        feedOfTheMonthCoordinator?.pushUserPageView(with: selectedUser)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let scrollViewHeight = scrollView.contentSize.height - scrollView.frame.height
        if scrollViewHeight - scrollView.contentOffset.y <= 0 {
            viewModel.fetchFeedOfTheMonth(isFirst: false)
        }
    }
}
