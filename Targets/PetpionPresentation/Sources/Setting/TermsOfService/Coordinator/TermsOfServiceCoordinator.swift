//
//  TermsOfServiceCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/03/08.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

final class TermsOfServiceCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var mainCoordinatorDelegate: MainCoordinatorDelegage?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = gettermsOfServiceViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
}
private extension TermsOfServiceCoordinator {
    func gettermsOfServiceViewController() -> TermsOfServiceViewController {
        TermsOfServiceViewController()
    }
}
