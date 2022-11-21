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
    public func uploadNewFeed(feed: PetpionFeed, imageDatas: [Data]) {
        uploadNewFeedOnFirestore(feed)
        uploadNewImageOnFirebaseStorage(feed: feed,
                                        imageDatas: imageDatas)
    }
    
    // MARK: - Private
    private func uploadNewFeedOnFirestore(_ feed: PetpionFeed) {
        firestoreRepository.createNewFeed(feed)
    }
    
    private func uploadNewImageOnFirebaseStorage(feed: PetpionFeed,
                                                 imageDatas: [Data]) {
        firebaseStorageRepository.uploadPetFeedImages(feed: feed,
                                                      imageDatas: imageDatas)
    }
}
