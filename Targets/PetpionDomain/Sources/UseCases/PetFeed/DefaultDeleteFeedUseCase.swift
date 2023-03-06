//
//  DefaultDeleteFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/13.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

final public class DefaultDeleteFeedUseCase: DeleteFeedUseCase {
    
    public var firestoreRepository: FirestoreRepository
    public var firebaseStorageRepository: FirebaseStorageRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository,
         firebaseStorageRepository: FirebaseStorageRepository) {
        self.firestoreRepository = firestoreRepository
        self.firebaseStorageRepository = firebaseStorageRepository
    }
    
    // MARK: - Public
    public func deleteFeed(_ feed: PetpionFeed) async -> Bool {
        let imageDidDeleted: Bool = await firebaseStorageRepository.deleteFeedImages(feed)
        let dataDidDeleted: Bool = await firestoreRepository.deleteFeedDataWithFeed(feed)

        return imageDidDeleted && dataDidDeleted
    }
    
}
