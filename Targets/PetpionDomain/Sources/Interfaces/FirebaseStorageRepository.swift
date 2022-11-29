//
//  FirebaseStorageRepository.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/16.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public protocol FirebaseStorageRepository {
    
    // MARK: - Create
    func uploadPetFeedImages(feed: PetpionFeed,
                                    imageDatas: [Data]) async -> Bool
    func uploadProfileImage(_ user: User)
    
    // MARK: - Read
    func fetchFeedImageURL(_ feed: PetpionFeed) async -> [URL]
    
}
