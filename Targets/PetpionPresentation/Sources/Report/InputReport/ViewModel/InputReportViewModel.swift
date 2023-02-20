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
    var reportType: ReportSceneType { get }
    var reportUseCase: ReportUseCase { get }
    var currentType: ReportSceneType { get }
    var inputReportViewStateSubject: PassthroughSubject<InputReportViewState, Never> { get }
    var textViewPlaceHolder: String { get }
    var user: User? { get set }
    var feed: PetpionFeed? { get set }
    
    func reportUser(description: String)
}
enum InputReportViewState {
    case startReporting
    case done
    case error
}

final class InputReportViewModel: InputReportViewModelProtocol {
    
    let reportType: ReportSceneType
    let reportUseCase: ReportUseCase
    let currentType: ReportSceneType
    let inputReportViewStateSubject: PassthroughSubject<InputReportViewState, Never> = .init()
    let textViewPlaceHolder: String = "신고하는 이유를 상세히 적어주세요. 🐶"
    
    var user: User?
    var feed: PetpionFeed?
    
    // MARK: - Initialize
    init(reportType: ReportSceneType,
         reportUseCase: ReportUseCase,
         currentType: ReportSceneType) {
        self.reportType = reportType
        self.reportUseCase = reportUseCase
        self.currentType = currentType
    }
    
    func reportUser(description: String) {
        Task {
            guard let user = user else { return }
            
            await MainActor.run {
                inputReportViewStateSubject.send(.startReporting)
            }
            
            let reportCompleted = await reportUseCase.reportUser(reportedUser: user, type: .other, description: description)
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
