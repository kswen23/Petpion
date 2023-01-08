//
//  CalculateVoteChance.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/06.
//  Copyright © 2023 Petpion. All rights reserved.
//

public protocol CalculateVoteChanceUseCase {
    
    var firestoreRepository: FirestoreRepository { get }
    
    func getVoteChance() -> Int
    func getChanceCreationTimeRemaining() -> Double
}
