//
//  MyPageViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

protocol MyPageViewModelInput {
    
}

protocol MyPageViewModelOutput {
    func loadUserProfileImage() async -> UIImage
}

protocol MyPageViewModelProtocol: MyPageViewModelInput, MyPageViewModelOutput {
    var user: User { get }
    var fetchFeedUseCase: FetchFeedUseCase { get }
}

final class MyPageViewModel: MyPageViewModelProtocol {
    
    let user: User
    let fetchFeedUseCase: FetchFeedUseCase
//
//    // MARK: - Initialize
    init(user: User,
         fetchFeedUseCase: FetchFeedUseCase) {
        self.user = user
        self.fetchFeedUseCase = fetchFeedUseCase
        Task {
            print(await fetchFeedUseCase.fetchUserTotalFeeds(user: user))
        }
    }
    
    // MARK: - Input
    
    // MARK: - Output
    func loadUserProfileImage() async -> UIImage  {
        guard let profileURL = user.imageURL else { return .init() }
            return await ImageCache.shared.loadImage(url: profileURL as NSURL)
    }

}
