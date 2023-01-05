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
              let firebaseStorageRepository: FirebaseStorageRepository = container.resolve(FirebaseStorageRepository.self),
              let firebaseAuthRepository: FirebaseAuthRepository = container.resolve(FirebaseAuthRepository.self) else { return }
        
        container.register(FetchFeedUseCase.self) { _ in
            DefaultFetchFeedUseCase(firestoreRepository: firestoreRepository,
                                           firebaseStorageRepository: firebaseStorageRepository)
        }
        
        container.register(UploadFeedUseCase.self) { _ in
            DefaultUploadFeedUseCase(firestoreRepository: firestoreRepository,
                                            firebaseStorageRepository: firebaseStorageRepository)
        }
        
        container.register(MakeVoteListUseCase.self) { _ in
            DefaultMakeVoteListUseCase(firestoreRepository: firestoreRepository,
                                              firebaseStorageRepository: firebaseStorageRepository)
        }
        
        container.register(VotePetpionUseCase.self) { _ in
            DefaultVotePetpionUseCase(firestoreRepository: firestoreRepository)
        }
        
        container.register(LoginUseCase.self) { _ in
            DefaultLoginUseCase(firebaseAuthRepository: firebaseAuthRepository)
        }
        
        container.register(UploadUserInfoUseCase.self) { _ in
            DefaultUploadUserInfoUseCase(firestoreRepository: firestoreRepository)
        }
    }
    
}
