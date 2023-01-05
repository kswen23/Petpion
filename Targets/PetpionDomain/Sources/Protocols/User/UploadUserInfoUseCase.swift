//
//  UploadUserInfoUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/04.
//  Copyright © 2023 Petpion. All rights reserved.
//

public protocol UploadUserInfoUseCase {
    
    var firestoreRepository: FirestoreRepository { get }
    
    func uploadNewUser(_ user: User)
}
