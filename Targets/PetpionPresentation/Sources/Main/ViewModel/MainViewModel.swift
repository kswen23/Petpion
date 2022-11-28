//
//  MainViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain

public protocol MainViewModelInput {
    func fetchNextFeed()
}

public protocol MainViewModelOutput {
    //    func makeViewModel(for: WaterfallItem) -> PetCollectionViewCell.ViewModel
}

public protocol MainViewModelProtocol: MainViewModelInput, MainViewModelOutput {
    var fetchFeedUseCase: FetchFeedUseCase { get }
}

final class MainViewModel: MainViewModelProtocol {
    
    let fetchFeedUseCase: FetchFeedUseCase
    
    var sortingOption: SortingOption = .favorite
    
    init(fetchFeedUseCase: FetchFeedUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
//        fetchFeedUseCase.fetchFeeds(sortBy: sortingOption)
    }
    
    func makeViewModel(for item: WaterfallItem) -> PetCollectionViewCell.ViewModel {
        return PetCollectionViewCell.ViewModel(item: item)
    }
    
    func fetchNextFeed() {
//        fetchFeedUseCase.fetchFeeds(sortBy: sortingOption)
    }
}

