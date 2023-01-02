//
//  PetpionVotePare.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/12/22.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public struct PetpionVotePare: Hashable {
    
    public let feed1: PetpionFeed
    public let feed2: PetpionFeed
    
    init(feed1: PetpionFeed, feed2: PetpionFeed) {
        self.feed1 = feed1
        self.feed2 = feed2
    }
}
