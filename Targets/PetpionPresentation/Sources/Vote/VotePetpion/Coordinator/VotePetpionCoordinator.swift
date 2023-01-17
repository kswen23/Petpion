//
//  VotePetpionCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/17.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

public final class VotePetpionCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    public var voteList: [PetpionVotePare]?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("deinit VotePetpionCoordinator")
    }
    
    public func start() {
        guard let voteList = voteList else { return }
        let votePetpionViewController = getVotePetpionViewController(with: voteList)
        votePetpionViewController.coordinator = self
        navigationController.pushViewController(votePetpionViewController, animated: true)
    }
    
    public func popVotePetpionViewController() {
        navigationController.popViewController(animated: true)
    }

}

private extension VotePetpionCoordinator {
    private func getVotePetpionViewController(with pare: [PetpionVotePare]) -> VotePetpionViewController {
        guard let votePetpionUseCase: VotePetpionUseCase = DIContainer.shared.resolve(VotePetpionUseCase.self) else {
            fatalError("GetVotePetpionViewController did occurred error")
        }
        let viewModel: VotePetpionViewModelProtocol = VotePetpionViewModel(fetchedVotePare: pare, votePetpionUseCase: votePetpionUseCase)
        return VotePetpionViewController(viewModel: viewModel)
    }
}
