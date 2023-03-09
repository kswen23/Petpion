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

final class EditProfileCoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let editProfileViewController = getEditProfileViewController()
        editProfileViewController.coordinator = self
        navigationController.pushViewController(editProfileViewController, animated: true)
    }
    
    func presentProfileImagePickerViewController(parentableViewController: ProfileImagePickerViewControllerDelegate) {
        let profileImagePickerViewController = getProfileImagePickerViewController()
        profileImagePickerViewController.profileImagePickerViewControllerListener = parentableViewController
        navigationController.present(profileImagePickerViewController, animated: true)
    }
    
    func popEditProfileViewController() {
        navigationController.popViewController(animated: true)
    }
    
    func dismissProfileImagePickerViewController() {
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
