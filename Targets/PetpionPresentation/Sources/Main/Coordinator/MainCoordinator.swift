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

public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

public extension Coordinator {
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

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
    
    public func presentFeedImagePicker() {
        if UserDefaults.standard.bool(forKey: UserInfoKey.isLogin) == true {
            guard let feedImagePickerCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "FeedImagePickerCoordinator") as? FeedImagePickerCoordinator else { return }
            feedImagePickerCoordinator.parentCoordinator = self
            childCoordinators.append(feedImagePickerCoordinator)
            feedImagePickerCoordinator.start()
            navigationController.present(feedImagePickerCoordinator.navigationController, animated: true)
        } else {
            presentLoginView()
        }
    }
    
    public func presentDetailFeed(transitionDependency: FeedTransitionDependency, feed: PetpionFeed) {
        guard let detailFeedCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "DetailFeedCoordinator") as? DetailFeedCoordinator else { return }
        childCoordinators.append(detailFeedCoordinator)
        detailFeedCoordinator.feed = feed
        detailFeedCoordinator.presentDetailFeedView(transitionDependency: transitionDependency)
    }
    
    public func pushVoteMainViewController(user: User) {
        if UserDefaults.standard.bool(forKey: UserInfoKey.isLogin) == true {
            guard let voteMainCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "VoteMainCoordinator") as? VoteMainCoordinator else { return }
            childCoordinators.append(voteMainCoordinator)
            voteMainCoordinator.user = user
            voteMainCoordinator.start()
        } else {
            presentLoginView()
        }
    }
    
    public func pushMyPageViewController(user: User) {
        guard let myPageCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "MyPageCoordinator") as? MyPageCoordinator else { return }
        childCoordinators.append(myPageCoordinator)
        myPageCoordinator.user = user
        myPageCoordinator.start()
    }
    
    public func presentLoginView() {
        guard let mainViewController = navigationController.visibleViewController as? MainViewController else { return }
        let loginViewController = getLoginViewController()
        loginViewController.modalPresentationStyle = .custom
        loginViewController.transitioningDelegate = mainViewController
        mainViewController.present(loginViewController, animated: true)
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
              let calculateVoteChanceUseCase: CalculateVoteChanceUseCase = DIContainer.shared.resolve(CalculateVoteChanceUseCase.self)
        else {
            fatalError("getMainViewController did occurred error")
        }
        let viewModel: MainViewModelProtocol = MainViewModel(fetchFeedUseCase: fetchFeedUseCase, fetchUserUseCase: fetchUserUseCase, calculateVoteChanceUseCase: calculateVoteChanceUseCase)
        return MainViewController(viewModel: viewModel)
    }
    
    
    private func getLoginViewController() -> LoginViewController {
        guard let loginUseCase: LoginUseCase = DIContainer.shared.resolve(LoginUseCase.self),
              let uploadUserUseCase: UploadUserUseCase = DIContainer.shared.resolve(UploadUserUseCase.self) else {
            fatalError("getLoginViewController did occurred error")
        }
        let viewModel: LoginViewModelProtocol = LoginViewModel(loginUseCase: loginUseCase, uploadUserUseCase: uploadUserUseCase)
        return LoginViewController(viewModel: viewModel)
    }
}
