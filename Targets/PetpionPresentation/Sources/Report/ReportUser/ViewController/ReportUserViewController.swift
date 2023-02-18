//
//  ReportUserViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/18.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain

final class ReportUserViewController: HasCoordinatorViewController {
    
    lazy var reportCoordinator: ReportUserCoordinator? = {
        self.coordinator as? ReportUserCoordinator
    }()
    
    let viewModel: ReportUserViewModelProtocol
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "신고하는 이유를 알려주세요."
        label.lineBreakMode = .byCharWrapping
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.sizeToFit()
        return label
    }()
    
    private let headerTextLabel: UILabel = {
        let label = UILabel()
        label.text = "만약 이 계정이 커뮤니티 가이드라인이나 이용약관을 위반하고 있다고 생각하신다면, 신고를 통해 알려주시기 바랍니다. 신고 내용을 검토한 후 적절한 조치를 취하겠습니다."
        label.textColor = .darkGray
        label.lineBreakMode = .byCharWrapping
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
    
    private lazy var detailStackView: ReportTypeStackView = {
        let stackView = ReportTypeStackView(typeArray: ReportType.user)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initialize
    init(viewModel: ReportUserViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutHeaderLabel()
        layoutDetailStackView()
    }
    
    private func layoutHeaderLabel() {
        view.addSubview(headerStackView)
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    }
    
    private func layoutDetailStackView() {
        view.addSubview(detailStackView)
        NSLayoutConstraint.activate([
            detailStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 10),
            detailStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
extension ReportUserViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let reportUserPresentationController = CustomPresentationController(presentedViewController: presented, presenting: presenting)
        reportUserPresentationController.fractionalHeight = 0.6
        return reportUserPresentationController
    }
}
