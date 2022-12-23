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
        guard let firestoreRepository: FirestoreRepository = container.resolve(FirestoreRepository.self),
              let firebaseStorageRepository: FirebaseStorageRepository = container.resolve(FirebaseStorageRepository.self) else { return }
        
        container.register(FetchFeedUseCase.self) { resolver in
            return DefaultFetchFeedUseCase(firestoreRepository: firestoreRepository,
                                           firebaseStorageRepository: firebaseStorageRepository)
        }
        
        container.register(UploadFeedUseCase.self) { resolver in
            return DefaultUploadFeedUseCase(firestoreRepository: firestoreRepository,
                                            firebaseStorageRepository: firebaseStorageRepository)
        }
        
        container.register(MakeVoteListUseCase.self) { resolver in
            return DefaultMakeVoteListUseCase(firestoreRepository: firestoreRepository,
                                              firebaseStorageRepository: firebaseStorageRepository)
        }
    }
    
}
