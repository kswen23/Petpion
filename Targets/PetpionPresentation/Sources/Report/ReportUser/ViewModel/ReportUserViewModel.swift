//
//  ReportUserViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/18.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import PetpionDomain

protocol ReportUserViewModelInput {
    
}

protocol ReportUserViewModelOutput {
    
}

protocol ReportUserViewModelProtocol: ReportUserViewModelInput, ReportUserViewModelOutput {
    var reportUseCase: ReportUseCase { get }
}

final class ReportUserViewModel: ReportUserViewModelProtocol {
    let reportUseCase: ReportUseCase
    
    // MARK: - Initialize
    init(reportUseCase: ReportUseCase) {
        self.reportUseCase = reportUseCase
    }
    
    
}
