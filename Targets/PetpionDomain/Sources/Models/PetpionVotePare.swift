//
//  PetpionVotePare.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/12/22.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public struct PetpionVotePare: Hashable {
    
    public let topFeed: PetpionFeed
    public let bottomFeed: PetpionFeed
    
    init(topFeed: PetpionFeed, bottomFeed: PetpionFeed) {
        self.topFeed = topFeed
        self.bottomFeed = bottomFeed
    }
}
