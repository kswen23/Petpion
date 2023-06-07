//
//  ReportCompletedViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/19.
//  Copyright © 2023 Petpion. All rights reserved.
//
import Combine
import Foundation
import UIKit

final class ReportCompletedViewController: HasCoordinatorViewController {
    
    lazy var reportCoordinator: ReportCoordinator? = {
        self.coordinator as? ReportCoordinator
    }()
    
    private var cancellables = Set<AnyCancellable>()
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
        viewModel.block()
    }
    
    private let toastAnimationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = .black
        label.textAlignment = .center
        label.textColor = .white
        label.alpha = 0.9
        label.isHidden = true
        return label
    }()
    private let toastAnimationLabelHeightConstant: CGFloat = 40
    private lazy var toastAnimationLabelTopAnchor: NSLayoutConstraint? = toastAnimationLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: toastAnimationLabelHeightConstant)
    
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
        bindReportCompletedViewStateSubject()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutDefaultView()
        layoutToastAnimationLabel()
    }
    
    private func layoutDefaultView() {
        [completedImageView, headerStackView, blockButton].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            completedImageView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
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
    
    private func layoutToastAnimationLabel() {
        view.addSubview(toastAnimationLabel)
        NSLayoutConstraint.activate([
            toastAnimationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastAnimationLabel.widthAnchor.constraint(equalToConstant: view.frame.width*0.7),
            toastAnimationLabel.heightAnchor.constraint(equalToConstant: toastAnimationLabelHeightConstant)
        ])
        toastAnimationLabelTopAnchor?.isActive = true
        toastAnimationLabel.roundCorners(cornerRadius: 15)
    }

    
    // MARK: - Configure
    private func configureBlockButtonTitle() {
        switch viewModel.reportBlockType {
            
        case .user:
            blockButton.setTitle("유저 차단하기", for: .normal)
        case .feed:
            blockButton.setTitle("해당 게시글 유저 차단하기", for: .normal)
        }
        
        blockButton.sizeToFit()
    }
    
    // MARK: - Binding
    private func bindReportCompletedViewStateSubject() {
        viewModel.reportCompletedViewStateSubject.sink { [weak self] viewState in
            self?.configureToastAnimationLabel(viewState: viewState)
            self?.startToastLabelAnimation()
        }.store(in: &cancellables)
    }
}

private extension ReportCompletedViewController {
    
    private func configureToastAnimationLabel(viewState: ReportCompletedViewState) {
        switch viewState {
        case .blocked:
            configureBlocked()
        case .duplicated:
            configureDuplicated()
        case .error:
            toastAnimationLabel.text = "에러가 발생했습니다."
        }
    }
    
    private func configureBlocked() {
        switch viewModel.reportBlockType {
        case .user:
            guard let user = viewModel.user else { return }
            toastAnimationLabel.text = "\(user.nickname) 님을 차단했습니다"
        case .feed:
            guard let user = viewModel.feed?.uploader else { return }
            toastAnimationLabel.text = "\(user.nickname) 님을 차단했습니다"
        }
    }
    
    private func configureDuplicated() {
        toastAnimationLabel.text = "이미 차단한 유저입니다."
    }
    
    private func startToastLabelAnimation() {
        toastAnimationLabel.isHidden = false
        toastAnimationLabelTopAnchor?.isActive = false
        toastAnimationLabelTopAnchor = toastAnimationLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -(toastAnimationLabelHeightConstant*2))
        toastAnimationLabelTopAnchor?.isActive = true
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.popToastLabelAnimation()
        })
    }
    
    private func popToastLabelAnimation() {
        toastAnimationLabelTopAnchor?.isActive = false
        toastAnimationLabelTopAnchor = toastAnimationLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: toastAnimationLabelHeightConstant)
        toastAnimationLabelTopAnchor?.isActive = true
        UIView.animate(withDuration: 0.5,
                       delay: 2.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.toastAnimationLabel.isHidden = true
        })
    }
}
