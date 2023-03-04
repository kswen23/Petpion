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
    
    func pushUserPageView(with user: User) {
        guard let userPageCoordinator: UserPageCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "UserPageCoordinator") as? UserPageCoordinator else { return }
        userPageCoordinator.user = user
        userPageCoordinator.userPageStyle = .myPageWithOutSettings
        userPageCoordinator.start()
    }
    
    func pushPushableDetailFeedView(with feed: PetpionFeed) {
        guard let detailFeedCoordinator: DetailFeedCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "DetailFeedCoordinator") as? DetailFeedCoordinator else { return }
        detailFeedCoordinator.feed = feed
        detailFeedCoordinator.detailFeedStyle = .uneditableUserDetailFeed
        detailFeedCoordinator.start()
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
