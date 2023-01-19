//
//  UserData.swift
//  PetpionData
//
//  Created by 김성원 on 2023/01/05.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import FirebaseFirestore
import PetpionDomain

struct UserData {
    public typealias Identifier = String
    
    public var userID: Identifier
    public var nickname: String
    public var latestVoteTimestamp: Timestamp
    public var voteChanceCount: Double
    
    public init(userID: Identifier, nickname: String, latestVoteTimestamp: Timestamp, voteChanceCount: Double) {
        self.userID = userID
        self.nickname = nickname
        self.latestVoteTimestamp = latestVoteTimestamp
        self.voteChanceCount = voteChanceCount
    }
    
    public init(user: User) {
        self.userID = user.id
        self.nickname = user.nickname
        self.latestVoteTimestamp = Timestamp.init()
        self.voteChanceCount = Double(user.voteChanceCount)
    }
    
}

extension UserData {
    
    static let empty: Self = .init(userID: "",
                                   nickname: "",
                                   latestVoteTimestamp: .init(),
                                   voteChanceCount: .nan)
    
    static func toKeyValueCollections(_ data: Self) -> [String: Any] {
        return [
            "userID": data.userID,
            "userNickname": data.nickname,
            "latestVoteTime": data.latestVoteTimestamp,
            "voteChanceCount": data.voteChanceCount
        ]
    }
    
    static func toUserData(_ data: [String: Any]) -> Self {
        var result: Self = .empty
        for (key, value) in data {
            switch key {
            case "userID": result.userID = value as? String ?? .init()
            case "userNickname": result.nickname = value as? String ?? ""
            case "latestVoteTime": result.latestVoteTimestamp = value as? Timestamp ?? Timestamp.init()
            case "voteChanceCount": result.voteChanceCount = value as? Double ?? 0
            default:
                break
            }
        }
        return result
    }

    static func toUser(_ data: Self) -> User {
        .init(id: data.userID,
              nickName: data.nickname,
              latestVoteTime: data.latestVoteTimestamp.dateValue(),
              voteChanceCount: Int(data.voteChanceCount),
              imageURL: nil)
    }
}
