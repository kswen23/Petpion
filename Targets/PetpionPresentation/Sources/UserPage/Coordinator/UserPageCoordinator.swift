//
//  MyPageCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

enum UserPageStyle {
    case myPageWithSettings
    case myPageWithOutSettings
    case otherUserPage
}

public final class UserPageCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    weak var mainCoordinatorDelegate: MainCoordinatorDelegage?
    var user: User?
    var userPageStyle: UserPageStyle?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let myPageViewController = getUserPageViewController()
        myPageViewController.coordinator = self
        navigationController.pushViewController(myPageViewController, animated: true)
    }
    
    func pushSettingViewController() {
        guard let settingCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "SettingCoordinator") as? SettingCoordinator else { return }
        settingCoordinator.mainCoordinatorDelegate = mainCoordinatorDelegate
        childCoordinators.append(settingCoordinator)
        settingCoordinator.start()
    }
    
    func pushDetailFeedViewController(selected feed: PetpionFeed, detailFeedStyle: DetailFeedStyle) {
        guard let detailFeedCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "DetailFeedCoordinator") as? DetailFeedCoordinator else { return }
        childCoordinators.append(detailFeedCoordinator)
        detailFeedCoordinator.feed = feed
        detailFeedCoordinator.detailFeedStyle = detailFeedStyle
        detailFeedCoordinator.start()
    }
    
    func presentReportUserViewController() {
        guard let reportCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "ReportCoordinator") as? ReportCoordinator else { return }
        childCoordinators.append(reportCoordinator)
        let reportUserNavigationController = UINavigationController()
        reportCoordinator.navigationController = reportUserNavigationController
        reportCoordinator.parentableNavigationController = navigationController
        reportCoordinator.reportBlockType = .user
        reportCoordinator.user = user
        reportCoordinator.start()
        navigationController.present(reportUserNavigationController, animated: true)
    }
}

private extension UserPageCoordinator {
    
    private func getUserPageViewController() -> UserPageViewController {
        guard let user = user,
              let userPageStyle = userPageStyle,
              let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self),
              let blockUseCase: BlockUseCase = DIContainer.shared.resolve(BlockUseCase.self)
               else {
            fatalError("getMyPageViewController did occurred error")
        }
        let viewModel: UserPageViewModelProtocol = UserPageViewModel(user: user, userPageStyle: userPageStyle, blockUseCase: blockUseCase, fetchFeedUseCase: fetchFeedUseCase)
        return UserPageViewController(viewModel: viewModel)
    }
    
}
