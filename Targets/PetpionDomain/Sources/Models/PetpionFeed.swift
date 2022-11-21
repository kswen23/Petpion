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
    public var likeCount: Int
    public var imagesCount: Int
    public var message: String?
    public var imageURLArr: [URL]?
    
    public init(id: Identifier,
                uploaderID: User.ID,
                uploadDate: Date,
                likeCount: Int,
                imageCount: Int,
                message: String = "",
                imageURLArr: [URL] = []) {
        self.id = id
        self.uploaderID = uploaderID
        self.uploadDate = uploadDate
        self.likeCount = likeCount
        self.imagesCount = imageCount
        self.message = message
        self.imageURLArr = imageURLArr
    }
    
}

public extension PetpionFeed {
    
    static func getImageReference(_ feed: Self) -> String {
        "\(feed.uploaderID)/\(feed.id)"
    }
}
