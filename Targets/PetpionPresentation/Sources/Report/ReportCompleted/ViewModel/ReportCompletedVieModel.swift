//
//  ReportCompletedVieModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation

import PetpionDomain

enum ReportCompletedViewState {
    case blocked
    case duplicated
    case error
}

protocol ReportCompletedViewModelProtocol {
    var reportBlockType: ReportBlockType { get }
    var blockUseCase: BlockUseCase { get }
    var user: User? { get set }
    var feed: PetpionFeed? { get set }
    var reportCompletedViewStateSubject: PassthroughSubject<ReportCompletedViewState, Never> { get }
    
    func block()
}

final class ReportCompletedViewModel: ReportCompletedViewModelProtocol {
    
    let reportBlockType: ReportBlockType
    let blockUseCase: BlockUseCase
    
    var user: User?
    var feed: PetpionFeed?
    
    let reportCompletedViewStateSubject: PassthroughSubject<ReportCompletedViewState, Never> = .init()
    
    // MARK: - Initialize
    init(reportBlockType: ReportBlockType,
         blockUseCase: BlockUseCase) {
        self.reportBlockType = reportBlockType
        self.blockUseCase = blockUseCase
    }
    
    func block() {
        if user == nil {
            user = feed?.uploader
        }
        
        if User.isBlockedUser(user: user) {
            reportCompletedViewStateSubject.send(.duplicated)
        } else {
            blockUser()
        }
    }
    
    // MARK: - Private
    private func blockUser() {
        Task {
            guard let user = user else { return }
            let isBlocked = await blockUseCase.block(blocked: user)
            await MainActor.run {
                if isBlocked {
                    User.blockedUserIDArray?.append(user.id)
                    User.blockedUserArray?.append(user)
                    reportCompletedViewStateSubject.send(.blocked)
                } else {
                    reportCompletedViewStateSubject.send(.error)
                }
            }
        }
    }
    
    private func blockFeed() {
        Task {
            guard let feed = feed else { return }
            let isBlocked = await blockUseCase.block(blocked: feed)
            await MainActor.run {
                if isBlocked {
                    User.blockedFeedIDArray?.append(feed.id)
                    reportCompletedViewStateSubject.send(.blocked)
                } else {
                    reportCompletedViewStateSubject.send(.error)
                }
            }
        }
    }
}
