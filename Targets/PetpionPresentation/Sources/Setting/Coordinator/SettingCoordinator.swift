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

public final class SettingCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
//    var user: User?
    var user: User = .empty
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        if self.user != .empty {
            let settingViewController = getLoggedInSettingViewController()
            settingViewController.coordinator = self
            navigationController.pushViewController(settingViewController, animated: true)
        } else {
            let settingViewController = getLoggedOutSettingViewController()
            settingViewController.coordinator = self
            navigationController.pushViewController(settingViewController, animated: true)
        }
    }
    
    func startSettingActionScene(with action: SettingModel.SettingAction, user: User? = nil) {
        guard let settingActionCoordinator: Coordinator = DIContainer.shared.resolve(Coordinator.self, name: action.coordinatorString) else { return }
        if action == .profile {
            (settingActionCoordinator as! EditProfileCoordinator).user = user!
        }
        childCoordinators.append(settingActionCoordinator)
        settingActionCoordinator.start()
    }
}

extension SettingCoordinator {
    
    private func getLoggedInSettingViewController() -> LoggedInSettingViewController {
//        guard let user = user else {
//            fatalError("getLoggedInSettingViewController did occurred error")
//        }
        let viewModel: LoggedInSettingViewModelProtocol = LoggedInSettingViewModel(user: user)
        return LoggedInSettingViewController(viewModel: viewModel)
    }
    
    private func getLoggedOutSettingViewController() -> LoggedOutSettingViewController {
        return LoggedOutSettingViewController()
    }
}
