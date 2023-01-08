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
        
        container.register(Coordinator.self, name: "VotePetpionCoordinator") { _ in
            VotePetpionCoordinator()
        }
    }
    
    // MARK: - ViewController Container
    private func registerViewControllers() {
        guard let mainViewModel: MainViewModelProtocol = container.resolve(MainViewModelProtocol.self),
              let feedUploadViewModel: FeedUploadViewModelProtocol = container.resolve(FeedUploadViewModelProtocol.self),
              let loginViewModel: LoginViewModelProtocol = container.resolve(LoginViewModelProtocol.self),
              let voteMainViewModel: VoteMainViewModelProtocol = container.resolve(VoteMainViewModelProtocol.self)
        else { return }
        
        container.register(MainViewController.self) { _ in
            MainViewController(viewModel: mainViewModel)
        }
        
        container.register(FeedUploadViewController.self) { _ in
            FeedUploadViewController(viewModel: feedUploadViewModel)
        }
        
        container.register(FeedImagePickerViewController.self) { _ in
            FeedImagePickerViewController(viewModel: feedUploadViewModel)
        }
        
        container.register(LoginViewController.self) { _ in
            LoginViewController(viewModel: loginViewModel)
        }
        
        container.register(VoteMainViewController.self) { _ in
            VoteMainViewController(viewModel: voteMainViewModel)
        }
    }
    
    // MARK: - ViewModel Container
    private func registerViewModels() {
        guard let fetchFeedUseCase: FetchFeedUseCase = container.resolve(FetchFeedUseCase.self),
              let uploadFeedUseCase: UploadFeedUseCase = container.resolve(UploadFeedUseCase.self),
              let makeVoteListUseCase: MakeVoteListUseCase = container.resolve(MakeVoteListUseCase.self),
              let loginUseCase: LoginUseCase = container.resolve(LoginUseCase.self),
              let uploadUserInfoUseCase: UploadUserInfoUseCase = container.resolve(UploadUserInfoUseCase.self),
              let calculateVoteChanceUseCase: CalculateVoteChanceUseCase = container.resolve(CalculateVoteChanceUseCase.self)
        else { return }
        
        container.register(MainViewModelProtocol.self) { _ in
            MainViewModel(fetchFeedUseCase: fetchFeedUseCase)
        }
        
        container.register(FeedUploadViewModelProtocol.self) { _ in
            FeedUploadViewModel(uploadFeedUseCase: uploadFeedUseCase)
        }
        
        container.register(LoginViewModelProtocol.self) { _ in
            LoginViewModel(loginUseCase: loginUseCase,
                           uploadUserInfoUseCase: uploadUserInfoUseCase)
        }
        
        container.register(VoteMainViewModelProtocol.self) { _ in
            VoteMainViewModel(calculateVoteChanceUseCase: calculateVoteChanceUseCase,
                              makeVoteListUseCase: makeVoteListUseCase,
                              fetchFeedUseCase: fetchFeedUseCase)
        }
    }
    
    func registerVotePetpion(with pare: [PetpionVotePare]) {
        guard let votePetpionUseCase: VotePetpionUseCase = container.resolve(VotePetpionUseCase.self) else { return }
        
        container.register(VotePetpionViewModel.self) { _ in
            VotePetpionViewModel(fetchedVotePare: pare, votePetpionUseCase: votePetpionUseCase)
        }
        
        guard let votePetpionViewModel: VotePetpionViewModel = container.resolve(VotePetpionViewModel.self) else { return }
        
        container.register(VotePetpionViewController.self) { _ in
            VotePetpionViewController(viewModel: votePetpionViewModel)
        }
    }
}

