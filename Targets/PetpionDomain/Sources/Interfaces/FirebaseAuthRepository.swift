//
//  FirebaseAuthRepository.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/03.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public protocol FirebaseAuthRepository {
    func signInFirebaseAuth(providerID: String,
                            idToken: String,
                            rawNonce: String?) async -> (Bool, String)
}
