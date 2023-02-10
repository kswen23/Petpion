//
//  FeedImagePickerCoordinator.swift
//  Petpion
//
//  Created by 김성원 on 2022/11/23.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

public final class FeedImagePickerCoordinator: NSObject, Coordinator {
    
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
        guard let feedUploadCoordinator: FeedUploadCoordinator = DIContainer.shared.resolve(Coordinator.self, name: "FeedUploadCoordinator") as? FeedUploadCoordinator else { return }
        childCoordinators.append(feedUploadCoordinator)
        feedUploadCoordinator.navigationController = navigationController
        feedUploadCoordinator.images = images
        feedUploadCoordinator.parentCoordinator = self
        feedUploadCoordinator.start()
    }
        
    public func dismissUploadViewController() {
        parentCoordinator?.childDidFinish(self)
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

private extension FeedImagePickerCoordinator {
    
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
}
