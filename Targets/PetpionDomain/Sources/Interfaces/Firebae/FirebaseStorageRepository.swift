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
    func uploadProfileImage(_ user: User) async -> Bool
    
    // MARK: - Read
    func fetchFeedThumbnailImageURL(_ feed: PetpionFeed) async -> [URL]
    func fetchFeedTotalImageURL(_ feed: PetpionFeed) async -> [URL]
    func fetchUserProfileImageURL(_ user: User) async -> URL?
    
    // MARK: - Delete
    func deleteFeedImages(_ feed: PetpionFeed) async -> Bool
    func deleteUserImage(_ user: User) async -> Bool
}
