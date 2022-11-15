//
//  DefaultUploadPetFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/15.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public final class DefaultUploadPetFeedUseCase: UploadPetFeedUseCase {
    
    public var firestoreRepository: FirestoreRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }

    public func uploadNewFeed(_ feed: PetpionFeed) {
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
    
}
