//
//  DefaultFirebaseStorageRepository.swift
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
    private let defaultURL: String = "gs://petpion.appspot.com/"
    private typealias DataAndReference = (Data, String)
    
    // MARK: - Private Method
    private func makeDataAndReferenceArray(feed: PetpionFeed,
                                           imageDatas: [Data]) -> [DataAndReference] {
        var array: [DataAndReference] = []
        let imageRef: String = PetpionFeed.getImageReference(feed)
        for i in 0 ..< feed.imagesCount {
            array.append((imageDatas[i], imageRef + "/\(i)"))
        }
        return array
    }
    
    // MARK: - Public Create
    public func uploadPetFeedImages(feed: PetpionFeed,
                                    imageDatas: [Data]) async -> Bool {
        return await withCheckedContinuation{ continuation in
            Task {
                let dataAndRefArray: [DataAndReference] = makeDataAndReferenceArray(feed: feed, imageDatas: imageDatas)
                let isCompleted = await uploadSeveralImages(dataAndRefArray)
                switch isCompleted {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
    
    public func uploadProfileImage(_ user: User) {
        //        Task {
        //            uploadSingleImage()
        //        }
    }
    
    // MARK: - Private Create
    private func uploadSeveralImages(_ dataAndRefArray: [DataAndReference]) async -> Result<Bool, Error> {
        return await withCheckedContinuation{ continuation in
            Task {
                let uploadResult = await withTaskGroup(of: Result<Bool, Error>.self) { taskGroup -> Result<Bool, Error> in
                    for dataAndRef in dataAndRefArray {
                        taskGroup.addTask {
                            let uploadResult = await self.uploadSingleImage(dataAndRef)
                            return uploadResult
                        }
                    }
                    var successArr = [Bool]()
                    for await value in taskGroup {
                        switch value {
                        case .success(let success):
                            if success {
                                successArr.append(success)
                            }
                        case .failure(let error):
                            continuation.resume(returning: .failure(error))
                        }
                    }
                    
                    if successArr.count == dataAndRefArray.count {
                        return Result.success(true)
                    } else {
                        return Result.success(false)
                    }
                }
                continuation.resume(returning: uploadResult)
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
        return await withCheckedContinuation{ continuation in
            Task {
                let thumbnailFeedImageRef: String = "\(PetpionFeed.getImageReference(feed))/0"
                let thumbnailFeedImageURL = await fetchSingleImageURL(from: thumbnailFeedImageRef)

                switch thumbnailFeedImageURL {
                case .success(let url):
                    continuation.resume(returning: [url])
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
    
    public func fetchFeedTotalImageURL(_ feed: PetpionFeed) async -> [URL] {
        return await withCheckedContinuation{ continuation in
            Task {
                let feedImageRef: String = PetpionFeed.getImageReference(feed)
                
                var imageReferences: [String] = []
                for i in 1 ..< feed.imagesCount {
                    imageReferences.append(feedImageRef + "/\(i)")
                }
                
                let totalImageURLs = await fetchSeveralImageURLs(from: imageReferences)
                var urlArr: [URL] = []
                for value in totalImageURLs {
                    switch value {
                    case .success(let url):
                        urlArr.append(url)
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
                let sortedURLArr = urlArr
                    .map{ $0.description }
                    .sorted(by: <)
                    .map{ URL(string: $0)! }
                
                continuation.resume(returning: sortedURLArr)
            }
        }
    }
    
    // MARK: - Private Read
    private func fetchSeveralImageURLs(from references: [String]) async -> [Result<URL, Error>] {
        
        return await withCheckedContinuation { continuation in
            Task {
                let result = await withTaskGroup(of: Result<URL,Error>.self) { taskGroup -> [Result<URL,Error>] in
                    for reference in references {
                        taskGroup.addTask {
                            let url = await self.fetchSingleImageURL(from: reference)
                            return url
                        }
                    }
                    var resultArr: [Result<URL,Error>] = []
                    for await value in taskGroup {
                        switch value {
                        case .success(let url):
                            resultArr.append(Result.success(url))
                        case .failure(let error):
                            resultArr.append(Result.failure(error))
                        }
                    }
                    return resultArr
                }
                continuation.resume(returning: result)
            }
        }
    }
    
    private func fetchSingleImageURL(from reference: String) async -> Result<URL, Error> {
        
        return await withCheckedContinuation { continuation in
            storage
                .reference(forURL: defaultURL + reference)
                .downloadURL { result in
                    switch result {
                    case .success(let url):
                        continuation.resume(returning: .success(url))
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }
        }
    }
    
}
