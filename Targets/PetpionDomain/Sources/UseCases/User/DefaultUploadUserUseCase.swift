//
//  DefaultUploadUserUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/04.
//  Copyright © 2023 Petpion. All rights reserved.
//

public final class DefaultUploadUserUseCase: UploadUserUseCase {
    
    public var firestoreRepository: FirestoreRepository
    public var firebaseStorageRepository: FirebaseStorageRepository
    
    // MARK: - Initialize
    init(firestoreRepository: FirestoreRepository,
         firebaseStorageRepository: FirebaseStorageRepository) {
        self.firestoreRepository = firestoreRepository
        self.firebaseStorageRepository = firebaseStorageRepository
    }
    
    // MARK: - Public
    public func uploadNewUser(_ user: User) async -> Bool {
        let uploadUserProfileImageResult = await uploadUserProfileImage(user)
        let uploadUserProfileResult = await firestoreRepository.uploadNewUser(user)
        return uploadUserProfileResult && uploadUserProfileImageResult
    }
    
    public func uploadUserProfileImage(_ user: User) async -> Bool {
        guard user.profileImage != nil else { return true }
        return await firebaseStorageRepository.uploadProfileImage(user)
    }
    
    public func updateVoteChanceCount(_ count: Int) async -> Bool {
        await firestoreRepository.updateUserHeart(count)
    }
    
    public func updateUserNickname(_ nickname: String) async -> Bool {
        await firestoreRepository.updateUserNickname(nickname)
    }
    
    public func plusUserVoteChance() {
        firestoreRepository.plusUserHeart()
    }

    public func minusUserVoteChance() {
        firestoreRepository.minusUserHeart()
    }
    
    public func updateLatestVoteTime() {
        firestoreRepository.updateUserLatestVoteTime()
    }
    
    public func checkUserNicknameDuplication(with text: String,
                                             field: UserInformationField) async -> Bool {
        await firestoreRepository.checkDuplicatedFieldValue(with: text, field: field)
    }
}
