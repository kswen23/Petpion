//
//  EditProfileButton.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/31.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain

final class EditProfileButton: UIButton {
    
    private let profileRadius: CGFloat
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = User.defaultProfileImage
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .petpionLightGray
        imageView.tintColor = .lightGray
        imageView.layer.borderColor = UIColor.systemGray2.cgColor
        imageView.layer.borderWidth = 0.2
        return imageView
    }()
    
    private let editProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "pencil.circle.fill")
        imageView.backgroundColor = .darkGray
        imageView.tintColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4
        return imageView
    }()
    
    // MARK: - Initialize
    init(profileRadius: CGFloat) {
        self.profileRadius = profileRadius
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutProfileImageView()
        layoutEditProfileImageView()
    }
    
    private func layoutProfileImageView() {
        addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: self.profileRadius*2),
            profileImageView.heightAnchor.constraint(equalToConstant: self.profileRadius*2)
        ])
        profileImageView.roundCorners(cornerRadius: profileRadius)
    }
    
    private func layoutEditProfileImageView() {
        let editProfileImageViewRadius = self.profileRadius/1.5
        addSubview(editProfileImageView)
        NSLayoutConstraint.activate([
            editProfileImageView.centerXAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -profileRadius*0.3),
            editProfileImageView.centerYAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -profileRadius*0.3),
            editProfileImageView.widthAnchor.constraint(equalToConstant: editProfileImageViewRadius),
            editProfileImageView.heightAnchor.constraint(equalToConstant: editProfileImageViewRadius)
        ])
        editProfileImageView.roundCorners(cornerRadius: editProfileImageViewRadius/2)
    }
        
    func configureProfileImage(with image: UIImage) {
        profileImageView.image = image
    }
}
