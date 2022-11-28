//
//  FeedUploadCoordinator.swift
//  Petpion
//
//  Created by 김성원 on 2022/11/23.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

import Mantis
import PetpionCore
import PetpionDomain

public final class FeedUploadCoordinator: NSObject, Coordinator {
    
    public weak var parentCoordinator: MainCoordinator?
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    public init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }
    
    public func start() {
        guard let imagePickerViewController = DIContainer.shared.resolve(FeedImagePickerViewController.self) else { return }
        imagePickerViewController.coordinator = self
        self.navigationController = imagePickerViewController
    }
    
    public func pushFeedUploadViewController() {
        guard let viewController = DIContainer.shared.resolve(FeedUploadViewController.self) else { return }
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
        
    public func dismissUploadViewController() {
        parentCoordinator?.childDidFinish(self)
        navigationController.dismiss(animated: true)
    }
    
    public func presentCropViewController(from viewController: CropViewControllerDelegate, with image: UIImage) {
        let cropViewController = Mantis.cropViewController(image: image)
        cropViewController.delegate = viewController
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.config.ratioOptions = [.custom]
        cropViewController.config.addCustomRatio(byVerticalWidth: 1, andVerticalHeight: 1)
        cropViewController.config.addCustomRatio(byVerticalWidth: 3, andVerticalHeight: 4)
        cropViewController.config.addCustomRatio(byVerticalWidth: 4, andVerticalHeight: 3)
        navigationController.present(cropViewController, animated: true)
    }
    
    public func dismissCropViewController() {
        navigationController.dismiss(animated: true)
    }
    private func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
