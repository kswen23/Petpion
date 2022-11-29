//
//  DefaultUploadPetFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/15.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public final class DefaultUploadFeedUseCase: UploadFeedUseCase {
    
    public var firestoreRepository: FirestoreRepository
    public var firebaseStorageRepository: FirebaseStorageRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository,
         firebaseStorageRepository: FirebaseStorageRepository) {
        self.firestoreRepository = firestoreRepository
        self.firebaseStorageRepository = firebaseStorageRepository
    }

    // MARK: - Public
    public func uploadNewFeed(feed: PetpionFeed, imageDatas: [Data]) async -> Bool {
        return await withCheckedContinuation { continuation in
            Task {
                let imageUploadIsCompleted = await firebaseStorageRepository.uploadPetFeedImages(feed: feed,
                                                                                           imageDatas: imageDatas)
                let feedUploadIsCompleted = await firestoreRepository.uploadNewFeed(feed)

                if imageUploadIsCompleted && feedUploadIsCompleted {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
        }
    }
}
