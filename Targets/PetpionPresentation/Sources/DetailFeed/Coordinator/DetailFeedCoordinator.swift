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

public final class DetailFeedCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    var feed: PetpionFeed?
    
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
    
    public func presentFeedSettingView() {
        if UserDefaults.standard.bool(forKey: UserInfoKey.isLogin.rawValue) == true {
            presentLoginView()
        } else {
            presentLoginView()
        }
    }
    
    private func presentLoginView() {
        guard let mainViewController = navigationController.visibleViewController as? PresentableDetailFeedViewController else { return }
        let loginViewController = getLoginViewController()
        loginViewController.modalPresentationStyle = .custom
        loginViewController.transitioningDelegate = mainViewController
        mainViewController.present(loginViewController, animated: true)
    }
    
    public func popDetailFeedView() {
        navigationController.popViewController(animated: true)
    }
    
    public func dismissDetailFeedView() {
        navigationController.dismiss(animated: true)
    }
    
    public func pushEditFeedView(listener: EditFeedViewControllerListener?,
                                 snapshot: NSDiffableDataSourceSnapshot<Int, URL>) {
        guard let editFeedCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "EditFeedCoordinator") as? EditFeedCoordinator else { return }
        childCoordinators.append(editFeedCoordinator)
        editFeedCoordinator.feed = feed
        editFeedCoordinator.snapshot = snapshot
        editFeedCoordinator.listener = listener
        editFeedCoordinator.start()
    }
    
}

private extension DetailFeedCoordinator {
    private func getPushableDetailFeedViewController() -> PushableDetailFeedViewController {
        guard let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self),
              let deleteFeedUseCase: DeleteFeedUseCase = DIContainer.shared.resolve(DeleteFeedUseCase.self),
              let feed = feed
        else {
            fatalError("getDetailFeedViewController occurred Error")
        }
        let viewModel: DetailFeedViewModelProtocol = DetailFeedViewModel(feed: feed, fetchFeedUseCase: fetchFeedUseCase, deleteFeedUseCase: deleteFeedUseCase)
        return PushableDetailFeedViewController(viewModel: viewModel)
    }
    
    private func getPresentableDetailFeedViewController(transitionDependency: FeedTransitionDependency) -> PresentableDetailFeedViewController {
        guard let fetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self),
              let deleteFeedUseCase = DIContainer.shared.resolve(DeleteFeedUseCase.self),
              let feed = feed
        else { fatalError("getDetailFeedViewController did occurred error") }
        let detailFeedViewModel = DetailFeedViewModel(feed: feed, fetchFeedUseCase: fetchFeedUseCase, deleteFeedUseCase: deleteFeedUseCase)
        return PresentableDetailFeedViewController(dependency: transitionDependency, viewModel: detailFeedViewModel)
    }
    
    private func getLoginViewController() -> LoginViewController {
        guard let loginUseCase: LoginUseCase = DIContainer.shared.resolve(LoginUseCase.self),
              let uploadUserUseCase: UploadUserUseCase = DIContainer.shared.resolve(UploadUserUseCase.self) else {
            fatalError("getLoginViewController did occurred error")
        }
        let viewModel: LoginViewModelProtocol = LoginViewModel(loginUseCase: loginUseCase, uploadUserUseCase: uploadUserUseCase)
        return LoginViewController(viewModel: viewModel)
    }
}
