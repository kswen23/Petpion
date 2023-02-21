//
//  ReportUserViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/18.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation

import PetpionDomain

protocol ReportUserViewModelInput {
    func reportUser(type: ReportCase)
}

protocol ReportUserViewModelOutput {
    
}

protocol ReportUserViewModelProtocol: ReportUserViewModelInput, ReportUserViewModelOutput {
    var user: User { get }
    var reportUseCase: ReportUseCase { get }
    var reportUserViewStateSubject: PassthroughSubject<ReportViewState, Never> { get }
}
enum ReportViewState {
    case inputMode
    case done
    case error
}
final class ReportUserViewModel: ReportUserViewModelProtocol {
    
    let user: User
    let reportUseCase: ReportUseCase
    let reportUserViewStateSubject: PassthroughSubject<ReportViewState, Never> = .init()
    
    // MARK: - Initialize
    init(user: User,
         reportUseCase: ReportUseCase) {
        self.user = user
        self.reportUseCase = reportUseCase
    }
    
    // MARK: - Input
    func reportUser(type: ReportCase) {
        Task {
            if type == .other {
                await MainActor.run {
                    reportUserViewStateSubject.send(.inputMode)
                }
            } else {
                let reportCompleted = await reportUseCase.report(reported: user, type: type, description: nil)
                await MainActor.run {
                    if reportCompleted {
                        reportUserViewStateSubject.send(.done)
                    } else {
                        reportUserViewStateSubject.send(.error)
                    }
                }
                
            }
        }
    }
    
}
