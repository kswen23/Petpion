//
//  ReportFeedViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/19.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation

import PetpionDomain

protocol ReportFeedViewModelInput {
    func reportFeed(type: ReportType)
}

protocol ReportFeedViewModelOutput {
    
}

protocol ReportFeedViewModelProtocol: ReportFeedViewModelInput, ReportFeedViewModelOutput {
    var feed: PetpionFeed { get }
    var reportUseCase: ReportUseCase { get }
    var reportFeedViewStateSubject: PassthroughSubject<ReportViewState, Never> { get }
}

final class ReportFeedViewModel: ReportFeedViewModelProtocol {
    
    let feed: PetpionFeed
    let reportUseCase: ReportUseCase
    var reportFeedViewStateSubject: PassthroughSubject<ReportViewState, Never> = .init()
    
    // MARK: - Initialize
    init(feed: PetpionFeed,
         reportUseCase: ReportUseCase) {
        self.feed = feed
        self.reportUseCase = reportUseCase
    }
    
    // MARK: - Input
    func reportFeed(type: ReportType) {
        Task {
            if type == .other {
                await MainActor.run {
                    reportFeedViewStateSubject.send(.inputMode)
                }
            } else {
                let reportCompleted = await reportUseCase.reportFeed(feed: feed, type: type, description: nil)
                await MainActor.run {
                    if reportCompleted {
                        reportFeedViewStateSubject.send(.done)
                    } else {
                        reportFeedViewStateSubject.send(.error)
                    }
                }
            }
        }
    }
    
}
