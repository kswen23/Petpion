//
//  PetpionRepository.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

public protocol FirestoreRepository {
    
    func createNewFeed(_ feed: PetpionFeed)
    func fetchFeeds() async -> Result<[PetpionFeed], Error>
}
