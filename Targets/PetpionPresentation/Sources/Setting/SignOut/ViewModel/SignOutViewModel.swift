//
//  SignOutViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/07.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation

import PetpionCore
import PetpionDomain

protocol SignOutViewModelProtocol {
    var user: User { get }
    var signOutResultSubject: PassthroughSubject<Bool, Never> { get }
    func signOut()
}

final class SignOutViewModel: SignOutViewModelProtocol {
    
    var user: User
    var signOutUseCase: SignOutUseCase
    var signOutResultSubject: PassthroughSubject<Bool, Never> = .init()
    
    // MARK: - Initialize
    init(user: User,
         signOutUseCase: SignOutUseCase) {
        self.user = user
        self.signOutUseCase = signOutUseCase
    }
    
    func signOut() {
        Task {
            UserInfoKey.deleteAllUserDefaultsValue()
            User.currentUser = nil
            let signOutResult = await signOutUseCase.signOut(user)
            await MainActor.run {
                signOutResultSubject.send(signOutResult)
            }
        }
    }
}
