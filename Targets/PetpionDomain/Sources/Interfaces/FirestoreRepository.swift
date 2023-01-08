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
    func createCounters(_ feed: PetpionFeed) async -> Bool
    func uploadNewUser(_ user: User)
    
    // MARK: - Read
    func fetchFirstFeedArray(by option: SortingOption) async -> Result<[PetpionFeed], Error>
    func fetchFeedArray(by option: SortingOption) async -> Result<[PetpionFeed], Error>
    func fetchRandomFeedArrayWithLimit(to count: Int) async -> [PetpionFeed]
    func fetchFeedCounts(_ feed: PetpionFeed) async -> PetpionFeed
    func fetchUser(with uid: String) async -> Result<User, Error>
    // MARK: - Update
    func updateFeedCounts(with feed: PetpionFeed, voteResult: VoteResult) async -> Bool
}
