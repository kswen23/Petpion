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
    case duplicatedNickname
    case done
}

final class EditProfileViewModel: EditProfileViewModelProtocol {
    
    var user: User = .empty
    let uploadUserUseCase: UploadUserUseCase
    let editProfileViewStateSubject: PassthroughSubject<EditProfileViewState, Never> = .init()
    private var profileImageDidChanged: Bool = false
    
    // MARK: - Initialize
    init(uploadUserUseCase: UploadUserUseCase) {
        self.uploadUserUseCase = uploadUserUseCase
    }
    
    // MARK: - Input
    func uploadUserData(with nickname: String) {
        Task {
            if nickname != user.nickname {
//                let profileUploadResult = await uploadUserUseCase.uploadUserProfileImage(user)
                let updateNicknameResult = await uploadUserUseCase.updateUserNickname(nickname)
                print("nicknameChange: \(updateNicknameResult)")
            }
            if profileImageDidChanged {
                let profileUploadResult = await uploadUserUseCase.uploadUserProfileImage(user)
                print("profileChange: \(profileUploadResult)")
            }
        
            postProfileUpdatedNotification()
        }
        
    }
    
    func changeCurrentProfileImage(_ image: UIImage) {
        profileImageDidChanged = true
        user.profileImage = image
    }
    
    private func postProfileUpdatedNotification() {
        let name = Notification.Name("ProfileUpdated")
        let notification = Notification(name: name)
        NotificationCenter.default.post(notification)
    }
    // MARK: - Output
    func checkUserNicknameDuplication(with nickname: String) {
        Task {
            if nickname == user.nickname {
                editProfileViewStateSubject.send(.done)
            } else {
                let nickNameIsDuplicated = await uploadUserUseCase.checkUserNicknameDuplication(with: nickname)
                
                await MainActor.run { [nickNameIsDuplicated] in
                    if nickNameIsDuplicated {
                        editProfileViewStateSubject.send(.duplicatedNickname)
                    } else {
                        editProfileViewStateSubject.send(.done)
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
