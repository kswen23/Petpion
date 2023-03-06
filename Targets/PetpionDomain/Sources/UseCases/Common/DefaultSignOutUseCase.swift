//
//  DefaultSignOutUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/03/06.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

final public class DefaultSignOutUseCase: SignOutUseCase {
    
    public var firestoreRepository: FirestoreRepository
    public var firebaseStorageRepository: FirebaseStorageRepository
    public var firebaseAuthRepository: FirebaseAuthRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository,
         firebaseStorageRepository: FirebaseStorageRepository,
         firebaseAuthRepository: FirebaseAuthRepository) {
        self.firestoreRepository = firestoreRepository
        self.firebaseStorageRepository = firebaseStorageRepository
        self.firebaseAuthRepository = firebaseAuthRepository
    }
    
    // MARK: - Public
    public func signOut(_ user: User) async -> Bool {
        let deleteUserTotalFeeds = await deleteUserTotalFeeds(user)
        let deleteUser = await deleteUser(user)
        let deleteAuth = await firebaseAuthRepository.deleteUser(user)
        
        return deleteUserTotalFeeds && deleteAuth && deleteUser
    }
    
    // MARK: - Private
    private func deleteUser(_ user: User) async -> Bool {
        let firebaseStorageDeleteResult = await firebaseStorageRepository.deleteUserImage(user)
        let firestoreDeleteResult = await firestoreRepository.deleteUser(user)

        return firestoreDeleteResult && firebaseStorageDeleteResult
    }

    private func deleteUserTotalFeeds(_ user: User) async -> Bool {
        let userFeed = await firestoreRepository.deleteUserFeeds(user)
        for feed in userFeed.1 {
            if await firebaseStorageRepository.deleteFeedImages(feed) == false {
                return false
            }
        }
        return userFeed.0 && true 
    }
    
}
