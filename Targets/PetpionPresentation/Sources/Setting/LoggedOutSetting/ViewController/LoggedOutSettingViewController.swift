//
//  LoggedOutSettingViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/07.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

final class LoggedOutSettingViewController: SettingCustomViewController {
    
    lazy var loggedOutSettingCoordinator: SettingCoordinator? = {
        return coordinator as? SettingCoordinator
    }()
    
    private lazy var baseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var baseContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var appPolicyStackView: SettingCategoryStackView = SettingCategoryStackView(category: .appPolicy)
    
    // MARK: - Initialize
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "설정"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        appPolicyStackView.settingCategoryStackViewListener = self
    }
    
    // MARK: - Layout
    private func layout() {
        layoutBaseScrollView()
        layoutAppPolicyStackView()
    }
    
    private func layoutBaseScrollView() {
        view.addSubview(baseScrollView)
        baseScrollView.addSubview(baseContentView)
        baseScrollView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        baseScrollView.contentInsetAdjustmentBehavior = .never
        NSLayoutConstraint.activate([
            baseScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            baseScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            baseContentView.topAnchor.constraint(equalTo: baseScrollView.topAnchor),
            baseContentView.bottomAnchor.constraint(equalTo: baseScrollView.bottomAnchor),
            baseContentView.leadingAnchor.constraint(equalTo: baseScrollView.leadingAnchor),
            baseContentView.trailingAnchor.constraint(equalTo: baseScrollView.trailingAnchor),
            baseContentView.widthAnchor.constraint(equalTo: baseScrollView.widthAnchor),
            baseContentView.heightAnchor.constraint(equalTo: baseScrollView.heightAnchor)
        ])
    }
    
    private func layoutAppPolicyStackView() {
        baseContentView.addSubview(appPolicyStackView)
        appPolicyStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appPolicyStackView.topAnchor.constraint(equalTo: baseContentView.topAnchor),
            appPolicyStackView.leadingAnchor.constraint(equalTo: baseContentView.leadingAnchor),
            appPolicyStackView.trailingAnchor.constraint(equalTo: baseContentView.trailingAnchor)
        ])
    }
}

extension LoggedOutSettingViewController: SettingCategoryStackViewDelegate {
    
    func settingActionViewDidTapped(action: SettingModel.SettingAction) {
        loggedOutSettingCoordinator?.startSettingActionScene(with: action)
    }
}
