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
        registerViewModels()
        registerViewControllers()
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
    }
    
    // MARK: - ViewController Container
    private func registerViewControllers() {
        guard let mainViewModel: MainViewModelProtocol = container.resolve(MainViewModelProtocol.self),
              let feedUploadViewModel: FeedUploadViewModelProtocol = container.resolve(FeedUploadViewModelProtocol.self) else { return }
        
        container.register(MainViewController.self) { _ in
            MainViewController(viewModel: mainViewModel)
        }
        
        container.register(FeedUploadViewController.self) { _ in
            FeedUploadViewController(viewModel: feedUploadViewModel)
        }
        
        container.register(FeedImagePickerViewController.self) { _ in
            FeedImagePickerViewController(viewModel: feedUploadViewModel)
        }
    }
    
    // MARK: - ViewModel Container
    private func registerViewModels() {
        guard let fetchFeedUseCase: FetchFeedUseCase = container.resolve(FetchFeedUseCase.self),
              let uploadFeedUseCase: UploadFeedUseCase = container.resolve(UploadFeedUseCase.self) else { return }
        
        container.register(MainViewModelProtocol.self) { _ in
            MainViewModel(fetchFeedUseCase: fetchFeedUseCase)
        }
        
        container.register(FeedUploadViewModelProtocol.self) { _ in
            FeedUploadViewModel(uploadFeedUseCase: uploadFeedUseCase)
        }
    }
    
    // Scene 으로 추상화? Main, Vote, Upload scene..
}

