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
        container.register(FetchFeedUseCase.self) { resolver in
            DefaultFetchFeedUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!,
                                    firebaseStorageRepository: resolver.resolve(FirebaseStorageRepository.self)!)
        }
        
        container.register(FetchUserUseCase.self) { resolver in
            DefaultFetchUserUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!,
                                    firebaseStorageRepository: resolver.resolve(FirebaseStorageRepository.self)!)
        }
        
        container.register(DeleteFeedUseCase.self) { resolver in
            DefaultDeleteFeedUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!,
                                     firebaseStorageRepository: resolver.resolve(FirebaseStorageRepository.self)!)
        }
        
        container.register(UploadFeedUseCase.self) { resolver in
            DefaultUploadFeedUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!,
                                     firebaseStorageRepository: resolver.resolve(FirebaseStorageRepository.self)!)
        }
        
        container.register(MakeVoteListUseCase.self) { resolver in
            DefaultMakeVoteListUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!,
                                       firebaseStorageRepository: resolver.resolve(FirebaseStorageRepository.self)!)
        }
        
        container.register(VotePetpionUseCase.self) { resolver in
            DefaultVotePetpionUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!)
        }
        
        container.register(LoginUseCase.self) { resolver in
            DefaultLoginUseCase(firebaseAuthRepository: resolver.resolve(FirebaseAuthRepository.self)!,
                                firestoreRepository: resolver.resolve(FirestoreRepository.self)!,
                                kakaoAuthReporitory: resolver.resolve(KakaoAuthRepository.self)!)
        }
        
        container.register(UploadUserUseCase.self) { resolver in
            DefaultUploadUserUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!,
                                     firebaseStorageRepository: resolver.resolve(FirebaseStorageRepository.self)!)
        }
        
        container.register(CalculateVoteChanceUseCase.self) { resolver in
            DefaultCalculateVoteChanceUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!)
        }
        
        container.register(CheckPreviousMonthRankingUseCase.self) { resolver in
            DefaultCheckPreviousMonthRankingUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!)
        }
        
        container.register(MakeNotificationUseCase.self) { _ in
            DefaultMakeNotificationUseCase()
        }
        
        container.register(ReportUseCase.self) { resolver in
            DefaultReportUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!)
        }
        
        container.register(BlockUseCase.self) { resolver in
            DefaultBlockUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!)
        }
        
        container.register(SignOutUseCase.self) { resolver in
            DefaultSignOutUseCase(firestoreRepository: resolver.resolve(FirestoreRepository.self)!,
                                  firebaseStorageRepository: resolver.resolve(FirebaseStorageRepository.self)!,
                                  firebaseAuthRepository: resolver.resolve(FirebaseAuthRepository.self)!)
        }
    }

}
