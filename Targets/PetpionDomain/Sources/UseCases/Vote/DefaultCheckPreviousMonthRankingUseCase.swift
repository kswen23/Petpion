//
//  DefaultCheckPreviousMonthRankingUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public final class DefaultCheckPreviousMonthRankingUseCase: CheckPreviousMonthRankingUseCase {
    
    public var firestoreRepository: FirestoreRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository) {
        self.firestoreRepository = firestoreRepository
    }
    
    // MARK: - Public
    public func checkPreviousMonthRankingDidUpdated() async {
        guard await firestoreRepository.checkPreviousMonthRankingDidUpdated() == false else { return }
        if await updatePreviousMonthRanking() {
            uploadRankingUpdated()
        }
    }
    
    // MARK: - Private
    private func updatePreviousMonthRanking() async -> Bool {
        let result = await firestoreRepository.updatePreviousMonthTopFeeds()
        guard result.0 == true else { return false }
        firestoreRepository.updatePreviousMonthTopUsers(userIDArray: result.1)
        return true
    }
    
    private func uploadRankingUpdated() {
        firestoreRepository.uploadRankingUpdated()
    }

}
