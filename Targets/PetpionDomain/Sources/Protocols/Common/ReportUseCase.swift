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
    
    func report<T>(reported: T, type: ReportCase, description: String?) async -> Bool
    func getReportedArray(type: ReportBlockType) async -> [String]?

}
