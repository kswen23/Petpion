//
//  ManageBlockedUserCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/21.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

final class ManageBlockedUserCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let manageBlockedUserViewController = getManageBlockedUserViewController()
        manageBlockedUserViewController.coordinator = self
        navigationController.pushViewController(manageBlockedUserViewController, animated: true)
    }
}

private extension ManageBlockedUserCoordinator {
    func getManageBlockedUserViewController() -> ManageBlockedUserViewController {
        guard let blockUseCase: BlockUseCase = DIContainer.shared.resolve(BlockUseCase.self) else {
            fatalError("getManageBlockedUserViewController occurred error")
        }
        let viewModel = ManageBlockedUserViewModel(blockUseCase: blockUseCase)
        return ManageBlockedUserViewController(viewModel: viewModel)
    }
}
