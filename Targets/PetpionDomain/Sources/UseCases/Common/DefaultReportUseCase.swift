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
    public func report<T>(reported: T, type: ReportCase, description: String? = nil) async -> Bool {
        var reason = type.rawValue
        if let description = description {
            reason = "\(type.rawValue) - \(description)"
        }
        let uploadReportListResult = await firestoreRepository.uploadReportList(reported: reported, reason: reason)
        let uploadPersonalReportListResult = await firestoreRepository.uploadPersonalReportList(reported: reported, reason: reason)
        
        if uploadReportListResult && uploadPersonalReportListResult {
            updateReportedArray(reported: reported)
        }
        return uploadReportListResult && uploadPersonalReportListResult
    }
    
    public func getReportedArray(type: ReportType) async -> [String]? {
        await firestoreRepository.getReportedArray(type: type)
    }
    
    // MARK: - Private
    private func updateReportedArray<T>(reported: T) {
        switch reported {
        case let user as User:
            User.reportedUserIDArray?.append(user.id)
        case let feed as PetpionFeed:
            User.reportedFeedIDArray?.append(feed.id)
        default:
            fatalError()
        }
    }
}
