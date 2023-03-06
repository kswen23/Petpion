//
//  ManageBlockedUserViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/21.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionDomain

final class ManageBlockedUserViewController: SettingCustomViewController {
    
    lazy var manageBlockedUserCoordinator: ManageBlockedUserCoordinator? = {
        self.coordinator as? ManageBlockedUserCoordinator
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let viewModel: ManageBlockedUserViewModelProtocol
    private lazy var blockedUserTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private lazy var blockedUserTableViewDataSource: UITableViewDiffableDataSource<Int, User> = makeBlockedUserTableViewDataSource()
    
    private let toastAnimationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "차단이 해제됐습니다."
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
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "차단한 사용자가 없습니다."
        label.font = .systemFont(ofSize: 18)
        label.textColor = .lightGray
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initialize
    init(viewModel: ManageBlockedUserViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "차단 유저 관리"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutBlockedUserTableView()
        layoutToastAnimationLabel()
        layoutEmptyLabel()
    }
    
    private func layoutBlockedUserTableView() {
        view.addSubview(blockedUserTableView)
        NSLayoutConstraint.activate([
            blockedUserTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            blockedUserTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blockedUserTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blockedUserTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
    
    private func layoutEmptyLabel() {
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        configureBlockedUserTableView()
    }
    
    private func configureBlockedUserTableView() {
        blockedUserTableView.register(BlockedUserTableViewCell.self, forCellReuseIdentifier: BlockedUserTableViewCell.identifier)
        blockedUserTableView.delegate = self
        blockedUserTableView.dataSource = blockedUserTableViewDataSource
        blockedUserTableView.separatorStyle = .none
    }
    
    // MARK: - Binding
    private func binding() {
        bindBlockedUserArraySubject()
        bindToastAnimationSubject()
    }
    
    private func bindBlockedUserArraySubject() {
        viewModel.blockedUserArraySubject.sink { [weak self] items in
            guard let strongSelf = self else { return }
            
            if items.count == 0 {
                strongSelf.emptyLabel.isHidden = false
            } else {
                strongSelf.emptyLabel.isHidden = true
            }
            
            var snapshot = NSDiffableDataSourceSnapshot<Int, User>()
            snapshot.appendSections([0])
            snapshot.appendItems(items)
            strongSelf.blockedUserTableViewDataSource.apply(snapshot, animatingDifferences: true)
        }.store(in: &cancellables)
    }
    
    private func bindToastAnimationSubject() {
        viewModel.toastAnimationSubject.sink { [weak self] unblockSuccess in
            guard let strongSelf = self else { return }
            if unblockSuccess == true {
                self?.postRefreshAction()
                self?.startToastLabelAnimation()
            } else {
                strongSelf.toastAnimationLabel.text = "에러가 발생했습니다."
                self?.startToastLabelAnimation()
            }
        }.store(in: &cancellables)
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

extension ManageBlockedUserViewController: UITableViewDelegate, BlockedUserTableViewCellListener {
    private func makeBlockedUserTableViewDataSource() -> UITableViewDiffableDataSource<Int, User> {
        return UITableViewDiffableDataSource(tableView: self.blockedUserTableView) { [weak self] tableView, indexPath, item in
            guard let cell = self?.blockedUserTableView.dequeueReusableCell(withIdentifier: BlockedUserTableViewCell.identifier, for: indexPath) as? BlockedUserTableViewCell else { fatalError() }
            cell.configureCell(with: item)
            cell.blockedUserTableViewCellListener = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func unblockUser(_ cell: BlockedUserTableViewCell) {
        guard let index = blockedUserTableView.indexPath(for: cell)?.item else { return }
        viewModel.unblockUser(index)
    }
}
