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
    private var popularCursor: DocumentSnapshot?
    private var latestCursor: DocumentSnapshot?
    
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
    public func fetchFirstFeedData(by option: SortingOption) async -> Result<[PetpionFeed], Error> {
        let feedCollection = await fetchFirstFeedCollection(by: option)
        return convertCollectionToModel(feedCollection)
    }
    
    public func fetchFeedData(by option: SortingOption) async -> Result<[PetpionFeed], Error> {
        guard getCursor(by: option) != nil else { return Result.success([]) }
        let feedCollection = await fetchFeedCollection(by: option)
        return convertCollectionToModel(feedCollection)
    }
    
    private func convertCollectionToModel(_ collection: Result<[[String : Any]], Error>) -> Result<[PetpionFeed], Error> {
        switch collection {
        case .success(let collections):
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
            guard let cursor = getCursor(by: option) else { return }
            let query = getQuery(by: option)
            
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
                                self?.setCursor(option: option, snapshot: result)
                                continuation
                                    .resume(returning: .success(result.map { $0.data() }))
                            }
                        }
                    }
            }
        }
    }
    
    private func fetchFirstFeedCollection(by option: SortingOption) async -> Result<[[String: Any]], Error> {
        return await withCheckedContinuation { [weak self] continuation in
            let query = getQuery(by: option)
            
            query
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        continuation
                            .resume(returning: .failure(error))
                    } else {
                        if let result = snapshot?.documents {
                            self?.setCursor(option: option, snapshot: result)
                            continuation
                                .resume(returning: .success(result.map { $0.data() }))
                        }
                    }
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
                .limit(to: 20)
        case .latest:
            return db
                .collection(FirestoreCollection.feed.reference)
                .order(by: "uploadTimestamp", descending: true)
                .limit(to: 20)
        }
    }
    
    private func setCursor(option: SortingOption, snapshot: [QueryDocumentSnapshot]) {
        switch option {
        case .popular:
            self.popularCursor = snapshot.last
        case .latest:
            self.latestCursor = snapshot.last
        }
    }
    
    private func getCursor(by option: SortingOption) -> DocumentSnapshot? {
        switch option {
        case .popular:
            return popularCursor
        case .latest:
            return latestCursor
        }
    }
}
