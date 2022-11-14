//
//  FetchPetDataUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public protocol FetchPetDataUseCase {
    
    var petpionRepository: PetpionRepository { get }
    
    func fetchPetData(sortBy: SortingOption) -> [Pet]
}

public enum SortingOption {
    
    case favorite
    case latest
    case random
}
