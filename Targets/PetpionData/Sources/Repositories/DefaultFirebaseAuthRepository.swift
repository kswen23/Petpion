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
    
    func signInFirebaseAuth(providerID: String,
                            idToken: String,
                            rawNonce: String?) async -> (Bool, String) {
        return await withCheckedContinuation { continuation in
            let credential = OAuthProvider.credential(withProviderID: providerID,
                                                      idToken: idToken,
                                                      rawNonce: rawNonce)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    continuation.resume(returning: (false, "loginFailed"))
                }
                if let user = authResult?.user {
                    continuation.resume(returning: (true, user.uid))
                }
            }
        }
    }
    
}
