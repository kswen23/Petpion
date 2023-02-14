//
//  PetpionFeed.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/14.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

public struct PetpionFeed: Identifiable {
    
    public typealias Identifier = String
    
    public var id: Identifier
    public var uploader: User = .empty
    public let uploaderID: User.ID
    public let uploadDate: Date
    public var battleCount: Int
    public var likeCount: Int
    public var imageCount: Int
    public var message: String
    public var imageURLArr: [URL]?
    public var feedSize: CGSize
    public var imageRatio: Double
    
    public init(id: Identifier,
                uploader: User,
                uploaderID: User.ID,
                uploadDate: Date,
                battleCount: Int,
                likeCount: Int,
                imageCount: Int,
                message: String,
                feedSize: CGSize,
                imageRatio: Double) {
        self.id = id
        self.uploader = uploader
        self.uploaderID = uploaderID
        self.uploadDate = uploadDate
        self.battleCount = battleCount
        self.likeCount = likeCount
        self.imageCount = imageCount
        self.message = message
        self.feedSize = feedSize
        self.imageRatio = imageRatio
    }
    
}

public extension PetpionFeed {
    static let empty: Self = .init(id: "",
                                   uploader: User.empty,
                                   uploaderID: "",
                                   uploadDate: .init(),
                                   battleCount: 0,
                                   likeCount: 0,
                                   imageCount: 0,
                                   message: "",
                                   feedSize: .init(),
                                   imageRatio: 0)
    
    static func getImageReference(_ feed: Self) -> String {
        "\(feed.uploaderID)/\(feed.id)"
    }
}

extension PetpionFeed: Hashable {    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
