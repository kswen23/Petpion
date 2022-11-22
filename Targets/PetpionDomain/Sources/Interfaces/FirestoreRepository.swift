//
//  PetpionRepository.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

public protocol FirestoreRepository {
    
    // MARK: - Create
    func uploadNewFeed(_ feed: PetpionFeed)
    // MARK: - Read
    func fetchFeeds(by option: SortingOption) async -> Result<[PetpionFeed], Error>
    
}
