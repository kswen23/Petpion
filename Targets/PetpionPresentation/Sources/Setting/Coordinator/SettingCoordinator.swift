//
//  SettingCoordinator.swift
//  Petpion
//
//  Created by 김성원 on 2023/01/29.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

final class SettingCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var mainCoordinatorDelegate: MainCoordinatorDelegage?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        if User.isLogin() {
            let settingViewController = getLoggedInSettingViewController()
            settingViewController.coordinator = self
            navigationController.pushViewController(settingViewController, animated: true)
        } else {
            let settingViewController = getLoggedOutSettingViewController()
            settingViewController.coordinator = self
            navigationController.pushViewController(settingViewController, animated: true)
        }
    }
    
    func startSettingActionScene(with action: SettingModel.SettingAction) {
        guard let settingActionCoordinator: Coordinator = DIContainer.shared.resolve(Coordinator.self, name: action.coordinatorString) else { return }
        if let signOutCoordinator = settingActionCoordinator as? SignOutCoordinator {
            signOutCoordinator.mainCoordinatorDelegate = mainCoordinatorDelegate
            childCoordinators.append(signOutCoordinator)
            signOutCoordinator.start()
        } else {
            childCoordinators.append(settingActionCoordinator)
            settingActionCoordinator.start()
        }
    }
    
    func restart() {
        mainCoordinatorDelegate?.restart()
    }
}

extension SettingCoordinator {
    
    private func getLoggedInSettingViewController() -> LoggedInSettingViewController {
        guard let user = User.currentUser,
              let loginUseCase: LoginUseCase = DIContainer.shared.resolve(LoginUseCase.self)
        else {
            fatalError("getLoggedInSettingViewController did occurred error")
        }
        let viewModel: LoggedInSettingViewModelProtocol = LoggedInSettingViewModel(user: user, loginUseCase: loginUseCase)
        return LoggedInSettingViewController(viewModel: viewModel)
    }
    
    private func getLoggedOutSettingViewController() -> LoggedOutSettingViewController {
        return LoggedOutSettingViewController()
    }
}
