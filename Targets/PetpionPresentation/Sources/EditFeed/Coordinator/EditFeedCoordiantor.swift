//
//  EditFeedCoordiantor.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/15.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

public final class EditFeedCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    var feed: PetpionFeed?
    weak var listener: EditFeedViewControllerListener?
    var snapshot: NSDiffableDataSourceSnapshot<Int, URL>?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let editFeedViewController = getEditFeedViewController()
        editFeedViewController.coordinator = self
        editFeedViewController.listener = listener
        editFeedViewController.snapshot = snapshot
        navigationController.pushViewController(editFeedViewController, animated: false)
    }

    public func popEditFeedView() {
        navigationController.popViewController(animated: false)
    }
    
}

private extension EditFeedCoordinator {
    private func getEditFeedViewController() -> EditFeedViewController {
        guard let feed = feed,
              let uploadFeedUseCase = DIContainer.shared.resolve(UploadFeedUseCase.self)
        else {
            fatalError("getEditFeedViewController occurred Error")
        }
        let viewModel: EditFeedViewModelProtocol = EditFeedViewModel(uploadFeedUseCase: uploadFeedUseCase, feed: feed)
        return EditFeedViewController(viewModel: viewModel)
    }
    
}
