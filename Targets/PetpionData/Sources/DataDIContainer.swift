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
        container.register(FirestoreRepository.self) { _ in
            DefaultFirestoreRepository()
        }
        
        container.register(FirebaseStorageRepository.self) { _ in
            DefaultFirebaseStorageRepository()
        }
        
        container.register(FirebaseAuthRepository.self) { _ in
            DefaultFirebaseAuthRepository()
        }
        
        container.register(KakaoAuthRepository.self) { _ in
            DefaultKakaoAuthRepository()
        }
    }
    
}

