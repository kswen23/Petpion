//
//  DetailFeedCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/10.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

enum DetailFeedStyle {
    case editableUserDetailFeed
    case uneditableUserDetailFeed
    case otherUserDetailFeed
}

public final class DetailFeedCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    var feed: PetpionFeed?
    var detailFeedStyle: DetailFeedStyle?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let detailFeedViewController = getPushableDetailFeedViewController()
        detailFeedViewController.coordinator = self
        navigationController.pushViewController(detailFeedViewController, animated: true)
    }
    
    public func presentDetailFeedView(transitionDependency: FeedTransitionDependency) {
        let detailFeedViewController: PresentableDetailFeedViewController = getPresentableDetailFeedViewController(transitionDependency: transitionDependency)
        detailFeedViewController.coordinator = self
        navigationController.present(detailFeedViewController, animated: true)
    }
    
    func pushUserPageView(user: User, userPageStyle: UserPageStyle) {
        guard let userPageCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "UserPageCoordinator") as? UserPageCoordinator else { return }
        childCoordinators.append(userPageCoordinator)
        userPageCoordinator.user = user
        userPageCoordinator.userPageStyle = userPageStyle
        userPageCoordinator.start()
    }
    
    func presentLoginView(transitioningDelegate: UIViewControllerTransitioningDelegate?) {
        guard let mainViewController = navigationController.visibleViewController as? PresentableDetailFeedViewController else { return }
        let loginViewController = getLoginViewController(transitioningDelegate: transitioningDelegate)
        mainViewController.present(loginViewController, animated: true)
    }
    
    func popDetailFeedView() {
        navigationController.popViewController(animated: true)
    }
    
    func dismissDetailFeedView() {
        navigationController.dismiss(animated: true)
    }
    
    func pushEditFeedView(listener: EditFeedViewControllerListener?,
                                 snapshot: NSDiffableDataSourceSnapshot<Int, URL>) {
        guard let editFeedCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "EditFeedCoordinator") as? EditFeedCoordinator else { return }
        childCoordinators.append(editFeedCoordinator)
        editFeedCoordinator.feed = feed
        editFeedCoordinator.snapshot = snapshot
        editFeedCoordinator.listener = listener
        editFeedCoordinator.start()
    }
    
    func presentReportFeedViewController() {
        guard let reportCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "ReportCoordinator") as? ReportCoordinator else { return }
        childCoordinators.append(reportCoordinator)
        let reportFeedNavigationController = UINavigationController()
        reportCoordinator.navigationController = reportFeedNavigationController
        reportCoordinator.parentableNavigationController = navigationController
        reportCoordinator.reportBlockType = .feed
        reportCoordinator.feed = feed
        reportCoordinator.start()
        navigationController.visibleViewController?.present(reportFeedNavigationController, animated: true)
    }
    
}

private extension DetailFeedCoordinator {
    private func getPushableDetailFeedViewController() -> PushableDetailFeedViewController {
        guard let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self),
              let deleteFeedUseCase: DeleteFeedUseCase = DIContainer.shared.resolve(DeleteFeedUseCase.self),
              let blockUseCase: BlockUseCase = DIContainer.shared.resolve(BlockUseCase.self),
              let feed = feed,
              let detailFeedStyle = detailFeedStyle
        else {
            fatalError("getDetailFeedViewController occurred Error")
        }
        let viewModel: DetailFeedViewModelProtocol = DetailFeedViewModel(feed: feed, detailFeedStyle: detailFeedStyle, fetchFeedUseCase: fetchFeedUseCase, deleteFeedUseCase: deleteFeedUseCase, blockUseCase: blockUseCase)
        return PushableDetailFeedViewController(viewModel: viewModel)
    }
    
    private func getPresentableDetailFeedViewController(transitionDependency: FeedTransitionDependency) -> PresentableDetailFeedViewController {
        guard let fetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self),
              let deleteFeedUseCase = DIContainer.shared.resolve(DeleteFeedUseCase.self),
              let blockUseCase: BlockUseCase = DIContainer.shared.resolve(BlockUseCase.self),
              let feed = feed,
              let detailFeedStyle = detailFeedStyle
        else { fatalError("getDetailFeedViewController did occurred error") }
        let detailFeedViewModel = DetailFeedViewModel(feed: feed, detailFeedStyle: detailFeedStyle, fetchFeedUseCase: fetchFeedUseCase, deleteFeedUseCase: deleteFeedUseCase, blockUseCase: blockUseCase)
        return PresentableDetailFeedViewController(dependency: transitionDependency, viewModel: detailFeedViewModel)
    }
    
    private func getLoginViewController(transitioningDelegate: UIViewControllerTransitioningDelegate?) -> LoginViewController {
        guard let loginUseCase: LoginUseCase = DIContainer.shared.resolve(LoginUseCase.self),
              let uploadUserUseCase: UploadUserUseCase = DIContainer.shared.resolve(UploadUserUseCase.self) else {
            fatalError("getLoginViewController did occurred error")
        }
        let viewModel: LoginViewModelProtocol = LoginViewModel(loginUseCase: loginUseCase, uploadUserUseCase: uploadUserUseCase)
        return LoginViewController(viewModel: viewModel)
    }
}
