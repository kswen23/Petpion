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

public final class VoteMainCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let voteMainViewController = getVoteMainViewController()
        voteMainViewController.coordinator = self
        navigationController.pushViewController(voteMainViewController, animated: true)
    }
    
    public func pushVotePetpionViewController(with pare: [PetpionVotePare]) {
        guard let votePetpionCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "VotePetpionCoordinator") as? VotePetpionCoordinator else { return }
        votePetpionCoordinator.voteList = pare
        childCoordinators.append(votePetpionCoordinator)
        votePetpionCoordinator.start()
    }
    
}

private extension VoteMainCoordinator {
    
    private func getVoteMainViewController() -> VoteMainViewController {
        guard let calculateVoteChanceUseCase: CalculateVoteChanceUseCase = DIContainer.shared.resolve(CalculateVoteChanceUseCase.self),
              let makeVoteListUseCase: MakeVoteListUseCase = DIContainer.shared.resolve(MakeVoteListUseCase.self),
              let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self),
              let fetchUserUseCase: FetchUserUseCase = DIContainer.shared.resolve(FetchUserUseCase.self),
              let uploadUserUseCase: UploadUserUseCase = DIContainer.shared.resolve(UploadUserUseCase.self),
              let makeNotificationUseCase: MakeNotificationUseCase = DIContainer.shared.resolve(MakeNotificationUseCase.self),
              let user = User.currentUser
        else {
            fatalError("GetVoteMainViewController did occurred error")
        }
        
        let viewModel: VoteMainViewModelProtocol = VoteMainViewModel(calculateVoteChanceUseCase: calculateVoteChanceUseCase, makeVoteListUseCase: makeVoteListUseCase, fetchFeedUseCase: fetchFeedUseCase, fetchUserUseCase: fetchUserUseCase, uploadUserUseCase: uploadUserUseCase, makeNotificationUseCase: makeNotificationUseCase, user: user)
        return VoteMainViewController(viewModel: viewModel)
    }

}
