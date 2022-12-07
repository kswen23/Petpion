//
//  BaseViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/07.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionCore
import PetpionDomain


protocol BaseViewModelInput {
    
}

protocol BaseViewModelOutput {
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<Int, PetpionFeed>,Publishers.Map<PassthroughSubject<[PetpionFeed], Never>,NSDiffableDataSourceSnapshot<Int, PetpionFeed>>.Failure> { get }
    var petpionFeedSubject: CurrentValueSubject<[PetpionFeed], Never> { get }
    func makeWaterfallLayoutConfiguration() -> UICollectionLayoutWaterfallConfiguration
    func makePetFeedCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, PetpionFeed>

}
protocol BaseViewModelProtocol: BaseViewModelInput, BaseViewModelOutput { }

final class BaseViewModel: BaseViewModelProtocol {
    
    private var cancellables = Set<AnyCancellable>()
    var petpionFeedSubject: CurrentValueSubject<[PetpionFeed], Never> = .init([])
    lazy var snapshotSubject = petpionFeedSubject.map { items -> NSDiffableDataSourceSnapshot<Int, PetpionFeed> in
        var snapshot = NSDiffableDataSourceSnapshot<Int, PetpionFeed>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        return snapshot
    }.eraseToAnyPublisher()


    
    // MARK: - Input
    
    // MARK: - Output
    func makeWaterfallLayoutConfiguration() -> UICollectionLayoutWaterfallConfiguration {
        return UICollectionLayoutWaterfallConfiguration(
            columnCount: 2,
            spacing: 5,
            contentInsetsReference: UIContentInsetsReference.automatic) { [self] indexPath in
                petpionFeedSubject.value[indexPath.row].feedSize
            }
    }

    func makePetFeedCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, PetpionFeed> {
        let registration = makePetFeedCollectionViewCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }

    func makePetFeedCollectionViewCellRegistration() -> UICollectionView.CellRegistration<PetFeedCollectionViewCell, PetpionFeed> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            let viewModel = self.makeViewModel(for: item)
            cell.configure(with: viewModel)
        }
    }

    func makeViewModel(for item:  PetpionFeed) -> PetFeedCollectionViewCell.ViewModel {
        return PetFeedCollectionViewCell.ViewModel(petpionFeed: item)
    }

}
