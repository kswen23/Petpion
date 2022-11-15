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
    public let nickName: String
    public let profileImage: Data
    
    public init(id: String,
                nickName: String,
                profileImage: Data) {
        self.id = id
        self.nickName = nickName
        self.profileImage = profileImage
    }
}

public extension User {
    
    static let empty: Self = .init(id: "", nickName: "", profileImage: Data())
}
