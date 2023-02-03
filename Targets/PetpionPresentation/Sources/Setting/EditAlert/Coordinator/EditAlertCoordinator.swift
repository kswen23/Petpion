//
//  EditAlertCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/02.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

public final class EditAlertCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let editAlertViewController = getEditAlertViewController()
        editAlertViewController.coordinator = self
        navigationController.pushViewController(editAlertViewController, animated: true)
    }
}

extension EditAlertCoordinator {
    func getEditAlertViewController() -> EditAlertViewController {
        guard let makeNotificationUseCase: MakeNotificationUseCase = DIContainer.shared.resolve(MakeNotificationUseCase.self) else {
            fatalError("getEditAlertViewController did occurred error")
        }
        let viewModel: EditAlertViewModelProtocol = EditAlertViewModel(makeNotificationUseCase: makeNotificationUseCase)
        return EditAlertViewController(viewModel: viewModel)
    }
}
