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
        let voteMainViewController = getVoteMainViewController()
        voteMainViewController.coordinator = self
        navigationController.pushViewController(voteMainViewController, animated: true)
    }
    
    public func pushVotePetpion(with pare: [PetpionVotePare]) {
        let votePetpionViewController = getVotePetpionViewController(with: pare)
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

private extension VotePetpionCoordinator {
    
    private func getVoteMainViewController() -> VoteMainViewController {
        guard let calculateVoteChanceUseCase: CalculateVoteChanceUseCase = DIContainer.shared.resolve(CalculateVoteChanceUseCase.self),
              let makeVoteListUseCase: MakeVoteListUseCase = DIContainer.shared.resolve(MakeVoteListUseCase.self),
              let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self),
              let uploadUserUseCase: UploadUserUseCase = DIContainer.shared.resolve(UploadUserUseCase.self) else { fatalError("GetVoteMainViewController did occurred error")
        }
        
        let viewModel: VoteMainViewModelProtocol = VoteMainViewModel(calculateVoteChanceUseCase: calculateVoteChanceUseCase, makeVoteListUseCase: makeVoteListUseCase, fetchFeedUseCase: fetchFeedUseCase, uploadUserUseCase: uploadUserUseCase)
        return VoteMainViewController(viewModel: viewModel)
    }
    
    private func getVotePetpionViewController(with pare: [PetpionVotePare]) -> VotePetpionViewController {
        guard let votePetpionUseCase: VotePetpionUseCase = DIContainer.shared.resolve(VotePetpionUseCase.self) else {
            fatalError("GetVotePetpionViewController did occurred error")
        }
        let viewModel: VotePetpionViewModelProtocol = VotePetpionViewModel(fetchedVotePare: pare, votePetpionUseCase: votePetpionUseCase)
        return VotePetpionViewController(viewModel: viewModel)
    }
}
