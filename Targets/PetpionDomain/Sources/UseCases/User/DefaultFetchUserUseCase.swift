//
//  DefaultFetchUserUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/09.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public final class DefaultFetchUserUseCase: FetchUserUseCase {
    
    // MARK: - Initialize
    public var firestoreRepository: FirestoreRepository
    
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    // MARK: - Public
    public func fetchUser() async -> User {
        await firestoreRepository.fetchUser()
    }
}
