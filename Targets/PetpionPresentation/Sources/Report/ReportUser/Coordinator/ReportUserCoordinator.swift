//
//  ReportCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/18.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

final class ReportUserCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    weak var transitioningDelegate: UIViewControllerTransitioningDelegate?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let reportUserViewController = getReportUserViewController()
        reportUserViewController.coordinator = self
        navigationController.transitioningDelegate = reportUserViewController
        navigationController.modalPresentationStyle = .custom
        navigationController.pushViewController(reportUserViewController, animated: true)
    }
    
}

extension ReportUserCoordinator {
    private func getReportUserViewController() -> ReportUserViewController {
        guard let reportUseCase: ReportUseCase = DIContainer.shared.resolve(ReportUseCase.self) else {
            fatalError("getReportViewController occurred error")
        }
        let viewModel: ReportUserViewModelProtocol = ReportUserViewModel(reportUseCase: reportUseCase)
        return ReportUserViewController(viewModel: viewModel)
    }
}
