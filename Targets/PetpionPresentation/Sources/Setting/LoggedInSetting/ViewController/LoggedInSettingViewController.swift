//
//  LoggedInSettingViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/30.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionDomain

final class LoggedInSettingViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: SettingCoordinator?
    private let viewModel: LoggedInSettingViewModelProtocol
    
    private lazy var navigationBarBorder: CALayer = {
        let border = CALayer()
        border.borderColor = UIColor.lightGray.cgColor
        border.borderWidth = 0.2
        border.frame = CGRectMake(0, self.navigationController?.navigationBar.frame.size.height ?? 0, self.navigationController?.navigationBar.frame.size.width ?? 0, 0.2)
        return border
    }()
    
    private lazy var settingCategoryStackViewArray: [SettingCategoryStackView] = SettingModel.SettingCategory.allCases.map { SettingCategoryStackView(category: $0) }
    
    private lazy var profileSettingView: SettingProfileView = .init()
    
    private lazy var settingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        settingCategoryStackViewArray.forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    
    // MARK: - Initialize
    init(viewModel: LoggedInSettingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        addProfileChangesObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ProfileUpdated"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addProfileChangesObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: Notification.Name("ProfileUpdated"), object: nil)
    }
    
    @objc func updateProfile(_ notification: Notification) {
        print("updateProfile!")
        viewModel.fetchUserProfile()
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layer.addSublayer(navigationBarBorder)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "설정"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        settingCategoryStackViewArray.forEach { $0.settingCategoryStackViewListener = self }
        viewModel.userProfileSubject.sink { [weak self] user in
            self?.configureProfileSettingView(with: user)
        }.store(in: &cancellables)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationBarBorder.removeFromSuperlayer()
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Layout
    private func layout() {
        layoutProfileSettingView()
        layoutStackview()
    }
    
    private func layoutProfileSettingView() {
        view.addSubview(profileSettingView)
        profileSettingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileSettingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            profileSettingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            profileSettingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            profileSettingView.heightAnchor.constraint(equalToConstant: 100)
        ])
        profileSettingView.settingProfileViewListener = self
    }
    
    private func layoutStackview() {
        view.addSubview(settingStackView)
        settingStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            settingStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            settingStackView.topAnchor.constraint(equalTo: profileSettingView.bottomAnchor, constant: 10)
        ])
    }
    
    // MARK: - Configure
    private func configureProfileSettingView(with user: User) {
        profileSettingView.configureSettingProfileView(with: user)
    }
}

extension LoggedInSettingViewController: SettingCategoryStackViewDelegate, SettingProfileViewDelegate {
    
    // SettingCategoryDelegate
    func settingActionViewDidTapped(action: SettingModel.SettingAction) {
        coordinator?.pushSettingActionScene(with: action)
    }
    
    // SettingProfileDelegate
    func profileViewDidTapped() {
        coordinator?.pushSettingActionScene(with: .profile)
    }

}
