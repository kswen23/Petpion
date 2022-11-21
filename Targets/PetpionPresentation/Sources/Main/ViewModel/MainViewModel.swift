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
    func uploadNewFeed(images: [UIImage], message: String?)
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
        fetchFeedUseCase.fetchFeeds(sortBy: .favorite)
    }
    
    func uploadNewFeed(images: [UIImage], message: String?) {
        let datas: [Data] = images.map{ $0.jpegData(compressionQuality: 0.8) ?? Data() }
        
        let feed: PetpionFeed = PetpionFeed(id: UUID().uuidString,
                                            uploaderID: UUID().uuidString,
                                            uploadDate: Date.init(),
                                            likeCount: 10,
                                            imageCount: datas.count,
                                            message: message ?? "")
        uploadFeedUseCase.uploadNewFeed(feed: feed, imageDatas: datas)
    }
    
    func makeViewModel(for item: WaterfallItem) -> PetCollectionViewCell.ViewModel {
        return PetCollectionViewCell.ViewModel(item: item)
    }
}

