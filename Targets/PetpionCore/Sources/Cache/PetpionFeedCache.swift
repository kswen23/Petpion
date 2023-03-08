//
//  PetpionFeedCache.swift
//  PetpionCore
//
//  Created by 김성원 on 2023/03/06.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public final class PetpionFeedCache {
    
    public static let shared: PetpionFeedCache = .init()
    
    private let cachedTopPetpionFeed: NSCache<NSDate, AnyObject> = .init()
    
    public func cachedTopPetpionFeed(date: NSDate) -> AnyObject? {
        cachedTopPetpionFeed.object(forKey: date)
    }
    
    public func saveTopPetpionFeed(value: AnyObject, key: NSDate) {
        cachedTopPetpionFeed.setObject(value, forKey: key)
    }
    
}
