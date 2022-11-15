//
//  DefaultFirestoreRepository.swift
//  PetpionData
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import FirebaseFirestore
import PetpionDomain

public final class DefaultFirestoreRepository: FirestoreRepository {
    
    private let database = Firestore.firestore()
    
    // MARK: - Create
    public func createNewFeed(_ feed: PetpionFeed) async -> Result<String, Error> {
        
        let feed = [
            "feedID": feed.feedID
        ] as [String : Any]

        return await withCheckedContinuation { continuation in
            database
                .document(Document.feed.reference)
                .setData(feed) { error in
                    if let error = error {
                        continuation.resume(returning: .failure(error))
                    } else {
                        continuation.resume(returning: .success("NewFeed Saved!"))
                    }
                }
        }
    }
    
    public func fetchSomething() {
        print("petpionRepository start")
    }
    
}

extension DefaultFirestoreRepository {
    
    enum Document {
        case feed
        
        var reference: String {
            switch self {
            case .feed: return "app/feeds"
                
            }
        }
    }
}
