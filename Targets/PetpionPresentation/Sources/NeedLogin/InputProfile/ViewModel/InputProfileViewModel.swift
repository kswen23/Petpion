//
//  EditProfileViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/24.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionCore
import PetpionDomain

protocol InputProfileViewModelInput {
    func changeCurrentProfileImage(_ image: UIImage)
    func checkNickNameValidate(nickname text: String) -> Bool
    func signIn()
    func checkUserNicknameDuplication(nickname: String)
}

protocol InputProfileViewModelOutput {
    
}

protocol InputProfileViewModelProtocol: InputProfileViewModelInput, InputProfileViewModelOutput {
    var loginType: LoginType { get }
    var firestoreUID: String? { get set }
    var kakaoUserID: String? { get set }
    var loginUseCase: LoginUseCase { get }
    var uploadUserUseCase: UploadUserUseCase { get }
    var inputProfileViewStateSubject: PassthroughSubject<InputProfileViewState, Never> { get }
}

enum InputProfileViewState {
    case startLoading
    case duplicatedNickname
    case startUpdating
    case finishUpdating
    case error
}

final class InputProfileViewModel: InputProfileViewModelProtocol {
    
    let loginType: LoginType
    let loginUseCase: LoginUseCase
    let uploadUserUseCase: UploadUserUseCase
    
    var firestoreUID: String?
    var kakaoUserID: String?
    
    let inputProfileViewStateSubject: PassthroughSubject<InputProfileViewState, Never> = .init()
    private var user: User = .empty
    
    // MARK: - Initialize
    init(loginType: LoginType,
         loginUseCase: LoginUseCase,
         uploadUserUseCase: UploadUserUseCase) {
        self.loginType = loginType
        self.loginUseCase = loginUseCase
        self.uploadUserUseCase = uploadUserUseCase
    }
    
    // MARK: - Input
    func signIn() {
        Task {
            switch loginType {
            case .signInWithApple:
                guard let firestoreUID = firestoreUID else {
                    fatalError("AppleSignIn Error")
                }
                await signInWithAppleID(firestoreUID: firestoreUID)
            case .signInWithKakao:
                guard let kakaoUserID = kakaoUserID else {
                    fatalError("KakaoSignIn Error")
                }
                await signInWithKakaoUserID(kakaoUserID: kakaoUserID)
            case .login:
                fatalError("Already signIn User")
            }
        }
    }
    
    func signInWithAppleID(firestoreUID: String) async {
        user.id = firestoreUID
        user.signInType = .appleID
        await uploadUserData()
    }
    
    func signInWithKakaoUserID(kakaoUserID: String) async {
        let signInResult = await loginUseCase.signInToFirebaseAuthWithEmail(providerEmail: "\(kakaoUserID)@kakao.com", providerID: kakaoUserID)
        if let signInResult = signInResult {
            user.id = signInResult
            user.kakaoID = kakaoUserID
            user.signInType = .kakaoID
            await uploadUserData()
        } else {
            await MainActor.run {
                inputProfileViewStateSubject.send(.error)
            }
        }
    }
        
    func changeCurrentProfileImage(_ image: UIImage) {
        user.profileImage = image
    }
    
    func checkNickNameValidate(nickname text: String) -> Bool {
        let nicknameRegex = "^[a-zA-Z가-힣0-9_]{3,10}$"
        let nicknameTest = NSPredicate(format:"SELF MATCHES %@", nicknameRegex)
        return nicknameTest.evaluate(with: text)
    }
    
    // MARK: - Output
    func checkUserNicknameDuplication(nickname: String) {
        inputProfileViewStateSubject.send(.startLoading)
        Task {
            let nickNameIsDuplicated = await uploadUserUseCase.checkUserNicknameDuplication(with: nickname, field: .nickname)
            
            await MainActor.run { [nickNameIsDuplicated] in
                if nickNameIsDuplicated {
                    inputProfileViewStateSubject.send(.duplicatedNickname)
                } else {
                    user.nickname = nickname
                    inputProfileViewStateSubject.send(.startUpdating)
                }
            }
            
        }
    }
    
    // MARK: - Private
    private func uploadUserData() async {
        let uploadResult = await uploadUserUseCase.uploadNewUser(user)
        await MainActor.run {
            if uploadResult == true {
                loginUseCase.setUserDefaults(firestoreUID: user.id)
                inputProfileViewStateSubject.send(.finishUpdating)
            } else {
                inputProfileViewStateSubject.send(.error)
            }
        }
    }
    
    

}
