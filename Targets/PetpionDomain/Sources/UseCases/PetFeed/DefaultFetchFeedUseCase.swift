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
        await withTaskGroup(of: (SortingOption, [PetpionFeed]).self) { taskGroup -> [[PetpionFeed]] in
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
    
    public func fetchSpecificMonthFeeds(with date: Date, isFirst: Bool) async -> [PetpionFeed] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        let fetchedFeeds = await firestoreRepository.fetchSpecificMonthPopularFeedArray(with: date, isFirst: isFirst)
        let updatedFeed: [PetpionFeed] = await updateDetailInformation(feeds: fetchedFeeds)
        let sortedResultFeeds = sortResultFeeds(sortBy: .popular, with: updatedFeed)
        return sortedResultFeeds
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
                    var resultFeed = await self.firestoreRepository.fetchFeedCounts(feed)
                    resultFeed.uploader = user
                    return await self.addThumbnailImage(with: resultFeed)
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
    
    public func fetchTopPetpionFeedForLast3Months(since date: Date) async -> [TopPetpionFeed] {
        await withTaskGroup(of: TopPetpionFeed.self, body: { taskGroup -> [TopPetpionFeed] in
            let last3MonthsDateArray: [Date] = self.makeLast3MonthsDateArray(date: date)
            var result = [TopPetpionFeed]()
            for month in last3MonthsDateArray {
                if let cachedTopPetpionFeed = PetpionFeedCache.shared.cachedTopPetpionFeed(date: month as NSDate) as? TopPetpionFeed {
                    result.append(cachedTopPetpionFeed)
                } else {
                    taskGroup.addTask {
                        var topPetpionFeed = await self.firestoreRepository.fetchTop3FeedDataForThisMonth(when: month)
                        topPetpionFeed.feedArray = await self.updateDetailInformation(feeds: topPetpionFeed.feedArray)
                        topPetpionFeed.feedArray.sort { $0.ranking! < $1.ranking! }
                        PetpionFeedCache.shared.saveTopPetpionFeed(value: topPetpionFeed as AnyObject, key: month as NSDate)
                        return topPetpionFeed
                    }
                }
            }
            
            for await taskResult in taskGroup {
                result.append(taskResult)
            }
                
            return result
                .filter { !$0.feedArray.isEmpty }
                .sorted { $0.date > $1.date }
        })
        
    }
    
    private func makeLast3MonthsDateArray(date: Date) -> [Date] {
        let calendar = Calendar.current
        let firstDayDateComponents: DateComponents = {
            var dateComponents: DateComponents = .dateToDateComponents(date)
            dateComponents.day = 1
            return dateComponents
        }()
        let firstDayDate: Date = calendar.date(from: firstDayDateComponents)!
        var last3MonthsDate = [Date]()
        for i in 1...3 {
            let beforeMonthDate = calendar.date(byAdding: .month, value: -i, to: firstDayDate)!
            last3MonthsDate.append(beforeMonthDate)
        }
        return last3MonthsDate
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
        var resultFeed = feed
        resultFeed.imageURLArr = await self.firebaseStorageRepository.fetchFeedThumbnailImageURL(feed)
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
            resultFeeds.sort { feed1, feed2 in
                if feed1.likeCount == feed2.likeCount {
                    return feed1.uploadDate < feed2.uploadDate
                }
                return feed1.likeCount > feed2.likeCount
            }
        case .latest:
            resultFeeds.sort { $0.uploadDate > $1.uploadDate }
        }
        return resultFeeds
    }
}
