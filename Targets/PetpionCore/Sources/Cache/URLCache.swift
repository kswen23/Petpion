//
//  URLCache.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/12/16.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

public final class URLCache {
    
    public static let shared: URLCache = .init()
    
    let cachedURLs: NSCache<NSString, NSArray> = .init()
    
    public func urls(id: NSString) -> [URL]? {
        cachedURLs.object(forKey: id) as? [URL]
    }
    
    public func saveURLCache(urls: NSArray, key: NSString) {
        self.cachedURLs.setObject(urls, forKey: key)
    }
}
