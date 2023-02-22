//
//  ManageBlockedUserViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/21.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation

import PetpionDomain
import UIKit

protocol ManageBlockedUserViewModelInput {
    func unblockUser(_ userIndex: Int)
}

protocol ManageBlockedUserViewModelOutput {
    
}

protocol ManageBlockedUserViewModelProtocol: ManageBlockedUserViewModelInput, ManageBlockedUserViewModelOutput {
    
    var blockUseCase: BlockUseCase { get }
    var blockedUserArraySubject: CurrentValueSubject<[User] ,Never> { get }
    var toastAnimationSubject: PassthroughSubject<Bool, Never> { get }
}

final class ManageBlockedUserViewModel: ManageBlockedUserViewModelProtocol {
    
    let blockUseCase: BlockUseCase
    let blockedUserArraySubject: CurrentValueSubject<[User] ,Never> = .init([])
    let toastAnimationSubject: PassthroughSubject<Bool, Never> = .init()
    
    // MARK: - Initialize
    init(blockUseCase: BlockUseCase) {
        self.blockUseCase = blockUseCase
        initBlockedUserArray()
    }
    
    func unblockUser(_ userIndex: Int) {
        Task {
            let user = blockedUserArraySubject.value[userIndex]
            let unblockIsCompleted = await blockUseCase.unblockUser(user: user)
            await MainActor.run {
                if unblockIsCompleted {
                    deleteUnblockedUser(userIndex)
                    toastAnimationSubject.send(true)
                } else {
                    toastAnimationSubject.send(false)
                }
            }
        }
    }
    
    private func deleteUnblockedUser(_ userIndex: Int) {
        var currentBlockedUserArray = blockedUserArraySubject.value
        if let blockedUserIDIndex = User.blockedUserIDArray?.firstIndex(of: currentBlockedUserArray[userIndex].id) {
            User.blockedUserIDArray?.remove(at: blockedUserIDIndex)
        }
        currentBlockedUserArray.remove(at: userIndex)
        User.blockedUserArray = currentBlockedUserArray
        blockedUserArraySubject.send(currentBlockedUserArray)
    }
    
    private func initBlockedUserArray() {
        guard let blockedUserArray = User.blockedUserArray else { return }
        blockedUserArraySubject.send(blockedUserArray)
    }
    
}
