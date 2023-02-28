//
//  PetpionHallCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

public final class PetpionHallCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let viewController = getPetpionHallViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
}

private extension PetpionHallCoordinator {
    
    func getPetpionHallViewController() -> PetpionHallViewController {
        guard let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self)
        else {
            fatalError("getPetpionHallViewController occurred error")
        }
        let viewModel: PetpionHallViewModelProtocol = PetpionHallViewModel(fetchFeedUseCase: fetchFeedUseCase)
        return PetpionHallViewController(viewModel: viewModel)
    }
}
