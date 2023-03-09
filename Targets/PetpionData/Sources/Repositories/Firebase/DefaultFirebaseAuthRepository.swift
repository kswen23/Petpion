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
    
    func deleteUser(_ user: PetpionDomain.User) async -> Bool {
        switch user.signInType {
        case .kakaoID:
            return await deleteUserWithKakaoID(user)
        case .appleID:
            return await deleteUserWithAppleID()
        }
    }
    
    func logOutUser() async -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch let signOutError as NSError {
            print("로그아웃 실패: \(signOutError)")
            return false
        }
    }
    
    // MARK: - Private
    private func deleteUserWithAppleID() async -> Bool {
        var deleteResult = false
        if let currentUser = Auth.auth().currentUser {
            for userInfo in currentUser.providerData {
                if userInfo.providerID == "apple.com" {
                    deleteResult = await deleteFirebaseAuthUser(user: currentUser)
                }
            }
        }
        return deleteResult
    }
    
    private func deleteUserWithKakaoID(_ user: PetpionDomain.User) async -> Bool {
        var deleteResult = false
        if let kakaoUser = Auth.auth().currentUser,
           let kakaoID = user.kakaoID {
            let credential = EmailAuthProvider.credential(withEmail: user.email, password: kakaoID)
            do {
                _ = try await kakaoUser.reauthenticate(with: credential)
                deleteResult = await deleteFirebaseAuthUser(user: kakaoUser)
            } catch {
                print(error.localizedDescription)
            }
        }
        return deleteResult
    }
    
    private func deleteFirebaseAuthUser(user: FirebaseAuth.User) async -> Bool {
        await withCheckedContinuation { continuation in
            user.delete { error in
                if let error = error {
                    print(error.localizedDescription)
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
}
