//
//  InputReportViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation

import PetpionDomain

protocol InputReportViewModelProtocol {
    var reportBlockType: ReportBlockType { get }
    var reportUseCase: ReportUseCase { get }
    var inputReportViewStateSubject: PassthroughSubject<InputReportViewState, Never> { get }
    var textViewPlaceHolder: String { get }
    var user: User? { get set }
    var feed: PetpionFeed? { get set }
    
    func report(description: String)
}
enum InputReportViewState {
    case startReporting
    case done
    case error
}

final class InputReportViewModel: InputReportViewModelProtocol {
    
    let reportBlockType: ReportBlockType
    let reportUseCase: ReportUseCase
    let inputReportViewStateSubject: PassthroughSubject<InputReportViewState, Never> = .init()
    let textViewPlaceHolder: String = "신고하는 이유를 상세히 적어주세요 🐶"
    
    var user: User?
    var feed: PetpionFeed?
    
    // MARK: - Initialize
    init(reportBlockType: ReportBlockType,
         reportUseCase: ReportUseCase) {
        self.reportBlockType = reportBlockType
        self.reportUseCase = reportUseCase
    }
    
    func report(description: String) {
        switch reportBlockType {
        case .user:
            reportUser(description: description)
        case .feed:
            reportFeed(description: description)
        }
    }
    
    private func reportUser(description: String) {
        Task {
            guard let user = user else { return }
            
            await MainActor.run {
                inputReportViewStateSubject.send(.startReporting)
            }
            
            let reportCompleted = await reportUseCase.report(reported: user, type: .other, description: description)
            await MainActor.run {
                if reportCompleted {
                    inputReportViewStateSubject.send(.done)
                } else {
                    inputReportViewStateSubject.send(.error)
                }
            }
        }
    }
    
    private func reportFeed(description: String) {
        Task {
            guard let feed = feed else { return }
            
            await MainActor.run {
                inputReportViewStateSubject.send(.startReporting)
            }
            
            let reportCompleted = await reportUseCase.report(reported: feed, type: .other, description: description)
            await MainActor.run {
                if reportCompleted {
                    inputReportViewStateSubject.send(.done)
                } else {
                    inputReportViewStateSubject.send(.error)
                }
            }
        }
    }
    
}
