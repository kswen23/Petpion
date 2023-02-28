//
//  PetpionHallViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import PetpionDomain

protocol PetpionHallViewModelInput {
    
}

protocol PetpionHallViewModelOutput {
    
}

protocol PetpionHallViewModelProtocol: PetpionHallViewModelInput, PetpionHallViewModelOutput {
    var fetchFeedUseCase: FetchFeedUseCase { get }
}

final class PetpionHallViewModel: PetpionHallViewModelProtocol {
    
    var fetchFeedUseCase: FetchFeedUseCase
    
    // MARK: - Initialize
    init(fetchFeedUseCase: FetchFeedUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
    }
    
}
