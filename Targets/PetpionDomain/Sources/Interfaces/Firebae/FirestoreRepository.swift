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
    func uploadNewUser(_ user: User) async -> Bool
    func uploadPersonalReportList<T>(reported: T, reason: String) async -> Bool
    func uploadReportList<T>(reported: T, reason: String) async -> Bool
    func uploadBlockList<T>(blocked: T) async -> Bool
    func uploadRankingUpdated()
    
    // MARK: - Read
    func fetchFirstFeedArray(by option: SortingOption) async -> [PetpionFeed]
    func fetchFeedArray(by option: SortingOption) async -> [PetpionFeed]
    func fetchRandomFeedArrayWithLimit(to count: Int) async -> [PetpionFeed]
    func fetchFeedCounts(_ feed: PetpionFeed) async -> PetpionFeed
    func fetchUser(uid: String) async -> User
    func addUserListener(completion: @escaping ((User)-> Void))
    func fetchFeedsWithUserID(with user: User) async -> [PetpionFeed]
    func fetchFeedWithFeedID(with feed: PetpionFeed) async -> PetpionFeed
    func checkDuplicatedFieldValue(with text: String, field: UserInformationField) async -> Bool
    func getUserActionArray(action: UserActionType, type: ReportBlockType) async -> [String]?
    func getUserIDWithKakaoIdentifier(_ kakaoID: String, _ completion: @escaping ((String?) -> Void))
    func getFirestoreUIDIsValid(_ firestoreUID: String) async -> Bool
    func checkPreviousMonthRankingDidUpdated() async -> Bool
    
    // MARK: - Update
    func updateFeed(with feed: PetpionFeed) async -> Bool
    func updateFeedCounts(with feed: PetpionFeed, voteResult: VoteResult) async -> Bool
    func updateUserHeart(_ count: Int) async -> Bool
    func updateUserNickname(_ nickname: String) async -> Bool
    func plusUserHeart()
    func minusUserHeart()
    func updateUserLatestVoteTime()
    func updatePreviousMonthTopFeeds() async -> (Bool, [String])
    func updatePreviousMonthTopUsers(userIDArray: [String])
    
    // MARK: - Delete
    func deleteFeedDataWithFeed(_ feed: PetpionFeed) async -> Bool
    func deleteUserFeeds(_ user: User) async -> Bool
    func deleteBlockedUser(_ user: User) async -> Bool
}
