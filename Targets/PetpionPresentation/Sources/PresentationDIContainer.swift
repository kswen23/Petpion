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

public struct PresentationDIContainer: Containable {
    
    public var container: Swinject.Container = DIContainer.shared
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func register() {
        registerViewModels()
        registerViewControllers()
        registerCoordinators()
    }
    
    // MARK: - Coordinator Container
    private func registerCoordinators() {
        container.register(Coordinator.self, name: "MainCoordinator") { _ in
            MainCoordinator(navigationController: navigationController)
        }
    }
    
    // MARK: - ViewController Container
    private func registerViewControllers() {
        guard let mainViewModel: MainViewModelProtocol = container.resolve(MainViewModelProtocol.self) else { return }
                
        container.register(MainViewController.self) { _ in
            MainViewController(mainViewModel: mainViewModel)
        }
    }
    
    // MARK: - ViewModel Container
    private func registerViewModels() {
        guard let fetchPetDataUseCase: FetchPetDataUseCase = container.resolve(FetchPetDataUseCase.self) else { return }
        
        container.register(MainViewModelProtocol.self) { _ in
            MainViewModel(fetchPetDataUseCase: fetchPetDataUseCase)
        }
    }
    
    // Scene 으로 추상화? Main, Vote, Upload scene..
}
