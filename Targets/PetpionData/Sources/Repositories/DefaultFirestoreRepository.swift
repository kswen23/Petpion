//
//  DefaultFirestoreRepository.swift
//  PetpionData
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import FirebaseFirestore
import PetpionDomain
import PetpionCore

public final class DefaultFirestoreRepository: FirestoreRepository {
    
    private let database = Firestore.firestore()
    
    // MARK: - Create
    public func createNewFeed(_ feed: PetpionFeed) {
            
        let feedCollections: [String: Any] = FeedData.toKeyValueCollections(.init(feed: feed))

            database
                .document(FirestoreCollection.feed.reference + "/\(feed.id)")
                .setData(feedCollections) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
    }
    
    // MARK: - Read
    public func fetchFeeds() async -> Result<[PetpionFeed], Error> {

        return await withCheckedContinuation({ continuation in
            Task {
                let feedCollections = await fetchFeedsToCollection()
                switch feedCollections {
                case .success(let collections):
                    let result = collections
                        .map{ FeedData.toFeedData($0) }
                        .map{ PetpionFeed.toPetpionFeed(data: $0) }
                    continuation.resume(returning: .success(result))
                case .failure(let failure):
                    continuation.resume(returning: .failure(failure))
                }
            }
        })
    }
    
    private func fetchFeedsToCollection() async -> Result<([[String: Any]]), Error> {
        
        return await withCheckedContinuation({ continuation in
            database
                .collection(FirestoreCollection.feed.reference)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        continuation.resume(returning: .failure(error))
                    } else {
                        if let result = snapshot?.documents {
                            continuation.resume(returning: .success(result.map { $0.data() }))
                        }
                    }
                }
            
        })
    }
}

extension DefaultFirestoreRepository {
    
    enum FirestoreCollection {
        
        case feed
        
        var reference: String {
            switch self {
            case .feed:
                guard let year = DateComponents.currentDateTimeComponents().year,
                      let month = DateComponents.currentDateTimeComponents().month else { return ""}
                return "feeds/\(year)/\(month)"
                
            }
        }
        
    }
}
