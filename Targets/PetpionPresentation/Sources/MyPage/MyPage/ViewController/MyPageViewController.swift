//
//  MyPageViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

final class MyPageViewController: UIViewController {
    
    weak var coordinator: MyPageCoordinator?
    private let viewModel: MyPageViewModelProtocol
    
    private let userCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .petpionLightGray
        return view
    }()
    let cardViewWidth: CGFloat = UIScreen.main.bounds.size.width - 40
    let cardViewHeight: CGFloat = (UIScreen.main.bounds.size.width - 40) * 0.56
    
    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .lightGray
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private let userNickNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "tempuser"
        label.sizeToFit()
        return label
    }()
    
    // MARK: - Initialize
    init(viewModel: MyPageViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        view.backgroundColor = .white
    }
    
    // MARK: - Layout
    private func layout() {
        layoutUserCardView()
        layoutUserProfileImageView()
        layoutUserNickNameLabel()
    }
    
    private func layoutUserCardView() {
        view.addSubview(userCardView)
        userCardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            userCardView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            userCardView.widthAnchor.constraint(equalToConstant: cardViewWidth),
            userCardView.heightAnchor.constraint(equalToConstant: cardViewHeight)
        ])
        userCardView.roundCorners(cornerRadius: 15)
        userCardView.layer.masksToBounds = false
        userCardView.layer.shadowOffset = CGSize(width: 5, height: 5)
        userCardView.layer.shadowOpacity = 0.7
        userCardView.layer.shadowRadius = 5
        userCardView.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    private func layoutUserProfileImageView() {
        userCardView.addSubview(userProfileImageView)
        userProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        let profileImageViewWidth: CGFloat = cardViewHeight * 0.75
        NSLayoutConstraint.activate([
            userProfileImageView.centerYAnchor.constraint(equalTo: userCardView.centerYAnchor),
            userProfileImageView.leadingAnchor.constraint(equalTo: userCardView.leadingAnchor, constant: 10),
            userProfileImageView.heightAnchor.constraint(equalToConstant: profileImageViewWidth),
            userProfileImageView.widthAnchor.constraint(equalToConstant: profileImageViewWidth)
        ])
        userProfileImageView.roundCorners(cornerRadius: profileImageViewWidth/2)
        userProfileImageView.backgroundColor = .white
        userProfileImageView.bringSubviewToFront(userCardView)
    }
    
    private func layoutUserNickNameLabel() {
        userCardView.addSubview(userNickNameLabel)
        userNickNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNickNameLabel.topAnchor.constraint(equalTo: userCardView.topAnchor, constant: 30),
            userNickNameLabel.leadingAnchor.constraint(equalTo: userProfileImageView.trailingAnchor, constant: 20)
        ])
        userNickNameLabel.bringSubviewToFront(userCardView)
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationItem()
        configureUserInformation()
    }
    
    private func configureNavigationItem() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "내 정보"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(settingButtonDidTapped))
    }
    
    @objc private func settingButtonDidTapped() {
        coordinator?.presentLoginView()
    }
    
    private func configureUserInformation() {
        Task {
            userNickNameLabel.text = viewModel.user.nickname
            userProfileImageView.image = await viewModel.loadUserProfileImage()
        }
    }
    
}
