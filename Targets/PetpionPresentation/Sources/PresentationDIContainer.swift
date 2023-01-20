//
//  PresentationDIContainer.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/10.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

import PetpionCore
import PetpionDomain
import Swinject
import YPImagePicker

public struct PresentationDIContainer: Containable {
    
    public var container: Swinject.Container = DIContainer.shared
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func register() {
        registerCoordinators()
    }
    
    // MARK: - Coordinator Container
    private func registerCoordinators() {
        container.register(Coordinator.self, name: "MainCoordinator") { _ in
            MainCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "FeedUploadCoordinator") { _ in
            FeedUploadCoordinator()
        }
        
        container.register(Coordinator.self, name: "VoteMainCoordinator") { _ in
            VoteMainCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "VotePetpionCoordinator") { _ in
            VotePetpionCoordinator(navigationController: navigationController)
        }
    }
}
