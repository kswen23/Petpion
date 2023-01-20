//
//  FirestoreDistributedCounter.swift
//  PetpionData
//
//  Created by 김성원 on 2023/01/05.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import FirebaseFirestore

struct FirestoreDistributedCounterKey {
    static let numShards = "numShards"
    static let shards = "shards"
    static let count = "count"
}

final class FirestoreDistributedCounter {
    
    static func createCounter(reference: DocumentReference, numberOfShards: Int) async -> Result<Bool, Error> {
        return await withCheckedContinuation { continuation in
            let batch = Firestore.firestore().batch()
            
            batch.setData([FirestoreDistributedCounterKey.numShards: numberOfShards], forDocument: reference)
            
            for i in 0 ..< numberOfShards {
                let shardReference = reference.collection(FirestoreDistributedCounterKey.shards).document(String(i))
                batch.setData([FirestoreDistributedCounterKey.count: 0], forDocument: shardReference)
            }
            batch.commit { error in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                }
                continuation.resume(returning: .success(true))
            }
        }
    }
    
    static func incrementCounter(by num: Int, reference: DocumentReference, numberOfShards: Int) async -> Result<Bool, Error> {
        return await withCheckedContinuation { continuation in
            let shardId = Int(arc4random_uniform(UInt32(numberOfShards - 1)))
            let shardRef = reference.collection(FirestoreDistributedCounterKey.shards).document(String(shardId))
            
            shardRef.updateData([
                FirestoreDistributedCounterKey.count: FieldValue.increment(Int64(num))
            ]) { error in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                } else {
                    continuation.resume(returning: .success(true))
                }
            }
        }
    }
    
    static func getCount(reference: DocumentReference) async -> Result<Int, Error> {
        return await withCheckedContinuation { continuation in
            reference.collection(FirestoreDistributedCounterKey.shards).getDocuments { querySnapshot, error in
                var totalCount = 0
                
                if let error = error {
                    continuation.resume(returning: .failure(error))
                }
                
                if let result = querySnapshot?.documents {
                    for document in result {
                        guard let count = document.data()[FirestoreDistributedCounterKey.count] as? Int else { return }
                        totalCount += count
                    }
                    continuation.resume(returning: .success(totalCount))
                }
            }
        }
    }
}
