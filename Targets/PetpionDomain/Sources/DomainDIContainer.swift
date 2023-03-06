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
              let firebaseAuthRepository: FirebaseAuthRepository = container.resolve(FirebaseAuthRepository.self),
              let kakaoAuthRepository: KakaoAuthRepository = container.resolve(KakaoAuthRepository.self)
        else { return }
        
        container.register(FetchFeedUseCase.self) { _ in
            DefaultFetchFeedUseCase(firestoreRepository: firestoreRepository,
                                           firebaseStorageRepository: firebaseStorageRepository)
        }
        
        container.register(FetchUserUseCase.self) { _ in
            DefaultFetchUserUseCase(firestoreRepository: firestoreRepository,
                                    firebaseStorageRepository: firebaseStorageRepository)
        }
        
        container.register(DeleteFeedUseCase.self) { _ in
            DefaultDeleteFeedUseCase(firestoreRepository: firestoreRepository,
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
            DefaultLoginUseCase(firebaseAuthRepository: firebaseAuthRepository,
                                firestoreRepository: firestoreRepository,
                                kakaoAuthReporitory: kakaoAuthRepository)
        }
        
        container.register(UploadUserUseCase.self) { _ in
            DefaultUploadUserUseCase(firestoreRepository: firestoreRepository,
                                     firebaseStorageRepository: firebaseStorageRepository)
        }
        
        container.register(CalculateVoteChanceUseCase.self) { _ in
            DefaultCalculateVoteChanceUseCase(firestoreRepository: firestoreRepository)
        }
        
        container.register(CheckPreviousMonthRankingUseCase.self) { _ in
            DefaultCheckPreviousMonthRankingUseCase(firestoreRepository: firestoreRepository)
        }
        
        container.register(MakeNotificationUseCase.self) { _ in
            DefaultMakeNotificationUseCase()
        }
        
        container.register(ReportUseCase.self) { _ in
            DefaultReportUseCase(firestoreRepository: firestoreRepository)
        }
        
        container.register(BlockUseCase.self) { _ in
            DefaultBlockUseCase(firestoreRepository: firestoreRepository)
        }
        
        container.register(SignOutUseCase.self) { _ in
            DefaultSignOutUseCase(firestoreRepository: firestoreRepository, firebaseStorageRepository: firebaseStorageRepository, firebaseAuthRepository: firebaseAuthRepository)
        }
        
    }
}
