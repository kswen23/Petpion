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
    
    let cachedURLArray: NSCache<NSString, NSArray> = .init()
    let cachedURL: NSCache<NSString, NSURL> = .init()
    
    public func urls(id: String) -> [URL]? {
        cachedURLArray.object(forKey: id as NSString) as? [URL]
    }
    
    public func singleURL(id: String) -> URL? {
        cachedURL.object(forKey: id as NSString) as? URL
    }
    
    public func saveURLArrayCache(urls: NSArray, key: String) {
        self.cachedURLArray.setObject(urls as NSArray, forKey: key as NSString)
    }
    
    public func saveURLCache(url: URL, key: String) {
        self.cachedURL.setObject(url as NSURL, forKey: key as NSString)
    }
}
