//
//  AppCoordinator.swift
//  Petpion
//
//  Created by 김성원 on 2022/11/07.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

public final class MainCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let viewController = getMainViewController()
        viewController.coordinator = self
        navigationController.delegate = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentFeedImagePicker() {
        if User.isLogin == true {
            guard let feedImagePickerCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "FeedImagePickerCoordinator") as? FeedImagePickerCoordinator else { return }
            feedImagePickerCoordinator.parentCoordinator = self
            childCoordinators.append(feedImagePickerCoordinator)
            feedImagePickerCoordinator.start()
            navigationController.present(feedImagePickerCoordinator.navigationController, animated: true)
        } else {
            pushNeedLoginView(navigationItemType: .uploadFeed)
        }
    }
    
    func presentDetailFeed(transitionDependency: FeedTransitionDependency, feed: PetpionFeed) {
        guard let detailFeedCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "DetailFeedCoordinator") as? DetailFeedCoordinator else { return }
        detailFeedCoordinator.feed = feed
        detailFeedCoordinator.detailFeedStyle = DetailFeedStyle.otherUserDetailFeed
        childCoordinators.append(detailFeedCoordinator)
        detailFeedCoordinator.presentDetailFeedView(transitionDependency: transitionDependency)
    }
    
    
    func pushVoteMainView() {
        if User.isLogin == true {
            guard let voteMainCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "VoteMainCoordinator") as? VoteMainCoordinator else { return }
            childCoordinators.append(voteMainCoordinator)
            voteMainCoordinator.start()
        } else {
            pushNeedLoginView(navigationItemType: .vote)
        }
    }
    
    func pushUserPageView(user: User?, userPageStyle: UserPageStyle) {
        if User.isLogin == false, userPageStyle == .myPageWithSettings {
            return pushNeedLoginView(navigationItemType: .myPage)
        }
        guard let userPageCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "UserPageCoordinator") as? UserPageCoordinator else { return }
        childCoordinators.append(userPageCoordinator)
        userPageCoordinator.user = user
        if User.isLogin == true {
            userPageCoordinator.userPageStyle = userPageStyle
        } else {
            userPageCoordinator.userPageStyle = .myPageWithOutSettings
        }
        userPageCoordinator.start()
    }
    
    private func pushNeedLoginView(navigationItemType: NavigationItemType) {
        guard let needLoginCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "NeedLoginCoordinator") as? NeedLoginCoordinator else { return }
        needLoginCoordinator.navigationItemType = navigationItemType
        childCoordinators.append(needLoginCoordinator)
        needLoginCoordinator.start()
    }
}

extension MainCoordinator: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from), !navigationController.viewControllers.contains(fromViewController) else {
            return
        }
        
        if let hasCoordinatorViewController = fromViewController as? CoordinatorWrapper {
            if let parentsCoordinatorWrapper = viewController as? CoordinatorWrapper {
                parentsCoordinatorWrapper.coordinator?.childDidFinish(hasCoordinatorViewController.coordinator)
            }
            
        }
    }
}

private extension MainCoordinator {
    
    private func getMainViewController() -> MainViewController {
        guard let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self),
              let fetchUserUseCase: FetchUserUseCase = DIContainer.shared.resolve(FetchUserUseCase.self),
              let calculateVoteChanceUseCase: CalculateVoteChanceUseCase = DIContainer.shared.resolve(CalculateVoteChanceUseCase.self),
              let reportUseCase: ReportUseCase = DIContainer.shared.resolve(ReportUseCase.self)
        else {
            fatalError("getMainViewController did occurred error")
        }
        let viewModel: MainViewModelProtocol = MainViewModel(fetchFeedUseCase: fetchFeedUseCase, fetchUserUseCase: fetchUserUseCase, calculateVoteChanceUseCase: calculateVoteChanceUseCase, reportUseCase: reportUseCase)
        return MainViewController(viewModel: viewModel)
    }
}
