//
//  LoggedInSettingViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/30.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionCore
import PetpionDomain

protocol LoggedInSettingViewModelInput {
    func fetchUserProfile()
}

protocol LoggedInSettingViewModelOutput {
    
}

protocol LoggedInSettingViewModelProtocol: LoggedInSettingViewModelInput, LoggedInSettingViewModelOutput {
    
    var fetchUserUseCase: FetchUserUseCase { get }
    var user: User { get }
    var userProfileSubject: CurrentValueSubject<User, Never> { get }
    var profileDidUpdated: Bool { get }
}

final class LoggedInSettingViewModel: LoggedInSettingViewModelProtocol {
    
    var fetchUserUseCase: FetchUserUseCase
    var user: User
    lazy var userProfileSubject: CurrentValueSubject<User, Never> = .init(user)
    
    var profileDidUpdated: Bool = false
    
    // MARK: - Initialize
    init(fetchUserUseCase: FetchUserUseCase,
         user: User) {
        self.fetchUserUseCase = fetchUserUseCase
        self.user = user
    }
    
    // MARK: - Input
    
    // MARK: - Output
    func fetchUserProfile() {
        Task {
            guard let uid = UserDefaults.standard.string(forKey: UserInfoKey.firebaseUID) else { return }
            let fetchedUser = await fetchUserUseCase.fetchUser(uid: uid)
            await MainActor.run {
                userProfileSubject.send(fetchedUser)
            }
        }
    }

}
