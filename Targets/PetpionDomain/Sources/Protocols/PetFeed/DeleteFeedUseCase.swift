//
//  DeleteFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/13.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public protocol DeleteFeedUseCase {
    
    var firestoreRepository: FirestoreRepository { get }
    var firebaseStorageRepository: FirebaseStorageRepository { get }
    
    func deleteFeed(_ feed: PetpionFeed) async -> Bool
}
