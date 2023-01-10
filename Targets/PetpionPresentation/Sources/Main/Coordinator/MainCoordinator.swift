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

public final class MainCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let viewController = getMainViewController()
        childCoordinators.append(self)
        viewController.coordinator = self
        navigationController.delegate = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    public func presentFeedImagePicker() {
        if UserDefaults.standard.bool(forKey: UserInfoKey.isLogin) == true {
            guard let feedUploadCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "FeedUploadCoordinator") as? FeedUploadCoordinator else { return }
            feedUploadCoordinator.parentCoordinator = self
            childCoordinators.append(feedUploadCoordinator)
            feedUploadCoordinator.start()
            navigationController.present(feedUploadCoordinator.navigationController, animated: true)
        } else {
            presentLoginView()
        }
    }
    
    public func presentDetailFeed(transitionDependency: FeedTransitionDependency, feed: PetpionFeed) {
        let detailFeedViewController: DetailFeedViewController = getDetailFeedViewController(transitionDependency: transitionDependency, feed: feed)
        navigationController.present(detailFeedViewController, animated: true)
    }
    
    public func pushVotePetpion() {
        if UserDefaults.standard.bool(forKey: UserInfoKey.isLogin) == true {
            guard let votePetpionCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "VotePetpionCoordinator") as? VotePetpionCoordinator else { return }
            childCoordinators.append(votePetpionCoordinator)
            votePetpionCoordinator.navigationController = navigationController
            votePetpionCoordinator.start()
        } else {
            presentLoginView()
        }
    }
    
    public func presentLoginView() {
        guard let mainViewController = navigationController.visibleViewController as? MainViewController else { return }
        let loginViewController = getLoginViewController()
        loginViewController.modalPresentationStyle = .custom
        loginViewController.transitioningDelegate = mainViewController
        mainViewController.present(loginViewController, animated: true)
    }
    
    public func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

extension MainCoordinator: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }
        
        if let detailFoodViewController = fromViewController as? FeedImagePickerViewController {
            childDidFinish(detailFoodViewController.coordinator)
        }
        
        if let voteMainViewController = fromViewController as? VoteMainViewController {
            childDidFinish(voteMainViewController.coordinator)
        }
    }
}

private extension MainCoordinator {
    
    private func getMainViewController() -> MainViewController {
        guard let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self) else {
            fatalError("getMainViewController did occurred error")
        }
        let viewModel: MainViewModelProtocol = MainViewModel(fetchFeedUseCase: fetchFeedUseCase)
        return MainViewController(viewModel: viewModel)
    }
    
    private func getDetailFeedViewController(transitionDependency: FeedTransitionDependency,
                                             feed: PetpionFeed) -> DetailFeedViewController {
        guard let fetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self) else { fatalError("getDetailFeedViewController did occurred error") }
        let detailFeedViewModel = DetailFeedViewModel(feed: feed, fetchFeedUseCase: fetchFeedUseCase)
        return DetailFeedViewController(dependency: transitionDependency, viewModel: detailFeedViewModel)
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
