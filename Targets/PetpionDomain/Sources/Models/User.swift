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
    public let latestVoteTime: Date
    public let voteChanceCount: Int
    public var imageURL: URL?
    
    public init(id: String,
                nickName: String,
                latestVoteTime: Date,
                voteChanceCount: Int,
                imageURL: URL?) {
        self.id = id
        self.nickname = nickName
        self.latestVoteTime = latestVoteTime
        self.voteChanceCount = voteChanceCount
        self.imageURL = imageURL
    }
}

public extension User {
    
    static let voteMaxCountPolicy: Int = 5
}

public extension User {
    
    static let empty: Self = .init(id: "", nickName: "", latestVoteTime: .init(), voteChanceCount: 0, imageURL: nil)
}

extension User: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
