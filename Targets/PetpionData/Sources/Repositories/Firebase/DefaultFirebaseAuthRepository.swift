//
//  DefaultFirebaseAuthRepository.swift
//  PetpionData
//
//  Created by 김성원 on 2023/01/03.
//  Copyright © 2023 Petpion. All rights reserved.
//

import FirebaseAuth
import PetpionDomain

final class DefaultFirebaseAuthRepository: FirebaseAuthRepository {
    
    func signInFirebaseAuthWithApple(providerID: String,
                            idToken: String,
                            rawNonce: String?) async -> String? {
        return await withCheckedContinuation { continuation in
            let credential = OAuthProvider.credential(withProviderID: providerID,
                                                      idToken: idToken,
                                                      rawNonce: rawNonce)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    continuation.resume(returning: nil)
                }
                if let user = authResult?.user {
                    continuation.resume(returning: user.uid)
                }
            }
        }
    }
    
    func signInFirebaseAuthWithEmail(providerEmail: String,
                                     providerID: String) async -> String? {
        return await withCheckedContinuation { continuation in
            Auth.auth().createUser(withEmail: providerEmail, password: providerID) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    continuation.resume(returning: nil)
                }
                if let user = authResult?.user {
                    continuation.resume(returning: user.uid)
                }
            }
        }
    }
}
