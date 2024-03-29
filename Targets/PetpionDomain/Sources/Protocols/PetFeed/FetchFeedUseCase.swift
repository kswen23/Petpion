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
    
    func fetchInitialFeedPerSortingOption() async -> [[PetpionFeed]]
    func fetchFeed(isFirst: Bool, option: SortingOption) async -> [PetpionFeed]
    func fetchSpecificMonthFeeds(with date: Date, isFirst: Bool) async -> [PetpionFeed]
    func fetchFeedDetailImages(feed: PetpionFeed) async -> [URL]
    func fetchVotePareDetailImages(pare: PetpionVotePare) async -> PetpionVotePare
    func fetchUserTotalFeeds(user: User) async -> [PetpionFeed]
    
    func updateFeeds(origin: [PetpionFeed]) async -> [PetpionFeed]
    
    func fetchTopPetpionFeedForLast3Months(since date: Date) async -> [TopPetpionFeed]
}

public enum SortingOption: Int, CaseIterable {
    
    case latest = 0
    case popular = 1
}
