//
//  EditProfileViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/31.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionCore
import PetpionDomain

protocol EditProfileViewModelInput {
    func uploadUserData(with nickname: String)
    func changeCurrentProfileImage(_ image: UIImage)
}

protocol EditProfileViewModelOutput {
    func checkUserNicknameDuplication(with nickname: String)
    func checkProfileNicknameChanges(with nickname: String) -> Bool
}

protocol EditProfileViewModelProtocol: EditProfileViewModelInput, EditProfileViewModelOutput {
    var user: User { get set }
    var uploadUserUseCase: UploadUserUseCase { get }
    var editProfileViewStateSubject: PassthroughSubject<EditProfileViewState, Never> { get }
}

enum EditProfileViewState {
    case startLoading
    case startUpdating
    case duplicatedNickname
    case finishUpdating
    case error
}

final class EditProfileViewModel: EditProfileViewModelProtocol {
    
    var user: User
    let uploadUserUseCase: UploadUserUseCase
    let editProfileViewStateSubject: PassthroughSubject<EditProfileViewState, Never> = .init()
    private var profileImageDidChanged: Bool = false
    
    // MARK: - Initialize
    init(uploadUserUseCase: UploadUserUseCase,
         user: User) {
        self.uploadUserUseCase = uploadUserUseCase
        self.user = user
    }
    
    // MARK: - Input
    func uploadUserData(with nickname: String) {
        Task {
            var nicknameDidUpdated: Bool = false
            var profileImageDidUpdated: Bool = false
            
            if nickname != user.nickname {
                nicknameDidUpdated = await uploadUserUseCase.updateUserNickname(nickname)
                user.nickname = nickname
            } else {
                nicknameDidUpdated = true
            }
            
            if profileImageDidChanged {
                profileImageDidUpdated = await uploadUserUseCase.uploadUserProfileImage(user)
            } else {
                profileImageDidUpdated = true
            }
            
            await MainActor.run { [profileImageDidUpdated, nicknameDidUpdated] in
                if profileImageDidUpdated, nicknameDidUpdated {
                    postProfileUpdatedNotification()
                    editProfileViewStateSubject.send(.finishUpdating)
                } else {
                    editProfileViewStateSubject.send(.error)
                }
            }
            
        }
        
    }
    
    func changeCurrentProfileImage(_ image: UIImage) {
        profileImageDidChanged = true
        user.profileImage = image
    }
    
    private func postProfileUpdatedNotification() {
        let userInfo: [AnyHashable: User] = ["profile": user]
        let notification = Notification(name: Notification.Name(NotificationName.profileUpdated), object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    // MARK: - Output
    func checkUserNicknameDuplication(with nickname: String) {
        editProfileViewStateSubject.send(.startLoading)
        Task {
            if nickname == user.nickname {
                await MainActor.run {
                    editProfileViewStateSubject.send(.startUpdating)
                }
            } else {
                let nickNameIsDuplicated = await uploadUserUseCase.checkUserNicknameDuplication(with: nickname, field: .nickname)
                
                await MainActor.run { [nickNameIsDuplicated] in
                    if nickNameIsDuplicated {
                        editProfileViewStateSubject.send(.duplicatedNickname)
                    } else {
                        editProfileViewStateSubject.send(.startUpdating)
                    }
                }
            }
        }
    }
    
    func checkProfileNicknameChanges(with nickname: String) -> Bool {
        if nickname == user.nickname {
            return false
        } else {
            return true
        }
    }
}
