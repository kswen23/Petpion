//
//  ReportData.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import FirebaseFirestore
import PetpionDomain

struct ReportUserData {
    let reporter: User
    let reportedUserID: User.ID
    let reportedUserNickName: String
    let reason: String
    let reportedTime: Timestamp
    
    init(reporter: User,
         reportedUser: User,
         reason: String) {
        self.reporter = reporter
        self.reportedUserID = reportedUser.id
        self.reportedUserNickName = reportedUser.nickname
        self.reason = reason
        self.reportedTime = Timestamp.init()
    }
    
    static func toKeyValueCollections(_ data: Self) -> [String: Any] {
        return [
            "reporterID": data.reporter.id,
            "reporterNickname": data.reporter.nickname,
            "reportedUserID": data.reportedUserID,
            "reportedUserNickName": data.reportedUserNickName,
            "reason": data.reason,
            "reportedTime": data.reportedTime
        ]
    }
}

struct ReportFeedData {
    let reporter: User
    let reportedFeedID: PetpionFeed.ID
    let reason: String
    let reportedTime: Timestamp
    
    init(reporter: User,
         reportedFeed: PetpionFeed,
         reason: String) {
        self.reporter = reporter
        self.reportedFeedID = reportedFeed.id
        self.reason = reason
        self.reportedTime = Timestamp.init()
    }
    
    static func toKeyValueCollections(_ data: Self) -> [String: Any] {
        return [
            "reporterID": data.reporter.id,
            "reporterNickname": data.reporter.nickname,
            "reportedFeedID": data.reportedFeedID,
            "reason": data.reason,
            "reportedTime": data.reportedTime
        ]
    }
}
