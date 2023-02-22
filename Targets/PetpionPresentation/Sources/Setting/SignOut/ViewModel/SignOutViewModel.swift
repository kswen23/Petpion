//
//  SignOutViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/07.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import PetpionCore
import PetpionDomain

protocol SignOutViewModelProtocol {
    var user: User { get }
    func signOut()
}

final class SignOutViewModel: SignOutViewModelProtocol {
    
    var user: User
    var deleteFeedUseCase: DeleteFeedUseCase
    
    // MARK: - Initialize
    init(user: User,
         deleteFeedUseCase: DeleteFeedUseCase) {
        self.user = user
        self.deleteFeedUseCase = deleteFeedUseCase
    }
    
    func signOut() {
        // userDefaults, firebaseStrage, firestore, loginToken 삭제필요
        Task {
            // userDefaults 관련 삭제
            UserInfoKey.deleteAllUserDefaultsValue()
            // 유저가 올린 피드들, 관련 피드이미지 삭제
            await deleteFeedUseCase.deleteUserTotalFeeds(user)
            // 유저정보(firestore), 유저프로필이미지(firebaseStorage) 삭제해야됨
            
        }
    }
}
