//
//  ImageCache.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/12/03.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

public final class ImageCache {
    
    public static let shared: ImageCache = .init()
    private let cachedImages: NSCache<NSURL, UIImage> = .init()
    
    // MARK: - Public Method
    public func loadImage(url: NSURL) async -> UIImage {
        return await withCheckedContinuation { continuation in
            Task {
                if let cachedImage = image(url: url) {
                    print("cached")
                    return continuation.resume(with: .success(cachedImage))
                }
                do {
                    let fetchedImage = try await fetchImage(url: url)
                    guard let imageDataCount = (fetchedImage.jpegData(compressionQuality: 0.8)?.count) else { return }
                    self.cachedImages.setObject(fetchedImage, forKey: url, cost: imageDataCount)
                    print("fetched")
                    return continuation.resume(with: .success(fetchedImage))
                } catch {
                    print("error")
                }
            }
        }
    }

    // MARK: - Private Method
    private func image(url: NSURL) -> UIImage? {
        cachedImages.object(forKey: url)
    }

    private func fetchImage(url: NSURL) async throws -> UIImage {
        
        let (data, response) = try await URLSession.shared.data(from: url as URL)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DownloadError.unknown
        }
        
        guard let image = UIImage(data: data) else {
            throw DownloadError.unknown
        }
        
        return image
    }
    
}

enum DownloadError: String, Error {
    case badImage = "badImage"
    case unknown = "unknown"
}
