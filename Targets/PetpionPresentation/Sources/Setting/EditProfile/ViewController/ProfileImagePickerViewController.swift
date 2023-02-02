//
//  ProfileImagePickerViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/01.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import YPImagePicker

public protocol ProfileImagePickerViewControllerDelegate: AnyObject {
    func profileImageDidChanged(_ image: UIImage?)
}

public final class ProfileImagePickerViewController: YPImagePicker {
    
    weak var coordinator: EditProfileCoordinator?
    weak var profileImagePickerViewControllerListener: ProfileImagePickerViewControllerDelegate?
    // MARK: - Initialize
    required init(configuration: YPImagePickerConfiguration = YPImagePickerConfiguration()) {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.showsPhotoFilters = false
        config.library.maxNumberOfItems = 1
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
                profileImagePickerViewControllerListener?.profileImageDidChanged(nil)
                coordinator?.dismissProfileImagePickerViewController()
            }
            
            for item in items {
                switch item {
                case .photo(let photo):
                    print(photo.image)
                    profileImagePickerViewControllerListener?.profileImageDidChanged(photo.image)
                    coordinator?.dismissProfileImagePickerViewController()
                case .video:
                    break
                }
            }
        }
    }
}
