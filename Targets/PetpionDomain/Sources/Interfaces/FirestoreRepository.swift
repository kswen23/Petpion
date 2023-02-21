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
    func uploadPersonalReportList<T>(reported: T, reason: String) async -> Bool
    func uploadReportList<T>(reported: T, reason: String) async -> Bool
    
    // MARK: - Read
    func fetchFirstFeedArray(by option: SortingOption) async -> [PetpionFeed]
    func fetchFeedArray(by option: SortingOption) async -> [PetpionFeed]
    func fetchRandomFeedArrayWithLimit(to count: Int) async -> [PetpionFeed]
    func fetchFeedCounts(_ feed: PetpionFeed) async -> PetpionFeed
    func fetchUser(uid: String) async -> User
    func addUserListener(completion: @escaping ((User)-> Void))
    func fetchFeedsWithUserID(with user: User) async -> [PetpionFeed]
    func fetchFeedWithFeedID(with feed: PetpionFeed) async -> PetpionFeed
    func checkDuplicatedNickname(with nickname: String) async -> Bool
    func getReportedArray(type: ReportBlockType) async -> [String]?
    
    // MARK: - Update
    func updateFeed(with feed: PetpionFeed) async -> Bool
    func updateFeedCounts(with feed: PetpionFeed, voteResult: VoteResult) async -> Bool
    func updateUserHeart(_ count: Int) async -> Bool
    func updateUserNickname(_ nickname: String) async -> Bool
    func plusUserHeart()
    func minusUserHeart()
    func updateUserLatestVoteTime()
    
    // MARK: - Delete
    func deleteFeedDataWithFeed(_ feed: PetpionFeed) async -> Bool
    func deleteUserFeeds(_ user: User) async -> Bool
}
