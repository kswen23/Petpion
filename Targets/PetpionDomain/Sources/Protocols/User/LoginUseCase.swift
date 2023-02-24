//
//  LoginUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/03.
//  Copyright © 2023 Petpion. All rights reserved.
//

public protocol LoginUseCase {
    
    var firebaseAuthRepository: FirebaseAuthRepository { get }
    var kakaoAuthReporitory: KakaoAuthRepository { get }
    
    // userDefaults
    func setUserDefaults(firestoreUID: String?)
    
    // apple
    func signInToFirebaseAuth(providerID: String,
                              idToken: String,
                              rawNonce: String?) async -> String?
    func checkUserIsValid(_ firestoreUID: String) async -> Bool
    
    // kakao
    func getKakaoUserID(_ completion: @escaping ((String) -> Void))
    func getUserUIDWithKakao(_ completion: @escaping (((Bool, String)) -> Void))
    func unlink()
    
    // email
    func signInToFirebaseAuthWithEmail(providerEmail: String,
                                       providerID: String) async -> String?
    
}
