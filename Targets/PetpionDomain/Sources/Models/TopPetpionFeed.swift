//
//  TopPetpionFeed.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/28.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public struct TopPetpionFeed {
    
    public let date: Date
    public var feedArray: [PetpionFeed]
    
    public init(date: Date, feedArray: [PetpionFeed]) {
        self.date = date
        self.feedArray = feedArray
    }

}

extension TopPetpionFeed: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
}
