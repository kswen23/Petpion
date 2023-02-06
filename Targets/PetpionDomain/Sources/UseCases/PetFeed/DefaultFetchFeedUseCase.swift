//
//  DefaultFetchFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

import PetpionCore

public final class DefaultFetchFeedUseCase: FetchFeedUseCase {
    
    public var firestoreRepository: FirestoreRepository
    public var firebaseStorageRepository: FirebaseStorageRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository,
         firebaseStorageRepository: FirebaseStorageRepository) {
        self.firestoreRepository = firestoreRepository
        self.firebaseStorageRepository = firebaseStorageRepository
    }
    
    // MARK: - Public
    public func fetchInitialFeedPerSortingOption() async -> [[PetpionFeed]] {
        let result = await withTaskGroup(of: (SortingOption, [PetpionFeed]).self) { taskGroup -> [[PetpionFeed]] in
            for option in SortingOption.allCases {
                taskGroup.addTask {
                    let fetchedFeed: [PetpionFeed] = await self.fetchFeed(isFirst: true, option: option)
                    return (option, fetchedFeed)
                }
            }
            var resultFeedArr = [[PetpionFeed]](repeating: [], count: SortingOption.allCases.count)
            for await taskResult in taskGroup {
                resultFeedArr[taskResult.0.rawValue] = taskResult.1
            }
            return resultFeedArr
        }
        return result
    }
    
    public func fetchFeed(isFirst: Bool, option: SortingOption) async -> [PetpionFeed] {
        var feedDataFromFirestore: [PetpionFeed] = .init()
        
        if isFirst {
            feedDataFromFirestore = await firestoreRepository.fetchFirstFeedArray(by: option)
        } else {
            feedDataFromFirestore = await firestoreRepository.fetchFeedArray(by: option)
        }
        
        let updatedFeed: [PetpionFeed] = await updateDetailInformation(feeds: feedDataFromFirestore)
        return sortResultFeeds(sortBy: option, with: updatedFeed)
    }
    
    public func fetchFeedDetailImages(feed: PetpionFeed) async -> [URL] {
        return await firebaseStorageRepository.fetchFeedTotalImageURL(feed)
    }
    
    public func fetchVotePareDetailImages(pare: PetpionVotePare) async -> PetpionVotePare {
        let result = await withTaskGroup(of: PetpionFeed.self) { taskGroup -> PetpionVotePare in
            for feed in [pare.topFeed, pare.bottomFeed] {
                taskGroup.addTask {
                    var resultFeed = feed
                    let urlArr = await self.fetchFeedDetailImages(feed: feed)
                    resultFeed.imageURLArr = (resultFeed.imageURLArr ?? []) + urlArr
                    return resultFeed
                }
            }
            var resultFeedArr = [PetpionFeed]()
            for await value in taskGroup {
                resultFeedArr.append(value)
            }
            return PetpionVotePare(topFeed: resultFeedArr[0],
                                   bottomFeed: resultFeedArr[1])
        }
        return result
    }
    
    public func fetchUserTotalFeeds(user: User) async -> [PetpionFeed] {
        let fetchedFeeds = await firestoreRepository.fetchFeedsWithUserID(with: user)
        
        return await withTaskGroup(of: PetpionFeed.self) { taskGroup -> [PetpionFeed] in
            for feed in fetchedFeeds {
                taskGroup.addTask {
                    return await self.addThumbnailImage(with: feed)
                }
            }
            var resultFeedArr = [PetpionFeed]()
            for await value in taskGroup {
                resultFeedArr.append(value)
            }
            return resultFeedArr
        }
    }
    
    public func updateFeeds(origin: [PetpionFeed]) async -> [PetpionFeed] {
        await withTaskGroup(of: PetpionFeed.self) { taskGroup -> [PetpionFeed] in
            for feed in origin {
                taskGroup.addTask {
                    let fetchedFeedWithFeedID = await self.firestoreRepository.fetchFeedWithFeedID(with: feed)
                    let countUpdatedFeed = await self.firestoreRepository.fetchFeedCounts(fetchedFeedWithFeedID)
                    let profileUpdatedFeed = await self.addUserProfile(with: countUpdatedFeed)
                    
                    var resultFeed = profileUpdatedFeed
                    resultFeed.thumbnailImage = feed.thumbnailImage
                    resultFeed.imageURLArr = feed.imageURLArr
                    return resultFeed
                }
            }
            var result = origin
            for await value in taskGroup {
                for i in 0 ..< result.count {
                    if value.id == result[i].id {
                        result[i] = value
                    }
                }
            }
            
            return result
        }
    }
    
    // MARK: - Private
    private func updateDetailInformation(feeds: [PetpionFeed]) async -> [PetpionFeed] {
        await withTaskGroup(of: PetpionFeed.self) { taskGroup -> [PetpionFeed] in
            for feed in feeds {
                taskGroup.addTask {
                    let countUpdatedFeed = await self.firestoreRepository.fetchFeedCounts(feed)
                    let profileUpdatedFeed = await self.addUserProfile(with: countUpdatedFeed)
                    let thumbnailUpdatedFeed = await self.addThumbnailImage(with: profileUpdatedFeed)
                    return thumbnailUpdatedFeed
                }
            }
            var resultFeedArr = [PetpionFeed]()
            for await value in taskGroup {
                resultFeedArr.append(value)
            }
            return resultFeedArr
        }
    }
    
    private func addThumbnailImage(with feed: PetpionFeed) async -> PetpionFeed {
        var resultFeed = await self.firestoreRepository.fetchFeedCounts(feed)
        resultFeed.imageURLArr = await self.firebaseStorageRepository.fetchFeedThumbnailImageURL(feed)
        if let thumbnailImageURL = resultFeed.imageURLArr?[0] {
            resultFeed.thumbnailImage = await ImageCache.shared.loadImage(url: thumbnailImageURL as NSURL)
        }
        return resultFeed
    }
    
    private func addUserProfile(with feed: PetpionFeed) async -> PetpionFeed {
        var user = await self.firestoreRepository.fetchUser(uid: feed.uploaderID)
        user.imageURL = await self.firebaseStorageRepository.fetchUserProfileImageURL(user)
        if let profileImageURL = user.imageURL {
            user.profileImage = await ImageCache.shared.loadImage(url: profileImageURL as NSURL)
        }
        var resultFeed = feed
        resultFeed.uploader = user
        return resultFeed
        
    }
    
    private func sortResultFeeds(sortBy option: SortingOption,
                                 with feeds: [PetpionFeed]) -> [PetpionFeed] {
        var resultFeeds = feeds
        switch option {
        case .popular:
            resultFeeds.sort { $0.likeCount > $1.likeCount }
        case .latest:
            resultFeeds.sort { $0.uploadDate > $1.uploadDate }
        }
        return resultFeeds
    }
    
}
