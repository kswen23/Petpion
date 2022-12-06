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
    
    private let db = Firestore.firestore()
    private var query: Query?
    private var cursor: DocumentSnapshot?
    // MARK: - Create
    public func uploadNewFeed(_ feed: PetpionFeed) async -> Bool {
        return await withCheckedContinuation{ continuation in
            Task {
                let feedCollections: [String: Any] = FeedData.toKeyValueCollections(.init(feed: feed))
                db
                    .document(FirestoreCollection.feed.reference + "/\(feed.id)")
                    .setData(feedCollections) { error in
                        if let error = error {
                            print(error.localizedDescription)
                            continuation.resume(returning: false)
                        } else {
                            continuation.resume(returning: true)
                        }
                    }
            }
        }
    }
    
    // MARK: - Public Read
    public func fetchFeedData(by option: SortingOption) async -> Result<[PetpionFeed], Error> {
        var feedCollections = Result<[[String : Any]], Error>.success([[:]])
        
        //                if query == getQuery(by: option), cursor != nil {
        //                    feedCollections = await fetchFeedCollection(by: option)
        //                } else {
        //                    feedCollections = await fetchFirstFeedCollection(by: option)
        //                }
        feedCollections = await fetchFirstFeedCollection(by: option) // 임시 (무한스크롤로직 전까지)
        
        switch feedCollections {
        case .success(let collections):
            guard !collections.isEmpty else {
                // 데이터 없음
                return Result.success([])
            }
            let result = collections
                .map{ FeedData.toFeedData($0) }
                .map{ PetpionFeed.toPetpionFeed(data: $0) }
            return Result.success(result)
        case .failure(let failure):
            return Result.failure(failure)
        }
    }
    
    // MARK: - Private Read
    private func fetchFeedCollection(by option: SortingOption) async -> Result<[[String: Any]], Error> {
        
        return await withCheckedContinuation { [weak self] continuation in
            guard let strongSelf = self,
                  let query = query,
                  let cursor = cursor else { return }
            
            query.addSnapshotListener { (snapshot, error) in
                guard snapshot != nil else {
                    print("Error retreving feeds: \(error.debugDescription)")
                    return
                }
                
                query
                    .start(afterDocument: cursor)
                    .getDocuments { (snapshot, error) in
                        if let error = error {
                            continuation
                                .resume(returning: .failure(error))
                        } else {
                            if let result = snapshot?.documents {
                                continuation
                                    .resume(returning: .success(result.map { $0.data() }))
                            }
                        }
                        strongSelf.cursor = snapshot?.documents.last
                    }
            }
        }
    }
    
    private func fetchFirstFeedCollection(by option: SortingOption) async -> Result<[[String: Any]], Error> {
        return await withCheckedContinuation { [weak self] continuation in
            guard let strongSelf = self else { return }
            query = getQuery(by: option)
            strongSelf.query?
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        continuation
                            .resume(returning: .failure(error))
                    } else {
                        if let result = snapshot?.documents {
                            continuation
                                .resume(returning: .success(result.map { $0.data() }))
                        }
                    }
                    strongSelf.cursor = snapshot?.documents.last
                }
        }
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
                //                return "feeds/\(year)/\(month)"
                return "feeds/2022/11"
            }
        }
        
    }
    
    private func getQuery(by option: SortingOption) -> Query {
        switch option {
        case .popular:
            return db
                .collection(FirestoreCollection.feed.reference)
                .order(by: "likeCount", descending: true)
                .limit(to: 6)
        case .latest:
            return db
                .collection(FirestoreCollection.feed.reference)
                .order(by: "uploadTimestamp", descending: true)
                .limit(to: 6)
        }
    }
}
