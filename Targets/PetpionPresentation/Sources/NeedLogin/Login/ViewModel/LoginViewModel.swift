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
    var uploadUserUseCase: UploadUserUseCase { get }
    
    var canDismissSubject: CurrentValueSubject<Bool, Never> { get }
}

final class LoginViewModel: LoginViewModelProtocol {
    
    let loginUseCase: LoginUseCase
    let uploadUserUseCase: UploadUserUseCase
    let canDismissSubject: CurrentValueSubject<Bool, Never> = .init(false)
    
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
            
            getCurrentAppleUserState(appleUserID: appleIDCredential.user)
            print(appleIDCredential.email)
            print(appleIDCredential.fullName)
            
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
    
    private func getCurrentAppleUserState(appleUserID: String) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: appleUserID) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                print("해당 ID는 연동되어있습니다.")
            case .revoked:
                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                print("해당 ID는 연동되어있지않습니다.")
            case .notFound:
                // The Apple ID credential is either was not found, so show the sign-in UI.
                print("해당 ID를 찾을 수 없습니다.")
            default:
                break
            }
        }
    }
}
