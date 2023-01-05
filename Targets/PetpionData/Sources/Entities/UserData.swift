//
//  UserData.swift
//  PetpionData
//
//  Created by 김성원 on 2023/01/05.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import PetpionDomain

struct UserData {
    public typealias Identifier = String
    
    public var userID: Identifier
    public var nickname: String
    
    public init(userID: Identifier, nickname: String) {
        self.userID = userID
        self.nickname = nickname
    }
    
    public init(user: User) {
        self.userID = user.id
        self.nickname = user.nickname
    }
    
    static func toKeyValueCollections(_ data: Self) -> [String: Any] {
        return [
            "userID": data.userID,
            "userNickname": data.nickname
        ]
    }

}
