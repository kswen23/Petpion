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
    public func uploadNewFeed(_ feed: PetpionFeed) {
        uploadNewFeedOnFirestore(feed)
        uploadNewImageOnFirebaseStorage(feed)
    }
    
    // MARK: - Private
    private func uploadNewFeedOnFirestore(_ feed: PetpionFeed) {
        Task {
            let uploadResult = await firestoreRepository.createNewFeed(feed)
            switch uploadResult {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func uploadNewImageOnFirebaseStorage(_ feed: PetpionFeed) {
        Task {
            let uploadResult = await firebaseStorageRepository.uploadPetFeedImages(feed)
            switch uploadResult {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
}
