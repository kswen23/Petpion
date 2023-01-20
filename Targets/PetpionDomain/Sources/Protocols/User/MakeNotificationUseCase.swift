//
//  MakeNotificationUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/11.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public protocol MakeNotificationUseCase {
    
    func requestAuthorization()
    func createPetpionVoteNotification(heart count: Int, latestVoteTime: Date)
}
