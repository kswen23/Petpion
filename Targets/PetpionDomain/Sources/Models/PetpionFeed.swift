//
//  Pet.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/14.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

public struct PetpionFeed {
    
    public let feedID: String
    public let uploader: User
    public let uploadDate: Date
    public var likeCount: Int
    public let images: [UIImage]
    public var message: String?
    
    public init(feedID: String,
                uploader: User,
                uploadDate: Date,
                likeCount: Int,
                images: [UIImage],
                message: String? = nil) {
        self.feedID = feedID
        self.uploader = uploader
        self.uploadDate = uploadDate
        self.likeCount = likeCount
        self.images = images
        self.message = message
    }
    
}
