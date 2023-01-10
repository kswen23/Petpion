//
//  User.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/14.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public struct User: Identifiable {
    public typealias Identifier = String
    
    public let id: Identifier
    public let nickname: String
    public let profileImage: Data
    public let latestVoteTime: Date
    public let voteChanceCount: Int
    
    public init(id: String,
                nickName: String,
                profileImage: Data,
                latestVoteTime: Date,
                voteChanceCount: Int) {
        self.id = id
        self.nickname = nickName
        self.profileImage = profileImage
        self.latestVoteTime = latestVoteTime
        self.voteChanceCount = voteChanceCount
    }
}

public extension User {
    
    static let voteMaxCountPolicy: Int = 5
}

public extension User {
    
    static let empty: Self = .init(id: "", nickName: "", profileImage: .init(), latestVoteTime: .init(), voteChanceCount: 0)
}
