//
//  DefaultFirebaseStorageRepository.swift
//  PetpionData
//
//  Created by 김성원 on 2022/11/16.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

import FirebaseStorage
import PetpionCore
import PetpionDomain

public final class DefaultFirebaseStorageRepository: FirebaseStorageRepository {
    
    private let storage = Storage.storage()
    private let defaultURL: String = "gs://petpion.appspot.com/"
    private typealias DataAndReference = (Data, String)
    
    // MARK: - Private Method
    private func makeFeedDataAndReferenceArray(feed: PetpionFeed,
                                               imageDatas: [Data]) -> [DataAndReference] {
        var array: [DataAndReference] = []
        let imageRef: String = PetpionFeed.getImageReference(feed)
        for i in 0 ..< feed.imageCount {
            array.append((imageDatas[i], imageRef + "/\(i)"))
        }
        return array
    }
    
    private func makeUserDataAndReference(user: User) -> DataAndReference {
        return (User.getProfileImageData(user: user), "\(user.id)/profile/profile")
    }
    
    // MARK: - Public Create
    public func uploadPetFeedImages(feed: PetpionFeed,
                                    imageDatas: [Data]) async -> Bool {
        let dataAndRefArray: [DataAndReference] = makeFeedDataAndReferenceArray(feed: feed, imageDatas: imageDatas)
        return await uploadSeveralImages(dataAndRefArray)
    }
    
    public func uploadProfileImage(_ user: User) async -> Bool {
        let dataAndRef = makeUserDataAndReference(user: user)
        let isCompleted = await uploadSingleImage(dataAndRef)
        switch isCompleted {
        case .success(let success):
            URLCache.shared.deleteURLCache(key: dataAndRef.1)
            return success
        case .failure(let failure):
            print(failure.localizedDescription)
            return false
        }
    }
    
    // MARK: - Private Create
    private func uploadSeveralImages(_ dataAndRefArray: [DataAndReference]) async -> Bool {
        return await withTaskGroup(of: Result<Bool, Error>.self) { taskGroup -> Bool in
            for dataAndRef in dataAndRefArray {
                taskGroup.addTask {
                    return await self.uploadSingleImage(dataAndRef)
                }
            }

            let uploadResults: [Bool] = await taskGroup.reduce(into: [Bool]()) { partialResult, uploadResult in
                switch uploadResult {
                case .success(let success):
                    partialResult.append(success)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            if uploadResults.contains(false) {
                return false
            } else {
                return true
            }
        }
    }
    
    private func uploadSingleImage(_ dataAndRef: DataAndReference) async -> Result<Bool, Error> {
        return await withCheckedContinuation{ continuation in
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            storage
                .reference()
                .child(dataAndRef.1)
                .putData(dataAndRef.0, metadata: metadata) { result in
                    switch result {
                    case .success(_):
                        continuation.resume(returning: .success(true))
                    case .failure(let failure):
                        continuation.resume(returning: .failure(failure))
                    }
                }
        }
    }
    
    // MARK: - Public Read
    public func fetchFeedThumbnailImageURL(_ feed: PetpionFeed) async -> [URL] {
        let thumbnailFeedImageRef: String = "\(PetpionFeed.getImageReference(feed))/0"
        let thumbnailFeedImageURL = await fetchSingleImageURL(from: thumbnailFeedImageRef)
        
        switch thumbnailFeedImageURL {
        case .success(let url):
            return [url]
        case .failure(_):
            return []
        }
    }
    
    public func fetchFeedTotalImageURL(_ feed: PetpionFeed) async -> [URL] {
        
        if let cachedURLs = URLCache.shared.urls(id: feed.id) {
            return cachedURLs
        }
        
        let feedImageRef: String = PetpionFeed.getImageReference(feed)
        
        var imageReferences: [String] = []
        for i in 1 ..< feed.imageCount {
            imageReferences.append(feedImageRef + "/\(i)")
        }
        
        let totalImageURLResults = await fetchSeveralImageURLs(from: imageReferences)
        
        let totalImageURLs: [URL] =
        totalImageURLResults
            .map { imageURLResult -> URL? in
                switch imageURLResult {
                case .success(let url):
                    return url
                case .failure(let failure):
                    print(failure.localizedDescription)
                    return nil
                }
            }
            .compactMap { $0 }
        
        let sortedURLArr =
        totalImageURLs
            .map{ $0.description }
            .sorted(by: <)
            .map{ URL(string: $0)! }
        
        URLCache.shared.saveURLArrayCache(urls: sortedURLArr as NSArray, key: feed.id)
        return sortedURLArr
    }
    
    public func fetchUserProfileImageURL(_ user: User) async -> URL? {
        let profileImageReference = "\(user.id)/profile/profile"
        if let cachedURL = URLCache.shared.singleURL(id: profileImageReference) {
            return cachedURL
        }
        
        let profileURL = await fetchSingleImageURL(from: profileImageReference)
        switch profileURL {
        case .success(let url):
            URLCache.shared.saveURLCache(url: url, key: profileImageReference)
            return url
        case .failure(_):
            return nil
        }
    }
    
    // MARK: - Private Read
    private func fetchSeveralImageURLs(from references: [String]) async -> [Result<URL, Error>] {
        return await withTaskGroup(of: Result<URL,Error>.self) { taskGroup -> [Result<URL,Error>] in
            for reference in references {
                taskGroup.addTask {
                    let url = await self.fetchSingleImageURL(from: reference)
                    return url
                }
            }
            
            return await taskGroup.reduce(into: [Result<URL, Error>]()) { partialResult, imageURLResult in
                partialResult.append(imageURLResult)
            }
        }
    }
    
    private func fetchSingleImageURL(from reference: String) async -> Result<URL, Error> {
        return await withCheckedContinuation { continuation in
            if let cachedURL = URLCache.shared.singleURL(id: reference) {
                return continuation.resume(returning: .success(cachedURL))
            }
            storage
                .reference(forURL: defaultURL + reference)
                .downloadURL { result in
                    switch result {
                    case .success(let url):
                        URLCache.shared.saveURLCache(url: url, key: reference)
                        continuation.resume(returning: .success(url))
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }
        }
    }
    
    // MARK: - Public Delete
    public func deleteFeedImages(_ feed: PetpionFeed) async -> Bool {
        return await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            for i in 0 ..< feed.imageCount {
                let ref = "\(PetpionFeed.getImageReference(feed))/\(i)"
                taskGroup.addTask {
                    await self.deleteImage(ref)
                }
            }
            
            for await task in taskGroup {
                if task == false {
                    return false
                }
            }
            
            return true
        }
    }
    
    public func deleteUserImage(_ user: User) async -> Bool {
        let userReference = "\(user.id)/profile/profile"
        return await deleteImage(userReference)
    }
    
    // MARK: - Private Delete
    private func deleteImage(_ reference: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            storage
                .reference()
                .child(reference)
                .delete { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    continuation.resume(returning: true)
                }
        }
    }
}
