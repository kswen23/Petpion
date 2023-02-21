//
//  User.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/14.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

public struct User: Identifiable {
    public typealias Identifier = String
    
    public let id: Identifier
    public var nickname: String
    public var latestVoteTime: Date
    public var voteChanceCount: Int
    public var imageURL: URL?
    public var profileImage: UIImage? = UIImage(systemName: "person.fill")
    
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
    static var currentUser: Self?
    static var reportedUserIDArray: [String]?
    static var reportedFeedIDArray: [String]?
    static var blockedUserIDArray: [String]?
    static var blockedFeedIDArray: [String]?
    
    static let isLogin: Bool = {
        currentUser != nil
    }()
    
    static func isReportedUser(user: User?) -> Bool {
        guard let reportedUserIDArray = User.reportedUserIDArray,
              let user = user
        else {
            fatalError("User.isReportedUser occurred error")
        }
        return reportedUserIDArray.contains(user.id)
    }
    
    static func isBlockedUser(user: User?) -> Bool {
        guard let blockedUserIDArray = User.blockedUserIDArray,
              let user = user
        else {
            fatalError("User.isBlockedUser occurred error")
        }
        return blockedUserIDArray.contains(user.id)
    }
    
    static func isReportedFeed(feed: PetpionFeed?) -> Bool {
        guard let reportedFeedIDArray = User.reportedFeedIDArray,
              let feed = feed
        else {
            fatalError("User.isReportedFeed occurred error")
        }
        return reportedFeedIDArray.contains(feed.id)
    }
    
    static func isBlockedFeed(feed: PetpionFeed?) -> Bool {
        guard let blockedFeedIDArray = User.blockedFeedIDArray,
              let feed = feed
        else {
            fatalError("User.isBlockedFeed occurred error")
        }
        return blockedFeedIDArray.contains(feed.id)
    }
    
    static let voteMaxCountPolicy: Int = 5
    
    static let empty: Self = .init(id: "", nickName: "", latestVoteTime: .init(), voteChanceCount: 0, imageURL: nil)
    
    static func getProfileImageData(user: Self) -> Data {
        user.profileImage?.jpegData(compressionQuality: 0.8) ?? Data()
    }
}

extension User: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
