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

final class LoginViewController: HasCoordinatorViewController {
    
    lazy var loginCoordinator: NeedLoginCoordinator? = {
        self.coordinator as? NeedLoginCoordinator
    }()
    
    var viewModel: LoginViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let petpionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = .init(named: "petpionLogo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var appleLoginButton: UIButton = {
        let button = makeLoginButton(backgroundColor: .black, logoImage: .init(named: "login_apple_symbol"), title: "AppleID로 계속하기", titleColor: .white, titleFont: .systemFont(ofSize: 17))
        button.addTarget(self, action: #selector(appleLoginButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var kakaoLoginButton: UIButton = {
        let button = makeLoginButton(backgroundColor: .init(hex: "FEE500"), logoImage: .init(named: "login_kakao_symbol"), title: "카카오로 계속하기", titleColor: .black, titleFont: .systemFont(ofSize: 17))
        button.addTarget(self, action: #selector(kakaoLoginButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = yValueRatio(20)
        return stackView
    }()
    
    @objc private func appleLoginButtonDidTapped() {
        viewModel.appleLoginButtonDidTapped(with: self)
    }
    
    @objc private func kakaoLoginButtonDidTapped() {
        viewModel.kakaoLoginButtonDidTapped()
    }
    
    // MARK: - Initialize
    init(viewModel: LoginViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.initializeTransition()
        
    }
    
    private func initializeTransition() {
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
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
        layoutPetpionLogoImageView()
        layoutLoginButtonStackView()
    }
    
    private func layoutPetpionLogoImageView() {
        view.addSubview(petpionImageView)
        NSLayoutConstraint.activate([
            petpionImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: yValueRatio(20)),
            petpionImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            petpionImageView.widthAnchor.constraint(equalToConstant: xValueRatio(190)),
            petpionImageView.heightAnchor.constraint(equalToConstant: yValueRatio(170))
        ])
    }
    
    private func layoutLoginButtonStackView() {
        [appleLoginButton, kakaoLoginButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
                button.heightAnchor.constraint(equalToConstant: yValueRatio(45))
            ])
            loginButtonStackView.addArrangedSubview(button)
        }
        
        view.addSubview(loginButtonStackView)
        loginButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButtonStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loginButtonStackView.topAnchor.constraint(equalTo: petpionImageView.bottomAnchor, constant: yValueRatio(10))
        ])
        
    }
    
    private func makeLoginButton(backgroundColor: UIColor,
                                 logoImage: UIImage?,
                                 title: String,
                                 titleColor: UIColor,
                                 titleFont: UIFont) -> UIButton {
        guard let logoImage = logoImage else { return UIButton() }
        let button = UIButton()
        button.backgroundColor = backgroundColor
        button.setImage(logoImage, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: view.frame.width*0.5)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = titleFont
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.roundCorners(cornerRadius: 10)
        return button
    }
    
    // MARK: - Binding
    private func binding() {
        bindUserUIDSubjectSubject()
    }
    
    private func bindUserUIDSubjectSubject() {
        viewModel.loginSubject.sink { [weak self] loginValue in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true)
            switch loginValue.0 {
            case .login:
                strongSelf.viewModel.setUserDefaultsUserValue(loginValue.1)
                strongSelf.loginCoordinator?.restart()
            case .signInWithApple:
                strongSelf.loginCoordinator?.pushInputProfileView(loginType: loginValue.0, firestoreUID: loginValue.1, kakaoUserID: nil)
            case .signInWithKakao:
                strongSelf.loginCoordinator?.pushInputProfileView(loginType: loginValue.0, firestoreUID: nil, kakaoUserID: loginValue.1)
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

extension LoginViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let loginPresentationController = CustomPresentationController(presentedViewController: presented, presenting: presenting)
        loginPresentationController.fractionalHeight = 0.4
        return loginPresentationController
    }
}
