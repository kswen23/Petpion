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
    
    private let numberOfShards = 10
    private let firestoreUID = UserDefaults.standard.string(forKey: UserInfoKey.firebaseUID)
    
    // MARK: - Create
    public func uploadNewFeed(_ feed: PetpionFeed) async -> Bool {
        return await withCheckedContinuation { continuation in
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
    
    public func createCounters(_ feed: PetpionFeed) async -> Bool {
        let feedReference = db.collection(FirestoreCollection.feed.reference).document(feed.id)
        let battleCountReference = getFeedCountsReference(reference: feedReference, type: .battle)
        let likeCountReference = getFeedCountsReference(reference: feedReference, type: .like)
        
        let battleResult = await createDistributedCounter(to: battleCountReference)
        let likeResult = await createDistributedCounter(to: likeCountReference)
        
        if battleResult, likeResult == true {
            return true
        } else {
            return false
        }
    }
    
    public func uploadNewUser(_ user: User) {
        let userCollection: [String: Any] = UserData.toKeyValueCollections(.init(user: user))
        db
            .document(FirestoreCollection.user.reference + "/\(user.id)")
            .setData(userCollection) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
    }
    
    // MARK: - Private Create
    private func createDistributedCounter(to reference: DocumentReference) async -> Bool {
        let createDistributedCounterResult = await FirestoreDistributedCounter.createCounter(reference: reference, numberOfShards: numberOfShards)
        
        switch createDistributedCounterResult {
        case .success(let success):
            return success
        case .failure(let failure):
            print(failure.localizedDescription)
            return false
        }
    }
    
    // MARK: - Public Read
    public func fetchFirstFeedArray(by option: SortingOption) async -> Result<[PetpionFeed], Error> {
        let feedCollection = await fetchFirstFeedCollection(by: option)
        return convertCollectionToModel(feedCollection)
    }
    
    public func fetchFeedArray(by option: SortingOption) async -> Result<[PetpionFeed], Error> {
        guard getCursor(by: option) != nil else { return Result.success([]) }
        let feedCollection = await fetchFeedCollection(by: option)
        return convertCollectionToModel(feedCollection)
    }
    
    public func fetchRandomFeedArrayWithLimit(to count: Int) async -> [PetpionFeed] {
        let result = await withTaskGroup(of: Result<[PetpionFeed], Error>.self) { taskGroup -> [PetpionFeed] in
            for _ in 0 ..< count {
                taskGroup.addTask {
                    let singleCollection = await self.fetchSingleRandomFeedCollection()
                    return self.convertCollectionToModel(singleCollection)
                }
            }
            var resultArr: [PetpionFeed] = []
            for await value in taskGroup {
                switch value {
                case .success(let feed):
                    if feed.count == 1 {
                        resultArr.append(feed[0])
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            return resultArr
        }
        return result
        
    }
    
    public func fetchFeedCounts(_ feed: PetpionFeed) async -> PetpionFeed {
        var resultFeed = feed
        let feedReference = db.collection(FirestoreCollection.feed.reference).document(feed.id)
        
        let likeCount = await fetchCounts(reference: feedReference, type: .like)
        let battleCount = await fetchCounts(reference: feedReference, type: .battle)
        
        resultFeed.likeCount = likeCount
        resultFeed.battleCount = battleCount
        
        return resultFeed
    }
    
    public func fetchUser(uid: String) async -> User {
        return await withCheckedContinuation { continuation in
            db
                .collection(FirestoreCollection.user.reference)
                .document(uid)
                .getDocument { snapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    if let document = snapshot, let collectioin = document.data(), document.exists {
                        continuation.resume(returning: UserData.toUser(UserData.toUserData(collectioin)))
                    }
                }
            
        }
    }
    
    public func addUserListener(completion: @escaping ((User)-> Void)) {
        guard let uid = firestoreUID else { return }
            db
                .collection(FirestoreCollection.user.reference)
                .document(uid)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    if let document = querySnapshot, let collection = document.data() {
                        completion(UserData.toUser(UserData.toUserData(collection)))
                    }
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
    
    private func fetchSingleRandomFeedCollection() async -> Result<[[String: Any]], Error> {
        return await withCheckedContinuation { continuation in
            db
                .collection(FirestoreCollection.feed.reference)
                .whereField("random", isGreaterThanOrEqualTo: Int.random(in: 0..<Int.max))
                .limit(to: 1)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        continuation.resume(returning: .failure(error))
                    } else {
                        if let result = snapshot?.documents {
                            continuation.resume(returning: .success(result.map{ $0.data() }))
                        }
                    }
                }
            
        }
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
    
    private func fetchCounts(reference: DocumentReference, type: FeedCountsType) async -> Int {
        let result = await FirestoreDistributedCounter.getCount(reference: getFeedCountsReference(reference: reference, type: type))
        var count = 0
        switch result {
        case .success(let resultCount):
            count = resultCount
        case .failure(let failure):
            print(failure.localizedDescription)
            break
        }
        return count
    }
    
    // MARK: - Public Update
    public func updateFeedCounts(with feed: PetpionFeed, voteResult: VoteResult) async -> Bool {
        let feedReference = db.collection(FirestoreCollection.feed.reference).document(feed.id)
        
        let battleCountReference = getFeedCountsReference(reference: feedReference, type: .battle)
        let incrementBattleCountResult = await incrementCounts(to: battleCountReference)
        
        switch voteResult {
        case .selected:
            let likeCountReference = getFeedCountsReference(reference: feedReference, type: .like)
            let incrementLikeCountResult = await incrementCounts(to: likeCountReference)
            
            if incrementBattleCountResult, incrementLikeCountResult == true {
                return true
            } else {
                return false
            }
        case .deselected:
            return incrementBattleCountResult
        }
    }
    
    public func updateUserLatestVoteTime() {
        guard let uid = firestoreUID else { return }
        db
            .collection(FirestoreCollection.user.reference)
            .document(uid)
            .updateData(["latestVoteTime": Timestamp.init()]) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
    }
    
    public func updateUserHeart(_ count: Int) async -> Bool {
        guard let uid = firestoreUID else { return false }
        return await withCheckedContinuation { continuation in
            db
                .collection(FirestoreCollection.user.reference)
                .document(uid)
                .updateData(["voteChanceCount": count]) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        continuation.resume(returning: false)
                    }
                    continuation.resume(returning: true)
                }
        }
    }
    
    public func plusUserHeart() {
        guard let uid = firestoreUID else { return }
        db
            .collection(FirestoreCollection.user.reference)
            .document(uid)
            .updateData(["voteChanceCount": FieldValue.increment(Int64(+1))]) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        
    }
    
    public func minusUserHeart() {
        guard let uid = firestoreUID else { return }
        db
            .collection(FirestoreCollection.user.reference)
            .document(uid)
            .updateData(["voteChanceCount": FieldValue.increment(Int64(-1))]) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        
    }
    
    // MARK: - Private Update
    private func incrementCounts(to reference: DocumentReference) async -> Bool {
        let incrementResult = await FirestoreDistributedCounter.incrementCounter(by: 1, reference: reference, numberOfShards: numberOfShards)
        
        switch incrementResult {
        case .success(let success):
            return success
        case .failure(let failure):
            print(failure.localizedDescription)
            return false
        }
    }
    
}

extension DefaultFirestoreRepository {
    
    enum FirestoreCollection {
        case feed
        case user
        
        var reference: String {
            switch self {
            case .feed:
                guard let year = DateComponents.currentDateTimeComponents().year,
                      let month = DateComponents.currentDateTimeComponents().month else { return ""}
                //                return "feeds/\(year)/\(month)"
                return "feeds/2022/11"
            case .user:
                return "user"
            }
        }
    }
    
    enum FeedCountsType {
        case like
        case battle
    }
    
    private func getFeedCountsReference(reference: DocumentReference, type: FeedCountsType) -> DocumentReference {
        
        switch type {
        case .like:
            return reference.collection("counts").document("likeCounts")
        case .battle:
            return reference.collection("counts").document("battleCounts")
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
