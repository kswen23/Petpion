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
    private var userData: User?
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
        initUserData()
    }
    
    // MARK: - Public
    public func getVoteChance() -> Int {
        guard let user = userData else { return 0 }
        //생성할 하트 갯수
        let passedTimeInterval: Int = Int(Date.init().timeIntervalSince(user.latestVoteTime))
        guard user.voteChanceCount != maxVoteChance else { return maxVoteChance}
        let passedHour: Int = passedTimeInterval/3600
        if passedHour >= maxVoteChance {
            return maxVoteChance
        } else {
            return min(passedHour + user.voteChanceCount, maxVoteChance)
        }
    }
    
    public func getChanceCreationTimeRemaining() -> Double {
        guard let user = userData else { return 0 }
        let passedTimeInterval: Int = Int(Date.init().timeIntervalSince(user.latestVoteTime))
        return 3600 - Double(passedTimeInterval%3600)
    }
    
    // MARK: - Private
    private func initUserData() {
        Task {
            guard let firebaseUID = UserDefaults.standard.string(forKey: UserInfoKey.firebaseUID) else { return }
            let user = await firestoreRepository.fetchUser(with: firebaseUID)
            switch user {
            case .success(let user):
                userData = user
            case .failure(_):
                return
            }
        }
    }
    
}
