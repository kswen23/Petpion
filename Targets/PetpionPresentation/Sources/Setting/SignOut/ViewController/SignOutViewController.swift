//
//  SignOutViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/07.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

final class SignOutViewController: SettingCustomViewController {
    
    lazy var signOutCoordinator: SignOutCoordinator? = {
        return coordinator as? SignOutCoordinator
    }()
    
    private let viewModel: SignOutViewModelProtocol
    
    private let signOutImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logOutDog")
        return imageView
    }()
    
    private lazy var signOutTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(viewModel.user.nickname) 님, 정말 탈퇴하시는건가요..?"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    private let signOutDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "탈퇴 시, 계정의 모든 정보는 삭제되며 재가입 시에도 복구되지 않습니다."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13)
        label.textColor = .systemGray
        label.sizeToFit()
        return label
    }()
    
    private lazy var signOutStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        [signOutTitleLabel, signOutDetailLabel].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.roundCorners(cornerRadius: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 70).isActive = true
        button.setTitle("취소하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.petpionLightGray.cgColor
        button.addTarget(self, action: #selector(cancelButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func cancelButtonDidTapped() {
        signOutCoordinator?.popViewController()
    }
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton()
        button.roundCorners(cornerRadius: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 70).isActive = true
        button.setTitle("탈퇴하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.backgroundColor = .petpionRealRed
        button.addTarget(self, action: #selector(signOutButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func signOutButtonDidTapped() {
        viewModel.signOut()
    }
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        [cancelButton, signOutButton].forEach { stackView.addArrangedSubview($0) }
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Initialize
    init(viewModel: SignOutViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "탈퇴하기"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutSignOutImageView()
        layoutSignOutLabel()
        layoutSignOutButton()
    }
    
    private func layoutSignOutImageView() {
        view.addSubview(signOutImageView)
        NSLayoutConstraint.activate([
            signOutImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            signOutImageView.widthAnchor.constraint(equalToConstant: 180),
            signOutImageView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    private func layoutSignOutLabel() {
        view.addSubview(signOutStackView)
        NSLayoutConstraint.activate([
            signOutStackView.topAnchor.constraint(equalTo: signOutImageView.bottomAnchor, constant: 40),
            signOutStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            signOutStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func layoutSignOutButton() {
        view.addSubview(buttonStackView)
        NSLayoutConstraint.activate([
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
}
