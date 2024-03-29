//
//  DefaultFetchUserUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/09.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore

public final class DefaultFetchUserUseCase: FetchUserUseCase {
    
    // MARK: - Initialize
    public var firestoreRepository: FirestoreRepository
    public var firebaseStorageRepository: FirebaseStorageRepository
    
    init(firestoreRepository: FirestoreRepository,
         firebaseStorageRepository: FirebaseStorageRepository) {
        self.firestoreRepository = firestoreRepository
        self.firebaseStorageRepository = firebaseStorageRepository
    }
    
    // MARK: - Public
    public func fetchUser(uid: String) async -> User {
        var fetchedUser = await firestoreRepository.fetchUser(uid: uid)
        fetchedUser.imageURL = await firebaseStorageRepository.fetchUserProfileImageURL(fetchedUser)
        fetchedUser.profileImage = await fetchUserProfileImage(user: fetchedUser)
        return fetchedUser
    }
    
    public func bindUser(completion: @escaping ((User) -> Void)) {
        firestoreRepository.addUserListener { user in
            var userResult = user
            userResult.imageURL = User.currentUser?.imageURL
            userResult.profileImage = User.currentUser?.profileImage
            completion(userResult)
        }
    }
    
    public func fetchBlockedUser(with userIDArray: [String]) async -> [User] {
        return await withTaskGroup(of: User.self) { taskGroup -> [User] in
            for userID in userIDArray {
                taskGroup.addTask {
                    await self.fetchUser(uid: userID)
                }
            }
            var resultUserArray: [User] = .init()
            for await value in taskGroup {
                resultUserArray.append(value)
            }
            return resultUserArray.sorted {
                $0.nickname < $1.nickname
            }
        }
    }
    
    // MARK: - Private
    private func fetchUserProfileImage(user: User) async -> UIImage {
        guard let profileURL = user.imageURL else {
            return User.defaultProfileImage
        }
        return await ImageCache.shared.loadImage(url: profileURL as NSURL)
    }

}
