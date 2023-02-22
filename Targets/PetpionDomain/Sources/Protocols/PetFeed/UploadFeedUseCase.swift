//
//  UploadPetFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/15.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public protocol UploadFeedUseCase {
 
    var firestoreRepository: FirestoreRepository { get }
    var firebaseStorageRepository: FirebaseStorageRepository { get }
    
    func uploadNewFeed(feed: PetpionFeed, imageDatas: [Data]) async -> Bool
    func updateFeed(feed: PetpionFeed) async -> Bool
}
