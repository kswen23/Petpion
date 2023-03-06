//
//  SignOutUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/03/06.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public protocol SignOutUseCase {
    
    var firestoreRepository: FirestoreRepository { get }
    var firebaseAuthRepository: FirebaseAuthRepository { get }
    var firebaseStorageRepository: FirebaseStorageRepository { get }

    func signOut(_ user: User) async -> Bool 
}
