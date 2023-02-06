//
//  LoginViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/03.
//  Copyright © 2023 Petpion. All rights reserved.
//

import AuthenticationServices
import Combine
import Foundation
import UIKit

final class LoginViewController: UIViewController {
    
    var viewModel: LoginViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .black)
        button.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        return button
    }()
    
    @objc private func handleAuthorizationAppleIDButtonPress() {
        viewModel.appleLoginButtonDidTapped(with: self)
    }
    // MARK: - Initialize
    init(viewModel: LoginViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutAppleLoginButton()
    }
    
    private func layoutAppleLoginButton() {
        self.view.addSubview(appleLoginButton)
        appleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appleLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            appleLoginButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            appleLoginButton.widthAnchor.constraint(equalToConstant: 300),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Binding
    private func binding() {
        bindCanDismissSubject()
    }
    
    private func bindCanDismissSubject() {
        viewModel.canDismissSubject
            .sink { canDismiss in
                if canDismiss {
                    self.dismiss(animated: true)
                }
            }.store(in: &cancellables)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        viewModel.signIn(authorization: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}
