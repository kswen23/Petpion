//
//  DataDIContainer.swift
//  PetpionData
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import PetpionCore
import PetpionDomain
import Swinject

public struct DataDIContainer: Containable {
    
    public init() {}

    public var container: Swinject.Container = DIContainer.shared
    
    public func register() {
        registerRepositories()
    }
    
    private func registerRepositories() {
        container.register(FirestoreRepository.self) { resolver in
            return DefaultFirestoreRepository()
        }
        
        container.register(FirebaseStorageRepository.self) { resolver in
            return DefaultFirebaseStorageRepository()
        }
        
        container.register(FirebaseAuthRepository.self) { resolver in
            return DefaultFirebaseAuthRepository()
        }
    }
    
}

