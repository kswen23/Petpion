//
//  DomainDIContainer.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import PetpionCore
import Swinject

public struct DomainDIContainer: Containable {
    
    public init() {}

    public var container: Swinject.Container = DIContainer.shared
    
    public func register() {
        registerUseCases()
    }
    
    private func registerUseCases() {
        guard let petpionRepository: PetpionRepository = container.resolve(PetpionRepository.self) else { return }
        container.register(FetchPetDataUseCase.self) { resolver in
            return DefaultFetchPetDataUseCase(petpionRepository: petpionRepository)
        }
    }
    
}