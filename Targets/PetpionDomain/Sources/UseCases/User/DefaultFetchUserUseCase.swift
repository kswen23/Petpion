//
//  DefaultFetchUserUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/09.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public final class DefaultFetchUserUseCase: FetchUserUseCase {
    
    // MARK: - Initialize
    public var firestoreRepository: FirestoreRepository
    public var firebaseStorageRepository: FirebaseStorageRepository
    
    init(firestoreRepository: FirestoreRepository,
         firebaseStorageRepository: FirebaseStorageRepository) {
        self.firestoreRepository = firestoreRepository
        self.firebaseStorageRepository = firebaseStorageRepository
    }
    
    // MARK: - Public
    public func fetchUser(uid: String) async -> User {
        let fetchedUser = await firestoreRepository.fetchUser(uid: uid)
//        fetchedUser.imageURL = await firebaseStorageRepository.f
        return fetchedUser
    }
    
}
