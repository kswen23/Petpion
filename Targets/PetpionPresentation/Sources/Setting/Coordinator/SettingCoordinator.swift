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
    var user: User?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let settingViewController = getLoggedInSettingViewController()
        settingViewController.coordinator = self
        navigationController.pushViewController(settingViewController, animated: true)
    }
    
    func pushSettingActionScene(with action: SettingModel.SettingAction) {
        print(action)
    }
}

extension SettingCoordinator {
    private func getLoggedInSettingViewController() -> LoggedInSettingViewController {
        guard let user = user else {
            fatalError("getSettingViewController did occurred error")
        }
        let viewModel: LoggedInSettingViewModelProtocol = LoggedInSettingViewModel(user: user)
        return LoggedInSettingViewController(viewModel: viewModel)
    }
}
