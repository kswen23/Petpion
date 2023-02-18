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

final class NeedLoginCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
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
        guard let needLoginViewController = navigationController.visibleViewController as? NeedLoginViewController else { return }
        let loginViewController = getLoginViewController()
        loginViewController.modalPresentationStyle = .custom
        loginViewController.transitioningDelegate = needLoginViewController
        needLoginViewController.present(loginViewController, animated: true)
    }
    
    func pushSettingViewController() {
        guard let settingCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "SettingCoordinator") as? SettingCoordinator else { return }
        childCoordinators.append(settingCoordinator)
        settingCoordinator.start()
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
}
