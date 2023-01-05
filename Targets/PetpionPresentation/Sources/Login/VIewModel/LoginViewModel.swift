//
//  File.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/03.
//  Copyright © 2023 Petpion. All rights reserved.
//

import AuthenticationServices
import Combine
import CryptoKit
import Foundation

import PetpionCore
import PetpionDomain

protocol LoginViewModelInput {
    func appleLoginButtonDidTapped(with viewController: UIViewController)
    func signIn(authorization: ASAuthorization)
}

protocol LoginViewModelOutput {
    
}

protocol LoginViewModelProtocol: LoginViewModelInput, LoginViewModelOutput {
    var loginUseCase: LoginUseCase { get }
    var uploadUserInfoUseCase: UploadUserInfoUseCase { get }
    
    var canDismissSubject: CurrentValueSubject<Bool, Never> { get }
}

final class LoginViewModel: LoginViewModelProtocol {
    
    let loginUseCase: LoginUseCase
    let uploadUserInfoUseCase: UploadUserInfoUseCase
    let canDismissSubject: CurrentValueSubject<Bool, Never> = .init(false)

    //MARK: - Initialize
    init(loginUseCase: LoginUseCase,
         uploadUserInfoUseCase: UploadUserInfoUseCase) {
        self.loginUseCase = loginUseCase
        self.uploadUserInfoUseCase = uploadUserInfoUseCase
    }
    
    fileprivate var currentNonce: String?
    
    //MARK: - Input
    func appleLoginButtonDidTapped(with viewController: UIViewController) {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = viewController as? ASAuthorizationControllerDelegate
        authorizationController.presentationContextProvider = viewController as? ASAuthorizationControllerPresentationContextProviding
        authorizationController.performRequests()
    }
    
    func signIn(authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            Task {
                let firebaseAuthResult = await loginUseCase.signInToFirebaseAuth(providerID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
                let loginResult: Bool = firebaseAuthResult.0
                let userUID: String = firebaseAuthResult.1
                let name = appleIDCredential.fullName?.description ?? ""
                
                if loginResult == true {
                    UserDefaults.standard.setValue(true, forKey: UserInfoKey.isLogin)
                    UserDefaults.standard.setValue(userUID, forKey: UserInfoKey.firebaseUID)
                    
                    uploadUserInfoUseCase.uploadNewUser(User.init(id: userUID, nickName: name, profileImage: .init()))
                    
                    await MainActor.run {
                        canDismissSubject.send(true)
                    }
                    
                    // 로그인 성공, 실패 여부 loginResult로 분기
                    // isLogIn 활성화 -> 개인별기능시 보여줄 View 가 다르다, 파베서버에 사용자 db 생성 그리고 dismiss
                }
            }
            
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
   
}
