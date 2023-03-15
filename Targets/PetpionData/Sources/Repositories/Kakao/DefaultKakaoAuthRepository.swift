//
//  DefaultKakaoAuthRepository.swift
//  PetpionData
//
//  Created by 김성원 on 2023/02/23.
//  Copyright © 2023 Petpion. All rights reserved.
//

import KakaoSDKAuth
import KakaoSDKUser
import PetpionDomain

final class DefaultKakaoAuthRepository: KakaoAuthRepository {
    
    func checkKakaoAccessTokenExistence() -> Bool {
        AuthApi.hasToken()
    }
    
    func startKakaoLogin(_ completion: @escaping ((Bool) -> Void)) {
        if UserApi.isKakaoTalkLoginAvailable() == true {
            kakaoLoginWithApp { result in
                completion(result)
            }
        } else {
            kakaoLoginWithWeb { result in
                completion(result)
            }
        }
    }
    
    func getKakaoUserIdentifier(_ completion: @escaping ((String)-> Void)) {
        UserApi.shared.me() { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let userID = user?.id {
                completion(String(describing: userID))
            }
        }
    }
    
    
    // MARK: - Login with App/Web
    func kakaoLoginWithApp(_ completion: @escaping ((Bool) -> Void)) {
        UserApi.shared.loginWithKakaoTalk {(token, error) in
            if let error = error {
                print(error)
                completion(false)
            }
            else {
                print("token?.accessToken): \(String(describing: token?.accessToken))")
                print("token?.refreshToken): \(String(describing: token?.refreshToken))")
                print("kakaoLoginWithApp() success.")
                completion(true)
            }
        }
    }
    
    func kakaoLoginWithWeb(_ completion: @escaping ((Bool) -> Void)) {
        UserApi.shared.loginWithKakaoAccount {(_, error) in
            if let error = error {
                print(error)
                completion(false)
            }
            else {
                print("kakaoLoginWithApp() success.")
                completion(true)
            }
        }
    }
    
    func logout() {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
        }
        
    }
    func unlink() {
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
            }
        }
        
    }
}
