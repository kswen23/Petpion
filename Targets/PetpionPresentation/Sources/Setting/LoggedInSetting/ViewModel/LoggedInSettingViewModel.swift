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
    func userDidUpdated(to updatedUser: User)
    func logoutDidTapped()
}

protocol LoggedInSettingViewModelOutput {
    
}

protocol LoggedInSettingViewModelProtocol: LoggedInSettingViewModelInput, LoggedInSettingViewModelOutput {
    var user: User { get }
    var loginUseCase: LoginUseCase { get }
    var logoutResultSubject: PassthroughSubject<Bool, Never> { get }
}

final class LoggedInSettingViewModel: LoggedInSettingViewModelProtocol {
    
    var user: User
    var loginUseCase: LoginUseCase
    var logoutResultSubject: PassthroughSubject<Bool, Never> = .init()
    
    // MARK: - Initialize
    init(user: User,
         loginUseCase: LoginUseCase) {
        self.user = user
        self.loginUseCase = loginUseCase
    }
    
    // MARK: - Input
    func userDidUpdated(to updatedUser: User) {
        self.user = updatedUser
    }
    
    func logoutDidTapped() {
        loginUseCase.logoutUserDefaults()
        Task {
            let logoutResult = await loginUseCase.unlinkFirebaseAuth()
            await MainActor.run {
                logoutResultSubject.send(logoutResult)
            }
        }
    }
    // MARK: - Output

}
