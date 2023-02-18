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
    public func reportUser(user: User, type: ReportType, description: String? = nil) {
        
    }
    
    public func reportFeed(feed: PetpionFeed, type: ReportType, description: String? = nil) {
        
    }
    
}
