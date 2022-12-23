//
//  FeedData.swift
//  Petpion
//
//  Created by 김성원 on 2022/11/15.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

import FirebaseFirestore
import PetpionDomain

struct FeedData {
    public typealias Identifier = String
    
    public var feedID: Identifier
    public var uploaderID: Identifier
    public var uploadTimestamp: Timestamp
    public var battleCount: Double
    public var likeCount: Double
    public var imageReference: String
    public var imageCount: Double
    public var message: String
    public var heightRatio: Double // width is 12
    public var imageRatio: Double
    
    
    public init(feedID: Identifier, uploaderID: Identifier, uploadTimestamp: Timestamp, battleCount: Double, likeCount: Double, imageCount: Double, message: String, heightRatio: Double, imageRatio: Double) {
        self.feedID = feedID
        self.uploaderID = uploaderID
        self.uploadTimestamp = uploadTimestamp
        self.battleCount = battleCount
        self.likeCount = likeCount
        self.imageCount = imageCount
        self.message = message
        self.heightRatio = heightRatio
        self.imageRatio = imageRatio
        self.imageReference = feedID + uploaderID
    }
    
    public init(feed: PetpionFeed) {
        self.feedID = feed.id
        self.uploaderID = feed.uploaderID
        self.uploadTimestamp = Timestamp.init()
        self.likeCount = Double(feed.likeCount)
        self.battleCount = Double(feed.battleCount)
        self.imageCount = Double(feed.imagesCount)
        self.message = feed.message
        self.imageReference = PetpionFeed.getImageReference(feed)
        self.heightRatio = feed.feedSize.height
        self.imageRatio = feed.imageRatio
    }
}

extension FeedData {
    
    static var empty: Self = .init(feedID: "",
                                   uploaderID: "",
                                   uploadTimestamp: .init(),
                                   battleCount: 0,
                                   likeCount: 0,
                                   imageCount: 0,
                                   message: "",
                                   heightRatio: 0,
                                   imageRatio: 0)
    
    static func toKeyValueCollections(_ data: Self) -> [String: Any] {
        return [
            "feedID": data.feedID,
            "uploaderID": data.uploaderID,
            "uploadTimestamp": data.uploadTimestamp,
            "battleCount": data.battleCount,
            "likeCount": data.likeCount,
            "imageReference": data.imageReference,
            "imageCount": data.imageCount,
            "message": data.message,
            "heightRatio": data.heightRatio,
            "imageRatio": data.imageRatio,
            "random": Int.random(in: 0..<Int.max)
        ]
    }
    
    static func toFeedData(_ data: [String: Any]) -> Self {
        var result: Self = .empty
        for (key, value) in data {
            switch key {
            case "feedID": result.feedID = value as? String ?? ""
            case "uploaderID": result.uploaderID = value as? String ?? ""
            case "uploadTimestamp": result.uploadTimestamp = value as? Timestamp ?? Timestamp.init()
            case "battleCount": result.battleCount = value as? Double ?? 0
            case "likeCount": result.likeCount = value as? Double ?? 0
            case "imageReference": result.imageReference = value as? String ?? ""
            case "imageCount": result.imageCount = value as? Double ?? 0
            case "message": result.message = value as? String ?? ""
            case "heightRatio": result.heightRatio = value as? Double ?? 0
            case "imageRatio": result.imageRatio = value as? Double ?? 0
            default:
                break
            }
        }
        return result
    }
}

extension PetpionFeed {
    
    static func toPetpionFeed(data: FeedData) -> PetpionFeed {
        .init(id: data.feedID,
              uploaderID: data.uploaderID,
              uploadDate: data.uploadTimestamp.dateValue(),
              battleCount: Int(data.battleCount),
              likeCount: Int(data.likeCount),
              imageCount: Int(data.imageCount),
              message: data.message,
              feedSize: CGSize(width: 12, height: data.heightRatio),
              imageRatio: data.imageRatio)
    }
}
