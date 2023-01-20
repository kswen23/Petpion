//
//  VotePetpionUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/02.
//  Copyright © 2023 Petpion. All rights reserved.
//

public protocol VotePetpionUseCase {
    
    var firestoreRepository: FirestoreRepository { get }
    
    func feedSelected(feed: PetpionFeed) async -> Bool
    func feedDeselected(feed: PetpionFeed) async -> Bool
}
