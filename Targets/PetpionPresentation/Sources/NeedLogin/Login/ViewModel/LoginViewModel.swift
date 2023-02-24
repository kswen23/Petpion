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

import KakaoSDKAuth
import KakaoSDKUser
import PetpionCore
import PetpionDomain


protocol LoginViewModelInput {
    func appleLoginButtonDidTapped(with viewController: UIViewController)
    func kakaoLoginButtonDidTapped()
    func signIn(authorization: ASAuthorization)
    func setUserDefaultsUserValue(_ firestoreUID: String?)
}

protocol LoginViewModelOutput {
    
}

protocol LoginViewModelProtocol: LoginViewModelInput, LoginViewModelOutput {
    
    var loginUseCase: LoginUseCase { get }
    var uploadUserUseCase: UploadUserUseCase { get }
    
    var loginSubject: PassthroughSubject<(LoginType, String?), Never> { get }
}

final class LoginViewModel: LoginViewModelProtocol {
    
    let loginUseCase: LoginUseCase
    let uploadUserUseCase: UploadUserUseCase
    let loginSubject: PassthroughSubject<(LoginType, String?), Never> = .init()
    
    //MARK: - Initialize
    init(loginUseCase: LoginUseCase,
         uploadUserUseCase: UploadUserUseCase) {
        self.loginUseCase = loginUseCase
        self.uploadUserUseCase = uploadUserUseCase
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
    
    func kakaoLoginButtonDidTapped() {
        loginUseCase.getUserUIDWithKakao { [weak self] (FirestoreUIDIsExist, firestoreUID) in
            if FirestoreUIDIsExist == true {
                self?.loginSubject.send((.login, firestoreUID))
            } else {
                self?.loginSubject.send((.signInWithKakao, firestoreUID))
            }
        }
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
                
                guard let userUID = await loginUseCase.signInToFirebaseAuth(providerID: "apple.com", idToken: idTokenString, rawNonce: nonce) else { return }
                
                let userIsValid = await loginUseCase.checkUserIsValid(userUID)
                
                await MainActor.run {
                    if userIsValid == true {
                        loginSubject.send((.login, userUID))
                    } else {
                        loginSubject.send((.signInWithApple, userUID))
                    }
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
    
    func setUserDefaultsUserValue(_ firestoreUID: String?) {
        loginUseCase.setUserDefaults(firestoreUID: firestoreUID)
    }
}

