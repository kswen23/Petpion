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
    public let uploader: User
    public let uploadDate: Date
    public var likeCount: Int
    public let images: [Data]?
    public var message: String?
    
    public init(id: Identifier,
                uploader: User,
                uploadDate: Date,
                likeCount: Int,
                images: [Data],
                message: String? = nil) {
        self.id = id
        self.uploader = uploader
        self.uploadDate = uploadDate
        self.likeCount = likeCount
        self.images = images
        self.message = message
    }
    
}

public extension PetpionFeed {
    static func getImageReference(_ feed: Self, number: Int) -> String {
        feed.uploader.id + "/" + feed.id + String(number)
    }
}
