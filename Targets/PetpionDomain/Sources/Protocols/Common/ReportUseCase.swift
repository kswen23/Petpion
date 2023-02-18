//
//  ReportUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/18.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public protocol ReportUseCase {
    
    var firestoreRepository: FirestoreRepository { get }
    
    func reportUser(user: User, type: ReportType, description: String?)
    func reportFeed(feed: PetpionFeed, type: ReportType, description: String?)
}
