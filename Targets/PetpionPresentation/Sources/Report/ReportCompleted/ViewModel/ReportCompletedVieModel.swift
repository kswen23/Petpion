//
//  ReportCompletedVieModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import PetpionDomain

protocol ReportCompletedViewModelProtocol {
    var reportType: ReportBlockType { get }
    var user: User? { get set }
    var feed: PetpionFeed? { get set }
}

final class ReportCompletedViewModel: ReportCompletedViewModelProtocol {
    
    let reportType: ReportBlockType
    var user: User?
    var feed: PetpionFeed?
    
    // MARK: - Initialize
    init(reportType: ReportBlockType) {
        self.reportType = reportType
    }
    
}
