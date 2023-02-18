//
//  EditProfileCoordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/31.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain
import PetpionCore

public final class EditProfileCoordinator: NSObject, Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let editProfileViewController = getEditProfileViewController()
        editProfileViewController.coordinator = self
        navigationController.pushViewController(editProfileViewController, animated: true)
    }
    
    public func presentProfileImagePickerViewController(parentableViewController: ProfileImagePickerViewControllerDelegate) {
        let profileImagePickerViewController = getProfileImagePickerViewController()
        profileImagePickerViewController.coordinator = self
        profileImagePickerViewController.profileImagePickerViewControllerListener = parentableViewController
        navigationController.present(profileImagePickerViewController, animated: true)
    }
    
    public func popEditProfileViewController() {
        navigationController.popViewController(animated: true)
    }
    
    public func dismissProfileImagePickerViewController() {
        navigationController.dismiss(animated: true)
    }
}

extension EditProfileCoordinator {
    
    private func getEditProfileViewController() -> EditProfileViewController {
        guard let uploadUserUseCase: UploadUserUseCase = DIContainer.shared.resolve(UploadUserUseCase.self),
              let user = User.currentUser
        else {
            fatalError("getEditProfileViewController did occurred error")
        }
        let viewModel: EditProfileViewModelProtocol = EditProfileViewModel(uploadUserUseCase: uploadUserUseCase, user: user)
        return EditProfileViewController(viewModel: viewModel)
    }
    
    private func getProfileImagePickerViewController() -> ProfileImagePickerViewController {
        return ProfileImagePickerViewController()
    }
}
