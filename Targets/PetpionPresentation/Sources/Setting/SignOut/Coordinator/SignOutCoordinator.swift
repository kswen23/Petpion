//
//  SignOutCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/07.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

final class SignOutCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var mainCoordinatorDelegate: MainCoordinatorDelegage?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let signOutViewController = getSignOutViewController()
        signOutViewController.coordinator = self
        navigationController.pushViewController(signOutViewController, animated: true)
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }
    
    func restart() {
        mainCoordinatorDelegate?.restart()
    }
}

extension SignOutCoordinator {
    private func getSignOutViewController() -> SignOutViewController {
        guard let user = User.currentUser,
              let signOutUseCase: SignOutUseCase = DIContainer.shared.resolve(SignOutUseCase.self)
        else {
            fatalError("getSignOutViewController occurred error")
        }
        let viewModel: SignOutViewModelProtocol = SignOutViewModel(user: user, signOutUseCase: signOutUseCase)
        return SignOutViewController(viewModel: viewModel)
    }
}
