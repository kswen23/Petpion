//
//  DefaultLoginUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/03.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import PetpionCore

public final class DefaultLoginUseCase: LoginUseCase {
    
    public var firebaseAuthRepository: FirebaseAuthRepository
    public var firestoreRepository: FirestoreRepository
    public var kakaoAuthReporitory: KakaoAuthRepository
    
    // MARK: - Initialize
    init(firebaseAuthRepository: FirebaseAuthRepository,
         firestoreRepository: FirestoreRepository,
         kakaoAuthReporitory: KakaoAuthRepository) {
        self.firebaseAuthRepository = firebaseAuthRepository
        self.firestoreRepository = firestoreRepository
        self.kakaoAuthReporitory = kakaoAuthReporitory
    }
    
    // MARK: - Apple
    public func signInToFirebaseAuth(providerID: String, idToken: String, rawNonce: String?) async -> String? {
        await firebaseAuthRepository.signInFirebaseAuthWithApple(providerID: providerID,
                                                  idToken: idToken,
                                                  rawNonce: rawNonce)
    }
    
    public func checkUserIsValid(_ firestoreUID: String) async -> Bool {
        await firestoreRepository.getFirestoreUIDIsValid(firestoreUID)
    }
    
    // MARK: - Kakao
    public func getKakaoUserID(_ completion: @escaping ((String) -> Void)) {
        kakaoAuthReporitory.startKakaoLogin { [weak self] kakaoLoginFinished in
            if kakaoLoginFinished {
                self?.kakaoAuthReporitory.getKakaoUserIdentifier { kakaoUserID in
                    completion(kakaoUserID)
                }
            }
        }
    }
    
    public func getUserUIDWithKakao(_ completion: @escaping (((Bool, String)) -> Void)) {
        getKakaoUserID { [weak self] kakaoID in
            self?.firestoreRepository.getUserIDWithKakaoIdentifier(kakaoID) { userID in
                if let userID = userID {
                    completion((true, userID))
                } else {
                    completion((false, kakaoID))
                }
            }
        }
    }
    
    public func unlink() {
        kakaoAuthReporitory.unlink()
    }
    
    // MARK: - Email
    public func signInToFirebaseAuthWithEmail(providerEmail: String,
                                              providerID: String) async -> String? {
        await firebaseAuthRepository.signInFirebaseAuthWithEmail(providerEmail: providerEmail, providerID: providerID)
    }
    
    // MARK: - UserDefaults
    public func setUserDefaults(firestoreUID: String?) {
        UserDefaults.standard.setValue(true, forKey: UserInfoKey.isLogin.rawValue)
        UserDefaults.standard.setValue(firestoreUID, forKey: UserInfoKey.firebaseUID.rawValue)
    }
}
