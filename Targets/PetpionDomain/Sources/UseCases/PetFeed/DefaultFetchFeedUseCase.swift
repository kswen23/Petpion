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
    
    // MARK: - Public
    public func fetchFeeds(sortBy option: SortingOption) -> [PetpionFeed] {
        let defaultPetFeed = fetchDefaultPetFeedData()
        
        Task {
            let result = await firestoreRepository.fetchFeeds()
            switch result {
            case .success(let success):
                let data = await fetchFeedWithImageURL(feeds: success)
                print(data)
            case .failure(let failure):
                print(failure)
            }
        }
        
        return sortPetData(defaultPetFeed, by: option)
    }
    
    public func fetchFeedWithImageURL(feeds: [PetpionFeed]) async -> [PetpionFeed] {
        return await withCheckedContinuation { continuation in
            Task {
                let result = await withTaskGroup(of: PetpionFeed.self) { taskGroup -> [PetpionFeed] in
                    for feed in feeds {
                        taskGroup.addTask {
                            let urlArr = await self.firebaseStorageRepository.fetchFeedImageURL(feed)
                            return PetpionFeed(id: feed.id,
                                               uploaderID: feed.uploaderID,
                                               uploadDate: feed.uploadDate,
                                               likeCount: feed.likeCount,
                                               imageCount: feed.imagesCount,
                                               message: feed.message ?? "",
                                               imageURLArr: urlArr)
                        }
                        
                    }
                    var resultFeedArr = [PetpionFeed]()
                    for await value in taskGroup {
                        resultFeedArr.append(value)
                    }
                    return resultFeedArr
                }
                continuation.resume(returning: result)
            }
        }
    }
}

// MARK: - Private

private func fetchDefaultPetFeedData() -> [PetpionFeed] {
    
    // 단발성 호출로 받는것이 좋아보임 (Async await)
    
    return [PetpionFeed.init(id: "", uploaderID: "", uploadDate: Date(), likeCount: 0, imageCount: 1, message: "")]
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
