//
//  DefaultFetchFeedUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

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
        return await addThumbnailImage(fetchedFeeds)
    }
    
    // MARK: - Private
    private func addThumbnailImage(_ feeds: [PetpionFeed]) async -> [PetpionFeed] {
        await withTaskGroup(of: PetpionFeed.self) { taskGroup -> [PetpionFeed] in
            for feed in feeds {
                taskGroup.addTask {
                    var resultFeed = await self.firestoreRepository.fetchFeedCounts(feed)
                    resultFeed.imageURLArr = await self.firebaseStorageRepository.fetchFeedThumbnailImageURL(feed)
                    return resultFeed
                }
            }
            var resultFeedArr = [PetpionFeed]()
            for await value in taskGroup {
                resultFeedArr.append(value)
            }
            return resultFeedArr
        }
    }
    
    private func updateDetailInformation(feeds: [PetpionFeed]) async -> [PetpionFeed] {
        await withTaskGroup(of: PetpionFeed.self) { taskGroup -> [PetpionFeed] in
            for feed in feeds {
                taskGroup.addTask {
                    let countUpdated = await self.firestoreRepository.fetchFeedCounts(feed)
                    let urlArr = await self.firebaseStorageRepository.fetchFeedThumbnailImageURL(feed)
                    var user = await self.firestoreRepository.fetchUser(uid: feed.uploaderID)
                    user.imageURL = await self.firebaseStorageRepository.fetchUserProfileImageURL(user)
                    var resultFeed = countUpdated
                    resultFeed.uploader = user
                    resultFeed.imageURLArr = urlArr
                    return resultFeed
                }
            }
            var resultFeedArr = [PetpionFeed]()
            for await value in taskGroup {
                resultFeedArr.append(value)
            }
            return resultFeedArr
        }
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
