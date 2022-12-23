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
        guard let viewController = DIContainer.shared.resolve(MainViewController.self) else { return }
        childCoordinators.append(self)
        viewController.coordinator = self
        navigationController.delegate = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    public func presentFeedImagePicker() {
        guard let feedUploadCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "FeedUploadCoordinator") as? FeedUploadCoordinator else { return }
        feedUploadCoordinator.parentCoordinator = self
        childCoordinators.append(feedUploadCoordinator)
        feedUploadCoordinator.start()
        navigationController.present(feedUploadCoordinator.navigationController, animated: true)
    }
    
    public func presentDetailFeed(transitionDependency: FeedTransitionDependency, feed: PetpionFeed) {
        guard let fetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self) else { return }
        let detailFeedViewModel = DetailFeedViewModel(feed: feed, fetchFeedUseCase: fetchFeedUseCase)
        let detailFeedViewController = DetailFeedViewController(dependency: transitionDependency,
                                                                viewModel: detailFeedViewModel)
        navigationController.present(detailFeedViewController, animated: true)
    }
    
    public func pushVotePetpion() {
        guard let votePetpionCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "VotePetpionCoordinator") as? VotePetpionCoordinator else { return }
        childCoordinators.append(votePetpionCoordinator)
        votePetpionCoordinator.navigationController = navigationController
        votePetpionCoordinator.start()
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
    }
}
