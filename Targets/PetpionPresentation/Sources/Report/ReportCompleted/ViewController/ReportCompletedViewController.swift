//
//  ReportCompletedViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/19.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

final class ReportCompletedViewController: HasCoordinatorViewController {
    
    lazy var reportCoordinator: ReportCoordinator? = {
        self.coordinator as? ReportCoordinator
    }()
    
    let viewModel: ReportCompletedViewModelProtocol
    
    let completedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "donePet")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "신고처리가 완료됐습니다."
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.sizeToFit()
        return label
    }()
    
    private let headerTextLabel: UILabel = {
        let label = UILabel()
        label.text = "신고 내용을 검토한 후 적절한 조치를 취하겠습니다."
        label.textColor = .darkGray
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.sizeToFit()
        return label
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        [headerLabel, headerTextLabel].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private lazy var blockButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(blockButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func blockButtonDidTapped() {
        print("차단")
    }
    
    // MARK: - Initialize
    init(viewModel: ReportCompletedViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configureBlockButtonTitle()
    }
    
    // MARK: - Layout
    private func layout() {
        [completedImageView, headerStackView, blockButton].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            completedImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            completedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completedImageView.heightAnchor.constraint(equalToConstant: 150),
            completedImageView.widthAnchor.constraint(equalToConstant: 150),
            headerStackView.topAnchor.constraint(equalTo: completedImageView.bottomAnchor, constant: 20),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            blockButton.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 10),
            blockButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Configure
    private func configureBlockButtonTitle() {
        switch viewModel.reportType {
            
        case .user:
            blockButton.setTitle("유저 차단하기", for: .normal)
        case .feed:
            blockButton.setTitle("게시글 차단하기", for: .normal)
        }
        
        blockButton.sizeToFit()
    }
}
