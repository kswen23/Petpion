//
//  BlockData.swift
//  PetpionData
//
//  Created by 김성원 on 2023/02/21.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import FirebaseFirestore
import PetpionDomain

struct BlockUserData {
    let blockedUserID: User.ID
    let blockedTime: Timestamp
    
    init(blockedUser: User) {
        self.blockedUserID = blockedUser.id
        self.blockedTime = Timestamp.init()
    }
    
    static func toKeyValueCollections(_ data: Self) -> [String: Any] {
        return [
            "blockedUserID": data.blockedUserID,
            "blockedTime": data.blockedTime
        ]
    }
}

struct BlockFeedData {
    let blockedFeedID: PetpionFeed.ID
    let blockedTime: Timestamp
    
    init(blockedFeed: PetpionFeed) {
        self.blockedFeedID = blockedFeed.id
        self.blockedTime = Timestamp.init()
    }
    
    static func toKeyValueCollections(_ data: Self) -> [String: Any] {
        return [
            "blockedFeedID": data.blockedFeedID,
            "blockedTime": data.blockedTime
        ]
    }
}
