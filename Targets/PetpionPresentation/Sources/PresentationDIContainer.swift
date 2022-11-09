//
//  PresentationDIContainer.swift
//  Petpion
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

import PetpionCore
import PetpionDomain
import Swinject

public struct PresentationDIContainer: Containable {
    
    private let navigationController: UINavigationController
    private let container: Container
    
    public init(navigationController: UINavigationController,
                container: Container) {
        self.navigationController = navigationController
        self.container = container
    }
    
    public func register() {
        registerCoordinators()
        registerViewControllers()
        registerViewModels()
    }
    
    // MARK: - Coordinator Container
    private func registerCoordinators() {
        container.register(Coordinator.self, name: "MainCoordinator") { resolver in
            let mainCoordinator = MainCoordinator(navigationController: navigationController)
            return mainCoordinator
        }
    }
    
    // MARK: - ViewController Container
    private func registerViewControllers() {
        
    }
    
    // MARK: - ViewModel Container
    private func registerViewModels() {
        
    }
    
    // Scene 으로 추상화? Main, Vote, Upload scene..
}

