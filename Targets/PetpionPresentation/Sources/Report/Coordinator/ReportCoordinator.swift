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

enum ReportSceneType {
    case user
    case feed
}

final class ReportCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    var reportType: ReportSceneType!
    var parentableNavigationController: UINavigationController?
    var feed: PetpionFeed?
    var user: User?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        var reportViewController: HasCoordinatorViewController = .init()
        
        switch reportType {
            
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
        guard let customPresentationController = parentableNavigationController?.presentedViewController?.presentationController as? CustomPresentationController else { return }
        let reportCompletedViewController = getReportCompletedViewController()
        reportCompletedViewController.coordinator = self
        customPresentationController.fractionalHeight = 0.45
        navigationController.pushViewController(reportCompletedViewController, animated: true)
        let finalFrame = customPresentationController.frameOfPresentedViewInContainerView
        UIView.animate(withDuration: 0.3) {
            customPresentationController.presentedView?.frame = finalFrame
        }
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
        var viewModel: InputReportViewModelProtocol = InputReportViewModel(reportType: reportType, reportUseCase: reportUseCase, currentType: reportType)
        switch reportType {
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
        var viewModel: ReportCompletedViewModelProtocol = ReportCompletedViewModel(reportType: reportType)
        switch reportType {
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
