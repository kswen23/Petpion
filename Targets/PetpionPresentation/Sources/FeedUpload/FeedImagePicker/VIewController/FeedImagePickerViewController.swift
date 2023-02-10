//
//  FeedImagePickerViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/23.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

import YPImagePicker

public final class FeedImagePickerViewController: YPImagePicker {
    
    weak var coordinator: FeedImagePickerCoordinator?
    
    // MARK: - Initialize
    required init(configuration: YPImagePickerConfiguration = YPImagePickerConfiguration()) {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.showsPhotoFilters = false
        config.library.maxNumberOfItems = 5
        config.library.mediaType = YPlibraryMediaType.photo
        config.library.onlySquare = true
        config.library.defaultMultipleSelection = true
        config.library.skipSelectionsGallery = true
        super.init(configuration: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureImagePicker()
    }
    
    private func configureImagePicker() {
        self.didFinishPicking { [unowned self] items, cancelled in
            if cancelled {
                coordinator?.dismissUploadViewController()
            } else {
                var images: [UIImage] = []
                for item in items {
                    switch item {
                    case .photo(let photo):
                        images.append(photo.image)
                    case .video:
                        break
                    }
                }
                coordinator?.pushFeedUploadViewController(with: images)
            }
        }
    }
}
