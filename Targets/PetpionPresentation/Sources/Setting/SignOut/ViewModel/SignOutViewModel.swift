//
//  SignOutViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/07.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import PetpionDomain

protocol SignOutViewModelProtocol {
    var user: User { get }
    func signOut()
}

final class SignOutViewModel: SignOutViewModelProtocol {
    
    var user: User
    
    // MARK: - Initialize
    init(user: User = .empty) {
        self.user = user
    }
    
    func signOut() {
        // userdefaults, firebaseStrage, firestore, loginToken 삭제필요
    }
}
