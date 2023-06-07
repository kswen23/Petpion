//
//  ReportCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/19.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

final class ReportCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    var reportBlockType: ReportBlockType!
    var parentableNavigationController: UINavigationController?
    var feed: PetpionFeed?
    var user: User?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        var reportViewController: HasCoordinatorViewController = .init()
        
        switch reportBlockType {
            
        case .user:
            reportViewController = getReportUserViewController()
        case .feed:
            reportViewController = getReportFeedViewController()
        case .none:
            break
        }
        
        reportViewController.coordinator = self
        navigationController.transitioningDelegate = reportViewController as? UIViewControllerTransitioningDelegate
        navigationController.modalPresentationStyle = .custom
        navigationController.pushViewController(reportViewController, animated: true)
    }
    
    func pushInputReportView() {
        guard let customPresentationController = parentableNavigationController?.presentedViewController?.presentationController as? CustomPresentationController else { return }
        
        let inputReportViewController = getInputReportViewController()
        inputReportViewController.coordinator = self
        
        customPresentationController.fractionalHeight = 0.7
        navigationController.pushViewController(inputReportViewController, animated: true)
        
        let finalFrame = customPresentationController.frameOfPresentedViewInContainerView
        UIView.animate(withDuration: 0.3) {
            customPresentationController.presentedView?.frame = finalFrame
        }
    }
    
    func pushReportCompletedView() {
        let reportCompletedViewController = getReportCompletedViewController()
        reportCompletedViewController.coordinator = self
        navigationController.pushViewController(reportCompletedViewController, animated: true)
    }
    
}

extension ReportCoordinator {
    private func getReportUserViewController() -> ReportUserViewController {
        guard let reportUseCase: ReportUseCase = DIContainer.shared.resolve(ReportUseCase.self),
              let user = user
        else {
            fatalError("getReportUserViewController occurred error")
        }
        let viewModel: ReportUserViewModelProtocol = ReportUserViewModel(user: user, reportUseCase: reportUseCase)
        return ReportUserViewController(viewModel: viewModel)
    }
    
    private func getReportFeedViewController() -> ReportFeedViewController {
        guard let reportUseCase: ReportUseCase = DIContainer.shared.resolve(ReportUseCase.self),
              let feed = feed
        else {
            fatalError("getReportFeedViewController occurred error")
        }
        let viewModel: ReportFeedViewModelProtocol = ReportFeedViewModel(feed: feed, reportUseCase: reportUseCase)
        return ReportFeedViewController(viewModel: viewModel)
    }
    
    private func getInputReportViewController() -> InputReportViewController {
        guard let reportUseCase: ReportUseCase = DIContainer.shared.resolve(ReportUseCase.self)
        else {
            fatalError("getReportFeedViewController occurred error")
        }
        var viewModel: InputReportViewModelProtocol = InputReportViewModel(reportBlockType: reportBlockType, reportUseCase: reportUseCase)
        switch reportBlockType {
        case .user:
            viewModel.user = user
        case .feed:
            viewModel.feed = feed
        case .none:
            fatalError("getReportFeedViewController occurred error")
        }
        
        return InputReportViewController(viewModel: viewModel)
    }
    
    private func getReportCompletedViewController() -> ReportCompletedViewController {
        guard let blockUseCase: BlockUseCase = DIContainer.shared.resolve(BlockUseCase.self) else {
            fatalError("getReportCompletedViewController occurred error")
        }
        var viewModel: ReportCompletedViewModelProtocol = ReportCompletedViewModel(reportBlockType: reportBlockType, blockUseCase: blockUseCase)
        switch reportBlockType {
        case .user:
            viewModel.user = user
        case .feed:
            viewModel.feed = feed
        case .none:
            fatalError("getReportFeedViewController occurred error")
        }
        return ReportCompletedViewController(viewModel: viewModel)
    }
}
