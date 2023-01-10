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
    public func bindUser(completion: @escaping ((Int, TimeInterval)-> Void)) {
        firestoreRepository.addUserListener { [weak self] user in
            guard let strongSelf = self else { return }
            completion(strongSelf.getVoteChance(user: user),
                       strongSelf.getRemainingTimeIntervalToCreateVoteChance(user: user))
        }
    }
   
    // MARK: - Private
    private func getRemainingTimeIntervalToCreateVoteChance(user: User) -> TimeInterval {
        let passedTimeInterval: Int = Int(Date.init().timeIntervalSince(user.latestVoteTime))
        return 3600 - Double(passedTimeInterval%3600)
    }
    
    private func getVoteChance(user: User) -> Int {
        let passedTimeInterval: Int = Int(Date.init().timeIntervalSince(user.latestVoteTime))
        guard user.voteChanceCount != maxVoteChance else { return maxVoteChance}
        let passedHour: Int = passedTimeInterval/3600
        if passedHour >= maxVoteChance {
            return maxVoteChance
        } else {
            return min(passedHour + user.voteChanceCount, maxVoteChance)
        }
    }
}
