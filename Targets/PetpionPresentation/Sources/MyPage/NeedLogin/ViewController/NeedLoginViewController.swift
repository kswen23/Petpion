//
//  NeedLoginViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import Lottie

final class NeedLoginViewController: SettingCustomViewController {
    
    lazy var needLoginCoordinator: MyPageCoordinator? = {
        return coordinator as? MyPageCoordinator
    }()
    
    private let viewModel: NeedLoginViewModelProtocol
    
    private let needLoginLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인이 필요한 기능입니다."
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }()
    
    private let animationView: LottieAnimationView = {
        let animationView = LottieAnimationView.init(name: LottieJson.cuteDog)
        animationView.loopMode = .loop
        return animationView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인 하러가기!", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .semibold )
        return button
    }()
    
    // MARK: - Initialize
    init(viewModel: NeedLoginViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationItem()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        configure()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutNeedLoginLabel()
        layoutAnimationView()
        layoutLoginButton()
    }
    
    private func layoutNeedLoginLabel() {
        view.addSubview(needLoginLabel)
        needLoginLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            needLoginLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            needLoginLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130)
        ])
    }
    
    private func layoutAnimationView() {
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            animationView.topAnchor.constraint(equalTo: needLoginLabel.bottomAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 300),
            animationView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func layoutLoginButton() {
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: animationView.bottomAnchor),
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 60),
            loginButton.widthAnchor.constraint(equalToConstant: 300)
        ])
        loginButton.roundCorners(cornerRadius: 20)
    }
    
    // MARK: - Configure
    private func configure() {
        configureAnimationView()
        configureLoginButton()
    }
    
    private func configureNavigationItem() {
        self.navigationItem.title = "내 정보"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(settingButtonDidTapped))
    }
    
    @objc private func settingButtonDidTapped() {
        needLoginCoordinator?.pushSettingViewController()
    }
    
    private func configureAnimationView() {
        animationView.play()
    }
    
    private func configureLoginButton() {
        loginButton.addTarget(self, action: #selector(loginButtonDidTapped), for: .touchUpInside)
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @objc private func loginButtonDidTapped() {
        needLoginCoordinator?.presentLoginView()
    }
}

extension NeedLoginViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        LoginPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
