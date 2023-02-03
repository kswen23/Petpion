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
    
    public weak var parentCoordinator: Coordinator?
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    public init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let imagePickerViewController = getFeedImagePickerViewController()
        imagePickerViewController.coordinator = self
        self.navigationController = imagePickerViewController
    }
    
    public func pushFeedUploadViewController(with images: [UIImage]) {
        let feedUploadViewController = getFeedUploadViewController(with: images)
        feedUploadViewController.coordinator = self
        navigationController.pushViewController(feedUploadViewController, animated: true)
    }
        
    public func dismissUploadViewController() {
//        parentCoordinator?.childDidFinish(self)
        navigationController.dismiss(animated: true)
    }
    
    public func presentCropViewController(from viewController: CropViewControllerDelegate, with image: UIImage) {
        let cropViewController = getCropViewController(from: viewController, with: image)
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

private extension FeedUploadCoordinator {
    
    private func getFeedImagePickerViewController() -> FeedImagePickerViewController {
        return FeedImagePickerViewController()
    }
    
    private func getFeedUploadViewController(with images: [UIImage]) -> FeedUploadViewController {
        guard let uploadFeedUseCase: UploadFeedUseCase = DIContainer.shared.resolve(UploadFeedUseCase.self) else {
            fatalError("getFeedUploadViewController did occurred error")
        }
        let viewModel: FeedUploadViewModelProtocol = FeedUploadViewModel(selectedImages: images, uploadFeedUseCase: uploadFeedUseCase)
        return FeedUploadViewController(viewModel: viewModel)
    }
    
    private func getCropViewController(from viewController: CropViewControllerDelegate,
                                       with image: UIImage) -> CropViewController {
        let cropViewController = Mantis.cropViewController(image: image)
        cropViewController.delegate = viewController
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.config.ratioOptions = [.custom]
        cropViewController.config.addCustomRatio(byVerticalWidth: 1, andVerticalHeight: 1)
        cropViewController.config.addCustomRatio(byVerticalWidth: 3, andVerticalHeight: 4)
        cropViewController.config.addCustomRatio(byVerticalWidth: 4, andVerticalHeight: 3)
        return cropViewController
    }
}
