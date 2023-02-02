//
//  PetpionRepository.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public protocol FirestoreRepository {
    
    // MARK: - Create
    func uploadNewFeed(_ feed: PetpionFeed) async -> Bool
    func createCounters(_ feed: PetpionFeed) async -> Bool
    func uploadNewUser(_ user: User)
    
    // MARK: - Read
    func fetchFirstFeedArray(by option: SortingOption) async -> [PetpionFeed]
    func fetchFeedArray(by option: SortingOption) async -> [PetpionFeed]
    func fetchRandomFeedArrayWithLimit(to count: Int) async -> [PetpionFeed]
    func fetchFeedCounts(_ feed: PetpionFeed) async -> PetpionFeed
    func fetchUser(uid: String) async -> User
    func addUserListener(completion: @escaping ((User)-> Void))
    func fetchFeedsWithUserID(with user: User) async -> [PetpionFeed]
    func checkDuplicatedNickname(with nickname: String) async -> Bool
    // MARK: - Update
    func updateFeedCounts(with feed: PetpionFeed, voteResult: VoteResult) async -> Bool
    func updateUserHeart(_ count: Int) async -> Bool
    func updateUserNickname(_ nickname: String) async -> Bool
    func plusUserHeart()
    func minusUserHeart()
    func updateUserLatestVoteTime()
}
