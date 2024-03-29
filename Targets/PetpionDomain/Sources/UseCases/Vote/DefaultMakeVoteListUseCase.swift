//
//  DefaultMakeVoteListUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/12/21.
//  Copyright © 2022 Petpion. All rights reserved.
//

public final class DefaultMakeVoteListUseCase: MakeVoteListUseCase {
    
    public var firestoreRepository: FirestoreRepository
    public var firebaseStorageRepository: FirebaseStorageRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository,
         firebaseStorageRepository: FirebaseStorageRepository) {
        self.firestoreRepository = firestoreRepository
        self.firebaseStorageRepository = firebaseStorageRepository
    }
    
    // MARK: - Public
    public func fetchVoteList(pare: Int, parentsTask: Task<Void, Never>) async -> [PetpionVotePare] {
        let randomFeedArr = await fetchRandomFeedArray(to: pare*2,
                                                       parentsTask: parentsTask)
        let randomFeedArrWithThumbnail = await addThumbnailImageURL(feeds: randomFeedArr)
        return makePetpionVotePare(with: randomFeedArrWithThumbnail.shuffled())
    }
    
    // MARK: - Private
    public func makePetpionVotePare(with feedArr: [PetpionFeed]) -> [PetpionVotePare] {
        let feedArrHalfCount = feedArr.count/2
        var result: [PetpionVotePare] = .init()
        for i in 0 ..< feedArrHalfCount {
            let secondIndex = i + feedArrHalfCount
            let pare: PetpionVotePare = .init(topFeed: feedArr[i],
                                              bottomFeed: feedArr[secondIndex])
            result.append(pare)
        }
        return result
    }

    private func fetchRandomFeedArray(to count: Int,
                                      parentsTask: Task<Void, Never>) async -> [PetpionFeed] {
        let randomFeeds = await firestoreRepository.fetchRandomFeedArrayWithLimit(to: count, parentsTask: parentsTask)
        var removeDuplicateRandomFeeds = removeDuplicate(with: randomFeeds)
        
        if removeDuplicateRandomFeeds.count < 2 {
            return []
        }
        
        var roopRunCount = 1
        
        while true {
            if roopRunCount == 20 {
                break
            }
            
            let neededFeedCount = count - removeDuplicateRandomFeeds.count
            if neededFeedCount == 0 {
                break
            }
            let neededFeeds = await firestoreRepository.fetchRandomFeedArrayWithLimit(to: neededFeedCount, parentsTask: parentsTask)
            removeDuplicateRandomFeeds = removeDuplicate(with: removeDuplicateRandomFeeds + neededFeeds)
            roopRunCount += 1
        }
        return removeDuplicateRandomFeeds
    }
    
    private func removeDuplicate(with array: [PetpionFeed]) -> [PetpionFeed] {
        let removedDuplicate: Set = Set(array)
        return Array(removedDuplicate)
    }
    
    private func addThumbnailImageURL(feeds: [PetpionFeed]) async -> [PetpionFeed] {
        let result = await withTaskGroup(of: PetpionFeed.self) { taskGroup -> [PetpionFeed] in
            for feed in feeds {
                taskGroup.addTask {
                    let urlArr = await self.firebaseStorageRepository.fetchFeedThumbnailImageURL(feed)
                    var withURLFeed = feed
                    withURLFeed.imageURLArr = urlArr
                    return withURLFeed
                }
            }
            var resultFeedArr = [PetpionFeed]()
            for await value in taskGroup {
                resultFeedArr.append(value)
            }
            return resultFeedArr
        }
        return result
    }

}
