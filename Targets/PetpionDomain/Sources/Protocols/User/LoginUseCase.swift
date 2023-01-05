//
//  LoginUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/03.
//  Copyright © 2023 Petpion. All rights reserved.
//

public protocol LoginUseCase {
    
    var firebaseAuthRepository: FirebaseAuthRepository { get }
    
    func signInToFirebaseAuth(providerID: String, idToken: String, rawNonce: String?) async -> (Bool, String)
}
