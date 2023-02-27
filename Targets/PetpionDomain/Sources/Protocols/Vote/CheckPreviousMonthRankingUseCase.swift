//
//  CheckPreviousMonthRanking.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public protocol CheckPreviousMonthRankingUseCase {
    
    var firestoreRepository: FirestoreRepository { get }

    func checkPreviousMonthRankingDidUpdated() async
}
