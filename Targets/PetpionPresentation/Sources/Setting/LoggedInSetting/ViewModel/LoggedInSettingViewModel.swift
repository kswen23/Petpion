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
}

final class LoggedInSettingViewModel: LoggedInSettingViewModelProtocol {
    
    var user: User
    
    // MARK: - Initialize
    init(user: User) {
        self.user = user
    }
    
    // MARK: - Input
    func userDidUpdated(to updatedUser: User) {
        self.user = updatedUser
    }
    
    func logoutDidTapped() {
        
    }
    // MARK: - Output

}
