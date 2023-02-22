//
//  DefaultBlockUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/21.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public final class DefaultBlockUseCase: BlockUseCase {
    
    public var firestoreRepository: FirestoreRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    // MARK: - Public
    public func block<T>(blocked: T) async -> Bool {
        await firestoreRepository.uploadBlockList(blocked: blocked)
    }
    
    public func unblockUser(user: User) async -> Bool {
        await firestoreRepository.deleteBlockedUser(user)
    }
    
    public func getBlockedArray(type: ReportBlockType) async -> [String]? {
        await firestoreRepository.getUserActionArray(action: .block, type: type)
    }
}
