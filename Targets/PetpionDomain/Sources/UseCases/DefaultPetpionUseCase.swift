//
//  DefaultPetpionUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public final class DefaultPetpionUseCase: PetpionUseCase {
    
    public var petpionRepository: PetpionRepository
    
    // MARK: - Initialize
    init(petpionRepository: PetpionRepository) {
        self.petpionRepository = petpionRepository
    }
    
    public func doSomething() {
        print("petpionUseCase start")
        petpionRepository.fetchSomething()
    }
    
}
