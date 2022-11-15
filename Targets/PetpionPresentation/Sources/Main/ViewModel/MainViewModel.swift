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
    var fetchPetFeedUseCase: FetchPetFeedUseCase { get }
}

final class MainViewModel: MainViewModelProtocol {
    
    let fetchPetFeedUseCase: FetchPetFeedUseCase
    let uploadPetFeedUseCase: UploadPetFeedUseCase // 지울것
    
    var sortingOption: SortingOption = .favorite
    
    init(fetchPetDataUseCase: FetchPetFeedUseCase,
         uploadPetFeedUseCase: UploadPetFeedUseCase) {
        self.fetchPetFeedUseCase = fetchPetDataUseCase
        self.uploadPetFeedUseCase = uploadPetFeedUseCase
    }
    
    func vmStart() {
        let tempFeed: PetpionFeed = PetpionFeed(feedID: "test",
                                                uploader: User.init(nickName: "ken", profileImage: UIImage()),
                                   uploadDate: Date.init(),
                                   likeCount: 10,
                                   images: [])
        uploadPetFeedUseCase.uploadNewFeed(tempFeed)
        
    }
    
    func makeViewModel(for item: WaterfallItem) -> PetCollectionViewCell.ViewModel {
        return PetCollectionViewCell.ViewModel(item: item)
    }
}

