//
//  LoggedInSettingViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/30.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

protocol LoggedInSettingViewModelInput {
    
}

protocol LoggedInSettingViewModelOutput {
    func getUserProfileImage() async -> UIImage
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
    
    // MARK: - Output
    func getUserProfileImage() async -> UIImage  {
        guard let profileURL = user.imageURL else { return UIImage(systemName: "person.fill")! }
        return await ImageCache.shared.loadImage(url: profileURL as NSURL)
    }

}
