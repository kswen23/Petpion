//
//  FirebaseAuthRepository.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/03.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public protocol FirebaseAuthRepository {
    func signInFirebaseAuthWithApple(providerID: String,
                                     idToken: String,
                                     rawNonce: String?) async -> String?
    
    func signInFirebaseAuthWithEmail(providerEmail: String,
                                     providerID: String) async -> String?
    
    func logOutUser() async -> Bool
    func deleteUser(_ user: User) async -> Bool
}
