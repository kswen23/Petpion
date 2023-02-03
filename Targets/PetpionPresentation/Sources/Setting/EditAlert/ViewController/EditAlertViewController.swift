//
//  EditAlertViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/02.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

final class EditAlertViewController: SettingCustomViewController {
    
    weak var coordinator: EditAlertCoordinator?
    private let viewModel: EditAlertViewModelProtocol
    
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
    
    private lazy var alertStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        let alertTitleViewArray = SettingModel.AlertType.allCases
                    .map { SettingAlertView(alertType: $0) }
        alertTitleViewArray.forEach { $0.settingAlertViewListener = self }
        alertTitleViewArray.forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    // MARK: - Initialize
    init(viewModel: EditAlertViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "알림 설정"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutBaseScrollView()
        layoutAlertStackView()
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
    
    private func layoutAlertStackView() {
        baseContentView.addSubview(alertStackView)
        NSLayoutConstraint.activate([
            alertStackView.topAnchor.constraint(equalTo: baseContentView.topAnchor, constant: 10),
            alertStackView.leadingAnchor.constraint(equalTo: baseContentView.leadingAnchor),
            alertStackView.trailingAnchor.constraint(equalTo: baseContentView.trailingAnchor),
        ])
        baseContentView.bringSubviewToFront(alertStackView)
    }
}

extension EditAlertViewController: SettingAlertViewDelegate {
    
    func toggleSwitchValueChanged(type: SettingModel.AlertType, bool: Bool) {
        viewModel.toggleSwitchDidChanged(alertType: type, value: bool)
    }
    
}
