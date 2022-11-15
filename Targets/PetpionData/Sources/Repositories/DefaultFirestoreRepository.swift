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
    public func createNewFeed(_ feed: PetpionFeed) async -> Result<String, Error> {

        let feedCollections: [String: Any] = FeedData.toKeyValueCollections(.init(feed: feed))
        
        return await withCheckedContinuation { continuation in
            database
                .document(Document.feed.reference + feed.id)
                .setData(feedCollections) { error in
                    if let error = error {
                        continuation.resume(returning: .failure(error))
                    } else {
                        continuation.resume(returning: .success("NewFeed Saved!"))
                    }
                }
        }
    }
}

extension DefaultFirestoreRepository {
    
    enum Document {
        
        case feed
        
        var reference: String {
            switch self {
            case .feed:
                guard let year = DateComponents.currentDateTimeComponents().year,
                      let month = DateComponents.currentDateTimeComponents().month else { return ""}
                return "feeds/\(year)/\(month)/"
                
            }
        }
        
    }
}
