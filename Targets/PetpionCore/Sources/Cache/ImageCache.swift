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
                    return continuation.resume(with: .success(cachedImage))
                }
                do {
                    let fetchedImage = try await fetchImage(url: url)
                    saveImageCache(image: fetchedImage, key: url)
                    return continuation.resume(with: .success(fetchedImage))
                } catch ImageDownloadError.invalidServerResponse {
                    print("ImageDownloadError - invalidServerResponse")
                } catch ImageDownloadError.unsupportedImage {
                    print("ImageDownloadError - unsupportedImage")
                }
            }
        }
    }
    
    // MARK: - Private Method
    public func image(url: NSURL) -> UIImage? {
        cachedImages.object(forKey: url)
    }

    private func fetchImage(url: NSURL) async throws -> UIImage {
        
        let (data, response) = try await URLSession.shared.data(from: url as URL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ImageDownloadError.invalidServerResponse
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageDownloadError.unsupportedImage
        }
        
        return image
    }
    
    public func saveImageCache(image: UIImage, key: NSURL) {
        guard let imageDataCount = (image.jpegData(compressionQuality: 1.0)?.count) else { return }
        self.cachedImages.setObject(image, forKey: key, cost: imageDataCount)
    }
    
}

public enum ImageDownloadError: String, Error {
    case invalidServerResponse = "invalidServerResponse"
    case unsupportedImage = "unsupportedImage"
}
