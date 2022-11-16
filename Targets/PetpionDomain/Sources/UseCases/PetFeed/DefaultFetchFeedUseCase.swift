//
//  DefaultFetchFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public final class DefaultFetchFeedUseCase: FetchFeedUseCase {
    
    public var firestoreRepository: FirestoreRepository
    public var firebaseStorageRepository: FirebaseStorageRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository,
         firebaseStorageRepository: FirebaseStorageRepository) {
        self.firestoreRepository = firestoreRepository
        self.firebaseStorageRepository = firebaseStorageRepository
    }
    
    public func fetchFeeds(sortBy option: SortingOption) -> [PetpionFeed] {
        let defaultPetFeed = fetchDefaultPetFeedData()
        
        Task {
            let result = await firestoreRepository.fetchFeeds()
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
        
        
        return sortPetData(defaultPetFeed, by: option)
    }
    
    public func fetchFeedImages() -> [Data] {
        // fetchFireStorage with imageReference
        return [Data()]
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
