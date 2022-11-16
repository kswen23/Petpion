//
//  FirebaseStorageRepository.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/16.
//  Copyright © 2022 Petpion. All rights reserved.
//

public protocol FirebaseStorageRepository {
    
    func uploadPetFeedImages(_ feed: PetpionFeed) async -> Result<String, Error>
}
