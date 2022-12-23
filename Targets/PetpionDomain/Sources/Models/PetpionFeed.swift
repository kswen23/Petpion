//
//  PetpionFeed.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/14.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public struct PetpionFeed: Identifiable {
    
    public typealias Identifier = String
    
    public let id: Identifier
    public let uploaderID: User.ID
    public let uploadDate: Date
    public var battleCount: Int
    public var likeCount: Int
    public var imagesCount: Int
    public var message: String
    public var imageURLArr: [URL]?
    public var feedSize: CGSize
    public var imageRatio: Double
    
    public init(id: Identifier,
                uploaderID: User.ID,
                uploadDate: Date,
                battleCount: Int,
                likeCount: Int,
                imageCount: Int,
                message: String,
                feedSize: CGSize,
                imageRatio: Double) {
        self.id = id
        self.uploaderID = uploaderID
        self.uploadDate = uploadDate
        self.battleCount = battleCount
        self.likeCount = likeCount
        self.imagesCount = imageCount
        self.message = message
        self.feedSize = feedSize
        self.imageRatio = imageRatio
    }
    
}

public extension PetpionFeed {
    
    static func getImageReference(_ feed: Self) -> String {
        "\(feed.uploaderID)/\(feed.id)"
    }
}

extension PetpionFeed: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
