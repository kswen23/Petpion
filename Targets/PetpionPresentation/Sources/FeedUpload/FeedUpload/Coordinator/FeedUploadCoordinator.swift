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
    
    var images: [UIImage]?
    
    public func start() {
        guard let images = images else { return }
        let feedUploadViewController = getFeedUploadViewController(with: images)
        feedUploadViewController.coordinator = self
        navigationController.pushViewController(feedUploadViewController, animated: true)
    }
    
    public func presentCropViewController(from viewController: CropViewControllerDelegate, with image: UIImage, ratio: CellAspectRatio) {
        let cropViewController = getCropViewController(from: viewController, with: image, ratio: ratio.double)
        navigationController.present(cropViewController, animated: true)
    }
    
    public func dismissCropViewController() {
        navigationController.dismiss(animated: true)
    }
    
    public func dismissUploadViewController() {
        parentCoordinator?.childDidFinish(self)
        navigationController.dismiss(animated: true)
    }
    
    public func childDidFinish() {
        parentCoordinator?.childDidFinish(self)
    }

}

private extension FeedUploadCoordinator {
    
    private func getFeedUploadViewController(with images: [UIImage]) -> FeedUploadViewController {
        guard let uploadFeedUseCase: UploadFeedUseCase = DIContainer.shared.resolve(UploadFeedUseCase.self) else {
            fatalError("getFeedUploadViewController did occurred error")
        }
        let viewModel: FeedUploadViewModelProtocol = FeedUploadViewModel(selectedImages: images, uploadFeedUseCase: uploadFeedUseCase)
        return FeedUploadViewController(viewModel: viewModel)
    }
    
    private func getCropViewController(from viewController: CropViewControllerDelegate,
                                       with image: UIImage,
                                       ratio: Double) -> CropViewController {
        let cropViewController = Mantis.cropViewController(image: image)
        cropViewController.delegate = viewController
        cropViewController.didSelectRatio(ratio: ratio)
        cropViewController.modalPresentationStyle = .fullScreen
        return cropViewController
    }
}
