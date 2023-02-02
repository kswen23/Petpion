//
//  UploadUserUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/04.
//  Copyright © 2023 Petpion. All rights reserved.
//

import UIKit

public protocol UploadUserUseCase {
    
    var firebaseStorageRepository: FirebaseStorageRepository { get }
    var firestoreRepository: FirestoreRepository { get }
    
    func uploadNewUser(_ user: User)
    func updateVoteChanceCount(_ count: Int) async -> Bool
    func updateUserNickname(_ nickname: String) async -> Bool
    func uploadUserProfileImage(_ user: User) async -> Bool
    func plusUserVoteChance()
    func minusUserVoteChance()
    func updateLatestVoteTime()
    func checkUserNicknameDuplication(with nickname: String) async -> Bool
}
