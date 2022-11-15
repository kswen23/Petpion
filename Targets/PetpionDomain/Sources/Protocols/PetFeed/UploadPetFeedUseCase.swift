//
//  UploadPetFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/15.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public protocol UploadPetFeedUseCase {
 
    var firestoreRepository: FirestoreRepository { get }
    
    func uploadNewFeed(_ feed: PetpionFeed)
}
