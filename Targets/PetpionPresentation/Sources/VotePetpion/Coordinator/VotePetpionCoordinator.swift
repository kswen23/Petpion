//
//  VotePetpionCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/21.
//  Copyright © 2022 Petpion. All rights reserved.
//
import Foundation
import UIKit

import PetpionCore
import PetpionDomain

public final class VotePetpionCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    public init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }
    
    public func start() {
        guard let voteMainViewController = DIContainer.shared.resolve(VoteMainViewController.self) else { return }
        voteMainViewController.coordinator = self
        navigationController.pushViewController(voteMainViewController, animated: true)
    }
    
    public func pushVotePetpion(with pare: [PetpionVotePare]) {
        PresentationDIContainer(navigationController: navigationController).registerVotePetpion(with: pare)
        guard let votePetpionViewController = DIContainer.shared.resolve(VotePetpionViewController.self) else { return }
        votePetpionViewController.coordinator = self
        navigationController.pushViewController(votePetpionViewController, animated: true)
    }
    
    private func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
