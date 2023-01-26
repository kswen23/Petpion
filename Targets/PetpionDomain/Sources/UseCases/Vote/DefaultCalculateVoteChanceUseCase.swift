//
//  DefaultCalculateVoteChance.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/06.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import PetpionCore

public final class DefaultCalculateVoteChanceUseCase: CalculateVoteChanceUseCase {
    
    public var firestoreRepository: FirestoreRepository
    let maxVoteChance: Int = User.voteMaxCountPolicy
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    // MARK: - Public
    public func initializeUserVoteChance(user: User) async -> Bool {
        return await firestoreRepository.updateUserHeart(getVoteChance(user: user))
    }
        
    public func getRemainingTimeIntervalToCreateVoteChance(latestVoteTime: Date) -> TimeInterval {
        let passedTimeInterval: Int = Int(Date.init().timeIntervalSince(latestVoteTime))
        return 3600 - Double(passedTimeInterval%3600)
    }
   
    // MARK: - Private
    private func getVoteChance(user: User) -> Int {
        let passedTimeInterval: Int = Int(Date.init().timeIntervalSince(user.latestVoteTime))
        guard user.voteChanceCount != maxVoteChance else { return maxVoteChance}
        let passedHour: Int = passedTimeInterval/3600
        if passedHour >= maxVoteChance {
            return maxVoteChance
        } else {
            return max(min(passedHour + user.voteChanceCount, maxVoteChance), 0)
        }
    }
}
