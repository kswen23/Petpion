//
//  SettingProfileView.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/30.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

protocol SettingProfileViewDelegate: AnyObject {
    func profileViewDidTapped()
}

final class SettingProfileView: UIView {
    
    weak var settingProfileViewListener: SettingProfileViewDelegate?
    
    private let baseViewButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        
        return button
    }()
    
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
    
    private var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "이름"
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = .black
        nameLabel.sizeToFit()
        return nameLabel
    }()
    
    private var emailLabel: UILabel = {
        let emailLabel = UILabel()
        emailLabel.text = "aaaa1234@gmail.com"
        emailLabel.font = UIFont.systemFont(ofSize: 14)
        emailLabel.textColor = .systemGray2
        emailLabel.sizeToFit()
        return emailLabel
    }()
    
    private lazy var nameEmailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 7
        [nameLabel, emailLabel].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private let chevronView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        view.roundCorners(cornerRadius: 0.1)
        view.backgroundColor = .lightGray
        return view
    }()
    
    // MARK: - Initialize
    init() {
        super.init(frame: .zero)
        addSubview(baseViewButton)
        [profileImageView, nameEmailStackView, chevronView, borderView].forEach { baseViewButton.addSubview($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        baseViewButton.frame = self.bounds
        layout()
    }
    
    // MARK: - Layout
    private func layout() {
        let widthPadding: CGFloat = 25
        let profileImageViewRadius: CGFloat = self.bounds.height * 0.65
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: baseViewButton.leadingAnchor, constant: 15),
            profileImageView.centerYAnchor.constraint(equalTo: baseViewButton.centerYAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewRadius),
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewRadius),
            nameEmailStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20),
            nameEmailStackView.centerYAnchor.constraint(equalTo: baseViewButton.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: baseViewButton.trailingAnchor, constant: -widthPadding),
            chevronView.centerYAnchor.constraint(equalTo: baseViewButton.centerYAnchor),
            borderView.leadingAnchor.constraint(equalTo: baseViewButton.leadingAnchor, constant: widthPadding),
            borderView.trailingAnchor.constraint(equalTo: baseViewButton.trailingAnchor, constant: -widthPadding),
            borderView.bottomAnchor.constraint(equalTo: baseViewButton.bottomAnchor)
        ])
        profileImageView.roundCorners(cornerRadius: profileImageViewRadius/2)
        
        baseViewButton.addTarget(self, action: #selector(settingActionButtonTouchUpInsideAction), for: .touchUpInside)
        baseViewButton.addTarget(self, action: #selector(settingActionButtonTouchUpOutsideAction), for: [.touchUpOutside, .touchCancel])
        baseViewButton.addTarget(self, action: #selector(settingActionButtonTouchDownAction), for: .touchDown)
    }
    
    @objc private func settingActionButtonTouchUpInsideAction(_ sender: UIButton) {
        sender.backgroundColor = .white
        settingProfileViewListener?.profileViewDidTapped()
    }
    
    @objc private func settingActionButtonTouchDownAction(_ sender: UIButton) {
        sender.backgroundColor = .petpionLightGray
    }
    
    @objc private func settingActionButtonTouchUpOutsideAction(_ sender: UIButton) {
        sender.backgroundColor = .white
    }
    
    func configureSettingProfileView(with user: User) {
        profileImageView.image = user.profileImage
        nameLabel.text = user.nickname
        emailLabel.text = user.email
    }
}
