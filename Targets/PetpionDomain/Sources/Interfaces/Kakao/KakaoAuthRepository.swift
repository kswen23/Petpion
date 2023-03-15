//
//  KakaoAuthRepository.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/23.
//  Copyright © 2023 Petpion. All rights reserved.
//

public protocol KakaoAuthRepository {
    
    func checkKakaoAccessTokenExistence() -> Bool
    
    func startKakaoLogin(_ completion: @escaping ((Bool) -> Void))

    func getKakaoUserIdentifier(_ completion: @escaping ((String)-> Void))
    func unlink()
}
