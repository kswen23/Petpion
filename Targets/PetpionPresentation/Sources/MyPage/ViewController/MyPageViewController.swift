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
    
    let userCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .petpionLightGray
        return view
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
    }
    
    private func layoutUserCardView() {
        view.addSubview(userCardView)
        userCardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            userCardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userCardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            userCardView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationItem()
    }
    
    private func configureNavigationItem() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "내 정보"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(settingButtonDidTapped))
    }
    
    @objc private func settingButtonDidTapped() {
        coordinator?.presentLoginView()
    }
}
