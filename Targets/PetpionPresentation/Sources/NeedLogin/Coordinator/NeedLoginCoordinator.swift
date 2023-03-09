//
//  NeedLoginCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/17.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

enum LoginType {
    case signInWithApple
    case signInWithKakao
    case login
}

final class NeedLoginCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    weak var mainCoordinatorDelegate: MainCoordinatorDelegage?
    var navigationItemType: NavigationItemType?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let needLoginViewController = getNeedLoginViewController()
        needLoginViewController.coordinator = self
        navigationController.pushViewController(needLoginViewController, animated: true)
    }
    
    func presentLoginView() {
        let loginViewController = getLoginViewController()
        loginViewController.coordinator = self
        navigationController.present(loginViewController, animated: true)
    }
    
    func continueNavigationItemTypeScene() {
        guard let navigationItemType = navigationItemType else { return }
        
        var navigationItemTypeCoordinator: Coordinator!
        switch navigationItemType {
        case .myPage:
            navigationItemTypeCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "MyPageCoordinator")
        case .uploadFeed:
            navigationItemTypeCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "MyPageCoordinator")
        case .vote:
            navigationItemTypeCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "VoteMainCoordinator")
            childCoordinators.append(navigationItemTypeCoordinator)
            navigationItemTypeCoordinator.start()
        }
        
        navigationItemTypeCoordinator.start()
    }
    
    func pushSettingViewController() {
        guard let settingCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "SettingCoordinator") as? SettingCoordinator else { return }
        childCoordinators.append(settingCoordinator)
        settingCoordinator.start()
    }
    
    func pushInputProfileView(loginType: LoginType, firestoreUID: String?, kakaoUserID: String?) {
        let inputProfileViewController = getInputProfileViewController(loginType: loginType, firestoreUID: firestoreUID, kakaoUserID: kakaoUserID)
        inputProfileViewController.coordinator = self
        navigationController.pushViewController(inputProfileViewController, animated: true)
    }
    
    func presentProfileImagePickerViewController(parentableViewController: ProfileImagePickerViewControllerDelegate) {
        let profileImagePickerViewController = getProfileImagePickerViewController()
        profileImagePickerViewController.profileImagePickerViewControllerListener = parentableViewController
        navigationController.present(profileImagePickerViewController, animated: true)
    }
    
    func restart() {
        mainCoordinatorDelegate?.restart()
    }
}

extension NeedLoginCoordinator {
    private func getNeedLoginViewController() -> NeedLoginViewController {
        guard let navigationItemType = navigationItemType else {
            fatalError("getNeedLoginViewController occurred error")
        }
        let viewModel: NeedLoginViewModelProtocol = NeedLoginViewModel(navigationItemType: navigationItemType)
        return NeedLoginViewController(viewModel: viewModel)
    }
    
    private func getLoginViewController() -> LoginViewController {
        guard let loginUseCase: LoginUseCase = DIContainer.shared.resolve(LoginUseCase.self),
              let uploadUserUseCase: UploadUserUseCase = DIContainer.shared.resolve(UploadUserUseCase.self) else {
            fatalError("getLoginViewController did occurred error")
        }
        let viewModel: LoginViewModelProtocol = LoginViewModel(loginUseCase: loginUseCase, uploadUserUseCase: uploadUserUseCase)
        return LoginViewController(viewModel: viewModel)
    }

    private func getInputProfileViewController(loginType: LoginType, firestoreUID: String?, kakaoUserID: String?) -> InputProfileViewController {
        guard let loginUseCase: LoginUseCase = DIContainer.shared.resolve(LoginUseCase.self),
              let uploadUserUseCase: UploadUserUseCase = DIContainer.shared.resolve(UploadUserUseCase.self)
        else {
            fatalError("getInputProfileViewController did occurred error")
        }
        var viewModel: InputProfileViewModelProtocol = InputProfileViewModel(loginType: loginType, loginUseCase: loginUseCase, uploadUserUseCase: uploadUserUseCase)
        
        switch loginType {
        case .signInWithApple:
            viewModel.firestoreUID = firestoreUID
        case .signInWithKakao:
            viewModel.kakaoUserID = kakaoUserID
        case .login:
            fatalError("getInputProfileViewController did occurred error")
        }
        
        return InputProfileViewController(viewModel: viewModel)
    }
    
    private func getProfileImagePickerViewController() -> ProfileImagePickerViewController {
        return ProfileImagePickerViewController()
    }
}

protocol MainCoordinatorDelegage: NSObject {
    func restart()
}
