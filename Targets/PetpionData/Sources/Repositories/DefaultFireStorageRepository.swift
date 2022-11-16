//
//  DefaultFireStorageRepository.swift
//  PetpionData
//
//  Created by 김성원 on 2022/11/16.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

import FirebaseStorage
import PetpionDomain

public final class DefaultFirebaseStorageRepository: FirebaseStorageRepository {
    
    private let storage = Storage.storage()
    
    // MARK: - Create
    public func uploadPetFeedImages(_ feed: PetpionFeed) async -> Result<String, Error> {
        
        return await withCheckedContinuation ({ continuation in
            Task {
                guard let images = feed.images else { return }
                var imageUploadCount = 1
                for i in 0 ..< images.count {
                    let imageReference = PetpionFeed.getImageReference(feed,
                                                                       number: i)
                    let uploadSingleImage = await uploadSingleImage(images[i],
                                                                    on: imageReference)
                    switch uploadSingleImage {
                    case .success(let success):
                        imageUploadCount += 1
                        print("image\(i) uploaded")
                        if imageUploadCount == images.count {
                            continuation.resume(returning: .success("all image uploaded"))
                        }
                    case .failure(let failure):
                        continuation.resume(returning: .failure(failure))
                    }
                }
            }
            
        })
    }
    
    private func uploadSingleImage(_ data: Data, on reference: String) async -> Result<String, Error> {
        
        return await withCheckedContinuation { continuation in
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            storage
                .reference()
                .child(reference)
                .putData(data, metadata: metadata) { result in
                    switch result {
                    case .success(let success):
                        print(success)
                        continuation.resume(returning: .success("success"))
                    case .failure(let failure):
                        continuation.resume(returning: .failure(failure))
                    }
                }
        }
    }
}

