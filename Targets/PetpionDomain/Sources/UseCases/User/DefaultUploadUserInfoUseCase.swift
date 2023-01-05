//
//  DefaultUploadUserInfoUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/04.
//  Copyright © 2023 Petpion. All rights reserved.
//

public final class DefaultUploadUserInfoUseCase: UploadUserInfoUseCase {
    
    public var firestoreRepository: FirestoreRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    // MARK: - Public
    public func uploadNewUser(_ user: User) {
        firestoreRepository.uploadNewUser(user)
    }
}
