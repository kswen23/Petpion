//
//  MainViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit
//지울것

import PetpionDomain

public protocol MainViewModelInputProtocol {
    func vmStart()
}

public protocol MainViewModelOutputProtocol {
    //    func makeViewModel(for: WaterfallItem) -> PetCollectionViewCell.ViewModel
}

public protocol MainViewModelProtocol: MainViewModelInputProtocol, MainViewModelOutputProtocol {
    var fetchFeedUseCase: FetchFeedUseCase { get }
}

final class MainViewModel: MainViewModelProtocol {
    
    let fetchFeedUseCase: FetchFeedUseCase
    let uploadFeedUseCase: UploadFeedUseCase // 지울것
    
    var sortingOption: SortingOption = .favorite
    
    init(fetchFeedUseCase: FetchFeedUseCase,
         uploadFeedUseCase: UploadFeedUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
        self.uploadFeedUseCase = uploadFeedUseCase
    }
    
    func vmStart() {
        let tempFeed: PetpionFeed = PetpionFeed(id: UUID().uuidString, 
                                                uploader: User.init(id: UUID().uuidString,
                                                                    nickName: "user",
                                                                    profileImage: Data()),
                                                uploadDate: Date.init(),
                                                likeCount: 10,
                                                images: [])
//        uploadFeedUseCase.uploadNewFeed(tempFeed)
//        fetchFeedUseCase.fetchFeeds(sortBy: .favorite)
        uploadFeedUseCase.
    }
    
    func makeViewModel(for item: WaterfallItem) -> PetCollectionViewCell.ViewModel {
        return PetCollectionViewCell.ViewModel(item: item)
    }
}

