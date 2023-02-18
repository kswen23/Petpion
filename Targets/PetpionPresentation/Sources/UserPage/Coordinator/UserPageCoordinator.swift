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
        guard let reportUserCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "ReportUserCoordinator") as? ReportUserCoordinator else { return }
        childCoordinators.append(reportUserCoordinator)
        let reportUserNavigationController = UINavigationController()
        reportUserCoordinator.navigationController = reportUserNavigationController
        reportUserCoordinator.start()
        navigationController.present(reportUserNavigationController, animated: true)
    }
}

private extension UserPageCoordinator {
    
    private func getUserPageViewController() -> UserPageViewController {
        guard let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self),
              let user = user,
              let userPageStyle = userPageStyle else {
            fatalError("getMyPageViewController did occurred error")
        }
        let viewModel: UserPageViewModelProtocol = UserPageViewModel(userPageStyle: userPageStyle, user: user, fetchFeedUseCase: fetchFeedUseCase)
        return UserPageViewController(viewModel: viewModel)
    }
    
}
