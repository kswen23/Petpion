//
//  DefaultFetchFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

public final class DefaultFetchFeedUseCase: FetchFeedUseCase {
    
    public var firestoreRepository: FirestoreRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    public func fetchFeeds(sortBy option: SortingOption) -> [PetpionFeed] {
        let defaultPetFeed = fetchDefaultPetFeedData()
        
        return sortPetData(defaultPetFeed, by: option)
    }
    
    // MARK: - Private Methods
    
    private func fetchDefaultPetFeedData() -> [PetpionFeed] {
        
        // 단발성 호출로 받는것이 좋아보임 (Async await)
        
        return [PetpionFeed.init(id: "", uploader: User.empty, uploadDate: Date(), likeCount: 0, images: [Data()])]
    }
    
    private func sortPetData(_ data: [PetpionFeed], by option: SortingOption) -> [PetpionFeed] {
        var defaultData = data
        
        switch option {
        case .favorite:
            defaultData.sort { $0.likeCount < $1.likeCount }
        case .latest:
            defaultData.sort { $0.uploadDate > $1.uploadDate }
        case .random:
            defaultData.shuffle()
        }
        
        return defaultData
    }
}
