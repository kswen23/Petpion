//
//  MakeVoteListUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/12/21.
//  Copyright © 2022 Petpion. All rights reserved.
//

public protocol MakeVoteListUseCase {
    
    var firestoreRepository: FirestoreRepository { get } 
    var firebaseStorageRepository: FirebaseStorageRepository { get }
    
    func fetchVoteList(pare: Int) async -> [PetpionVotePare]
}
