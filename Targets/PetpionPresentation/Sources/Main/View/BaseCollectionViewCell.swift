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

class BaseCollectionViewCell: UICollectionViewCell {
    
    var viewModel: BaseViewModel?
    private var cancellables = Set<AnyCancellable>()
    private lazy var petFeedCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: UICollectionViewLayout())
    lazy var petFeedDataSource: UICollectionViewDiffableDataSource<Int, PetpionFeed>? = self.viewModel?.makePetFeedCollectionViewDataSource(collectionView: petFeedCollectionView)
    
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
//        petFeedCollectionView.delegate = self
    }


    // MARK: - Binding
    func bindSnapshot() {
        viewModel?.snapshotSubject.sink { [weak self] snapshot in
            self?.configurePetCollectionView()
            self?.petFeedDataSource?.apply(snapshot)
        }.store(in: &cancellables)
    }
}

//extension MainViewController: UICollectionViewDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
////        print("\(indexPath)didEndDisplaying")
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        let scrollViewHeight = scrollView.contentSize.height - scrollView.frame.height
//        print(scrollViewHeight - scrollView.contentOffset.y)
//        if scrollViewHeight - scrollView.contentOffset.y <= 0 {
////            count += 1
////            let afterViewModels = Array(1*(count-1)...22*count).map { _ in SearchViewModel() }
////            viewModels = viewModels + afterViewModels
////            initialData(count: count)
//            viewModel.fetchNextFeed()
//        }
//    }
//
//}
