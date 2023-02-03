//
//  MyPageCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

public final class MyPageCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    var user: User = .empty
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        if UserDefaults.standard.bool(forKey: UserInfoKey.isLogin) == true {
            let myPageViewController = getMyPageViewController()
            myPageViewController.coordinator = self
            navigationController.pushViewController(myPageViewController, animated: true)
//            let needLoginViewController = getNeedLoginViewController()
//            needLoginViewController.coordinator = self
//            navigationController.pushViewController(needLoginViewController, animated: true)
        } else {
            let needLoginViewController = getNeedLoginViewController()
            needLoginViewController.coordinator = self
            navigationController.pushViewController(needLoginViewController, animated: true)
        }
    }
    
    public func pushSettingViewController(with user: User) {
        guard let settingCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "SettingCoordinator") as? SettingCoordinator else { return }
        childCoordinators.append(settingCoordinator)
        if UserDefaults.standard.bool(forKey: UserInfoKey.isLogin) == true {
            settingCoordinator.user = user
        }
        settingCoordinator.start()
    }
    
    public func presentLoginView() {
        guard let needLoginViewController = navigationController.visibleViewController as? NeedLoginViewController else { return }
        let loginViewController = getLoginViewController()
        loginViewController.modalPresentationStyle = .custom
        loginViewController.transitioningDelegate = needLoginViewController
        needLoginViewController.present(loginViewController, animated: true)
    }
    
}

private extension MyPageCoordinator {
    
    private func getMyPageViewController() -> MyPageViewController {
        guard let fetchFeedUseCase: FetchFeedUseCase = DIContainer.shared.resolve(FetchFeedUseCase.self) else {
            fatalError("getMyPageViewController did occurred error")
        }
        let viewModel: MyPageViewModelProtocol = MyPageViewModel(user: user,
                                                                 fetchFeedUseCase: fetchFeedUseCase)
        return MyPageViewController(viewModel: viewModel)
    }
    
    private func getNeedLoginViewController() -> NeedLoginViewController {
        let viewModel: NeedLoginViewModelProtocol = NeedLoginViewModel()
        return NeedLoginViewController(viewModel: viewModel)
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
