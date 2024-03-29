//
//  FetchUserUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/09.
//  Copyright © 2023 Petpion. All rights reserved.
//

public protocol FetchUserUseCase {
    
    var firestoreRepository: FirestoreRepository { get }
    var firebaseStorageRepository: FirebaseStorageRepository { get }
    
    func fetchUser(uid: String) async -> User
    func bindUser(completion: @escaping ((User) -> Void))
    func fetchBlockedUser(with userIDArray: [String]) async -> [User]
}
