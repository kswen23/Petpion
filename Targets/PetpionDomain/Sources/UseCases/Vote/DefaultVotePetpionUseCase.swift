//
//  DefaultVotePetpionUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/02.
//  Copyright © 2023 Petpion. All rights reserved.
//

public enum VoteResult {
    case selected
    case deselected
}

final public class DefaultVotePetpionUseCase: VotePetpionUseCase {
    
    public var firestoreRepository: FirestoreRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    // MARK: - Public
    public func feedSelected(feed: PetpionFeed) {
        firestoreRepository.updateFeed(with: feed, voteResult: .selected)
    }
    
    public func feedDeselected(feed: PetpionFeed) {
        firestoreRepository.updateFeed(with: feed, voteResult: .deselected)
    }
}

