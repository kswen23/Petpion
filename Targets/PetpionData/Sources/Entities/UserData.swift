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
    public var signInType: String
    public var kakaoID: String?
    public var first: Double
    public var second: Double
    public var third: Double
    
    public init(userID: Identifier, nickname: String, latestVoteTimestamp: Timestamp, voteChanceCount: Double, signInType: String, kakaoID: String?, first: Double, second: Double, third: Double) {
        self.userID = userID
        self.nickname = nickname
        self.latestVoteTimestamp = latestVoteTimestamp
        self.voteChanceCount = voteChanceCount
        self.signInType = signInType
        self.kakaoID = kakaoID
        self.first = first
        self.second = second
        self.third = third
    }
    
    public init(user: User) {
        self.userID = user.id
        self.nickname = user.nickname
        self.latestVoteTimestamp = Timestamp.init()
        self.voteChanceCount = Double(user.voteChanceCount)
        self.signInType = user.signInType.rawValue
        self.kakaoID = user.kakaoID
        self.first = Double(user.first)
        self.second = Double(user.second)
        self.third = Double(user.third)
    }
    
}

extension UserData {
    
    static let empty: Self = .init(userID: "",
                                   nickname: "",
                                   latestVoteTimestamp: .init(),
                                   voteChanceCount: .nan,
                                   signInType: "",
                                   kakaoID: nil,
                                   first: 0,
                                   second: 0,
                                   third: 0)
    
    static func toKeyValueCollections(_ data: Self) -> [String: Any] {
        return [
            "userID": data.userID,
            "userNickname": data.nickname,
            "latestVoteTime": data.latestVoteTimestamp,
            "voteChanceCount": data.voteChanceCount,
            "signInType": data.signInType,
            "kakaoID": data.kakaoID ?? "",
            "first": data.first,
            "second": data.second,
            "third": data.third
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
            case "signInType": result.signInType = value as? String ?? ""
            case "kakaoID": result.kakaoID = value as? String ?? ""
            case "first": result.first = value as? Double ?? 0
            case "second": result.second = value as? Double ?? 0
            case "third": result.third = value as? Double ?? 0
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
              imageURL: nil,
              signInType: configureSignInType(data.signInType),
              kakaoID: data.kakaoID,
              first: Int(data.first),
              second: Int(data.second),
              third: Int(data.third))
    }
    
    static func configureSignInType(_ signInType: String) -> SignInType {
        if signInType == "Apple" {
            return .appleID
        } else {
            return .kakaoID
        }
        
    }
}
