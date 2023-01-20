//
//  CalculateVoteChance.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/06.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public protocol CalculateVoteChanceUseCase {
    
    var firestoreRepository: FirestoreRepository { get }
    func initializeUserVoteChance() async -> Bool
    func bindUser(completion: @escaping ((Int, Date)-> Void))
    func getRemainingTimeIntervalToCreateVoteChance(latestVoteTime: Date) -> TimeInterval
}
