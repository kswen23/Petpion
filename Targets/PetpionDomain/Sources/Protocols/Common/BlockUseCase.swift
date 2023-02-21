//
//  BlockUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/21.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public protocol BlockUseCase {
    
    var firestoreRepository: FirestoreRepository { get }
    
    func block<T>(blocked: T, type: ReportCase, description: String?) async -> Bool
    func getReportedArray(type: ReportBlockType) async -> [String]?

}
