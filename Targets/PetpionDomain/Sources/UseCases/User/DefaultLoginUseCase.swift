//
//  DefaultLoginUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/03.
//  Copyright © 2023 Petpion. All rights reserved.
//

public final class DefaultLoginUseCase: LoginUseCase {
    public var firebaseAuthRepository: FirebaseAuthRepository
    
    // MARK: - Initialize
    init(firebaseAuthRepository: FirebaseAuthRepository) {
        self.firebaseAuthRepository = firebaseAuthRepository
    }
    
    // MARK: - Public
    public func signInToFirebaseAuth(providerID: String, idToken: String, rawNonce: String?) async -> (Bool, String) {
        await firebaseAuthRepository.signInFirebaseAuth(providerID: providerID,
                                                  idToken: idToken,
                                                  rawNonce: rawNonce)
    }
}
