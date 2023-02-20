//
//  DefaultReportUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/18.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public final class DefaultReportUseCase: ReportUseCase {
    
    public var firestoreRepository: FirestoreRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    // MARK: - Public
    public func reportUser(reportedUser: User, type: ReportType, description: String? = nil) async -> Bool {
        var reason = type.rawValue
        if let description = description {
            reason = "\(type.rawValue) - \(description)"
        }
        let uploadReportResult = await firestoreRepository.uploadUserReported(reportedUser: reportedUser, reason: reason)
        let uploadCurrentUserReportListResult = await firestoreRepository.uploadCurrentUserReportList(reportedUser: reportedUser, reason: reason)
        
        return uploadReportResult && uploadCurrentUserReportListResult
    }
    
    public func reportFeed(feed: PetpionFeed, type: ReportType, description: String? = nil) async -> Bool {
        var reason = type.rawValue
        if let description = description {
            reason = "\(type.rawValue) - \(description)"
        }
        let uploadReportResult = await firestoreRepository.uploadFeedReported(reportedFeed: feed, reason: reason)
        let uploadCurrentUserReportListResult = await firestoreRepository.uploadCurrentFeedReportList(reportedFeed: feed, reason: reason)
        
        return uploadReportResult && uploadCurrentUserReportListResult
    }
    
}
