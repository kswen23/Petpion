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
    public func fetchFeeds(sortBy option: SortingOption) async -> [PetpionFeed] {
        return await withCheckedContinuation { continuation in
            Task {
                let result = await firestoreRepository.fetchFeeds(by: option)
                switch result {
                case .success(let success):
                    let feedWithImageURL = await addImageURL(feeds: success)
                    // emit to viewModel
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }

    // MARK: - Private
    private func addImageURL(feeds: [PetpionFeed]) async -> [PetpionFeed] {
        return await withCheckedContinuation { continuation in
            Task {
                let result = await withTaskGroup(of: PetpionFeed.self) { taskGroup -> [PetpionFeed] in
                    for feed in feeds {
                        taskGroup.addTask {
                            let urlArr = await self.firebaseStorageRepository.fetchFeedImageURL(feed)
                            var withURLFeed = feed
                            withURLFeed.imageURLArr = urlArr
                            return withURLFeed
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
