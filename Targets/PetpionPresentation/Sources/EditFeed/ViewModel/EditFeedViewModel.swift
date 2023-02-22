//
//  EditFeedViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/15.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionDomain

enum EditFeedViewState {
    case startEdit
    case finish
}

protocol EditFeedViewModelInput {
    var currentPageChangedByPageControl: Bool { get }
    func pageControlValueChanged(_ count: Int)
    func collectionViewDidScrolled()
    func configureDoneBarButtonIsEnabled(with text: String) -> Bool
    func textViewDidChanged(_ text: String)
    func doneBarButtonDidTapped()
}

protocol EditFeedViewModelOutput {
    func configureDetailFeedImageCollectionViewLayout() -> UICollectionViewLayout
    func getWinRate() -> Double
}

protocol EditFeedViewModelProtocol: EditFeedViewModelInput, EditFeedViewModelOutput {
    var feed: PetpionFeed { get }
    var editFeedViewStateSubject: PassthroughSubject<EditFeedViewState, Never> { get }
    var currentPageSubject: CurrentValueSubject<Int, Never> { get }
}

final class EditFeedViewModel: EditFeedViewModelProtocol {
    
    var uploadFeedUseCase: UploadFeedUseCase
    var feed: PetpionFeed
    
    var editFeedViewStateSubject: PassthroughSubject<EditFeedViewState, Never> = .init()
    let currentPageSubject: CurrentValueSubject<Int, Never> = .init(0)
    var currentPageChangedByPageControl = false
    private var currentPage: Int = 0
    private lazy var changedMessage: String = feed.message
    
    // MARK: - Initialize
    init(uploadFeedUseCase: UploadFeedUseCase,
         feed: PetpionFeed) {
        self.uploadFeedUseCase = uploadFeedUseCase
        self.feed = feed
    }
    
    // MARK: - Input
    func pageControlValueChanged(_ count: Int) {
        currentPageChangedByPageControl = true
        currentPageSubject.send(count)
    }
    
    func collectionViewDidScrolled() {
        currentPageChangedByPageControl = false
    }
    
    func configureDoneBarButtonIsEnabled(with text: String) -> Bool {
        feed.message != text
    }
    
    func textViewDidChanged(_ text: String) {
        changedMessage = text
    }
    
    func doneBarButtonDidTapped() {
        editFeedViewStateSubject.send(.startEdit)
        feed.message = changedMessage
        Task {
            let updateResult = await uploadFeedUseCase.updateFeed(feed: feed)
            if updateResult == true {
                await MainActor.run {
                    editFeedViewStateSubject.send(.finish)
                }
            }
        }
    }
    
    // MARK: - Output
    func configureDetailFeedImageCollectionViewLayout() -> UICollectionViewLayout {
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
            if self?.currentPageChangedByPageControl == false {
                let changingPage = Int(max(0, round(point.x / environment.container.contentSize.width)))
                guard changingPage != self?.currentPage else { return }
                self?.currentPageSubject.send(changingPage)
                self?.currentPage = changingPage
            }
            self?.collectionViewDidScrolled()
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func getWinRate() -> Double {
        let winRate = ((Double(feed.likeCount)/Double(feed.battleCount))*100).roundDecimal(to: 1)
        return winRate.isNaN ? 0 : winRate
    }
    
}
