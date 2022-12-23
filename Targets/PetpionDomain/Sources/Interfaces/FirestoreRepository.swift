//
//  PetpionRepository.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

public protocol FirestoreRepository {
    
    // MARK: - Create
    func uploadNewFeed(_ feed: PetpionFeed) async -> Bool
    
    // MARK: - Read
    func fetchFirstFeedArray(by option: SortingOption) async -> Result<[PetpionFeed], Error>
    func fetchFeedArray(by option: SortingOption) async -> Result<[PetpionFeed], Error>
    func fetchRandomFeedArrayWithLimit(to count: Int) async -> [PetpionFeed]
}
