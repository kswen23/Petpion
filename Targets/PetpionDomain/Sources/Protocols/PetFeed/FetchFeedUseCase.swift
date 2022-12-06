//
//  FetchPetFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public protocol FetchFeedUseCase {
    
    var firestoreRepository: FirestoreRepository { get }
    var firebaseStorageRepository: FirebaseStorageRepository { get }
    
    func fetchFeeds(sortBy: SortingOption) async -> [PetpionFeed]
}

public enum SortingOption: Int, CaseIterable {
    
    case popular = 0
    case latest = 1
}
