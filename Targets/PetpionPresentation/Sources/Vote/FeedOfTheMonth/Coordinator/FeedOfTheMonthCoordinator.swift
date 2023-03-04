//
//  FeedOfTheMonthCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/03/04.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

final class FeedOfTheMonthCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var date: Date?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = getFeedOfTheMonthViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushUserPageView(with user: User) {
        guard let userPageCoordinator: UserPageCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "UserPageCoordinator") as? UserPageCoordinator else { return }
        userPageCoordinator.user = user
        userPageCoordinator.userPageStyle = .myPageWithOutSettings
        childCoordinators.append(userPageCoordinator)
        userPageCoordinator.start()
    }
    
    func pushPushableDetailFeedView(with feed: PetpionFeed) {
        guard let detailFeedCoordinator: DetailFeedCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "DetailFeedCoordinator") as? DetailFeedCoordinator else { return }
        detailFeedCoordinator.feed = feed
        detailFeedCoordinator.detailFeedStyle = .uneditableUserDetailFeed
        childCoordinators.append(detailFeedCoordinator)
        detailFeedCoordinator.start()
    }
}

private extension FeedOfTheMonthCoordinator {
    func getFeedOfTheMonthViewController() -> FeedOfTheMonthViewController {
        guard let targetDate = date,
              let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self) else {
            fatalError("getFeedOfTheMonthViewController occurred error")
        }
        let viewModel: FeedOfTheMonthViewModelProtocol = FeedOfTheMonthViewModel(targetDate: targetDate, fetchFeedUseCase: fetchFeedUseCase)
        return FeedOfTheMonthViewController(viewModel: viewModel)
    }
}
