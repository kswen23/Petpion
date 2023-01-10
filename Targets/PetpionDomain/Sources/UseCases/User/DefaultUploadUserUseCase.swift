//
//  DefaultUploadUserUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/04.
//  Copyright © 2023 Petpion. All rights reserved.
//

public final class DefaultUploadUserUseCase: UploadUserUseCase {
    
    public var firestoreRepository: FirestoreRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    // MARK: - Public
    public func uploadNewUser(_ user: User) {
        firestoreRepository.uploadNewUser(user)
    }
    
    public func updateVoteChanceCount(_ count: Int) {
        firestoreRepository.updateUserHeart(count)
    }
    
    public func minusUserVoteChance() {
        firestoreRepository.minusUserHeart()
    }
    
    public func updateLatestVoteTime() {
        firestoreRepository.updateUserLatestVoteTime()
    }
}
