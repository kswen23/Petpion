//
//  VotePetpionViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/21.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import UIKit

import PetpionCore
import PetpionDomain

final class VotePetpionViewController: HasCoordinatorViewController {
    
    lazy var votePetpionCoordinator: VotePetpionCoordinator? = {
        return coordinator as? VotePetpionCoordinator
    }()
    private var cancellables = Set<AnyCancellable>()
    
    private let viewModel: VotePetpionViewModelProtocol
    
    private lazy var votingListCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                             collectionViewLayout: UICollectionViewLayout())
    private var votingListCollectionViewDataSource: UICollectionViewDiffableDataSource<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare>?
    
    private lazy var customBackBarButton: UIBarButtonItem = {
        let backImage = UIImage(systemName: "chevron.backward", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonDidTapped))
        return backButton
    }()
    
    @objc private func backButtonDidTapped() {
        present(quitAlarmAlertController, animated: true)
    }
    
    private lazy var quitAlarmAlertController: UIAlertController = {
        let alert = UIAlertController(title: "투표를 나가시겠어요?", message: "지금 나가도 하트가 하나 없어져요.", preferredStyle: .alert)
        let quitAction: UIAlertAction = .init(title: "나가기", style: .destructive) { [weak self] _ in
            self?.votePetpionCoordinator?.popVotePetpionViewController()
        }
        let cancelAction: UIAlertAction = .init(title: "취소", style: .cancel)
        [quitAction, cancelAction].forEach { alert.addAction($0) }
        return alert
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.sizeToFit()
        return label
    }()
    
    // MARK: - Initialize
    init(viewModel: VotePetpionViewModelProtocol) {
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
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutVotingListCollectionView()
    }
    
    private func layoutVotingListCollectionView() {
        view.addSubview(votingListCollectionView)
        votingListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            votingListCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            votingListCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            votingListCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            votingListCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        votingListCollectionView.contentInsetAdjustmentBehavior = .never
        votingListCollectionView.alwaysBounceHorizontal = false
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationBar()
        configureVotingListCollectionView()
    }
    
    private func configureNavigationBar() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = navigationAppearance
        navigationItem.leftBarButtonItem = customBackBarButton
        navigationController?.navigationBar.tintColor = .black
        navigationItem.titleView = titleLabel
    }

    private func configureVotingListCollectionView() {
        votingListCollectionView.setCollectionViewLayout(viewModel.configureVotingListCollectionViewLayout(), animated: true)
        votingListCollectionView.contentInsetAdjustmentBehavior = .never
        votingListCollectionView.showsVerticalScrollIndicator = false
        votingListCollectionView.showsHorizontalScrollIndicator = false
        votingListCollectionView.isScrollEnabled = false
    }

    // MARK: - Binding
    private func binding() {
        bindSnapshotSubject()
        bindVoteIndexSubject()
    }
    
    private func bindSnapshotSubject() {
        viewModel.snapshotSubject.sink { [weak self] snapshot in
            self?.votingListCollectionViewDataSource = self?.makeVotingListCollectionViewDataSource()
            self?.votingListCollectionViewDataSource?.apply(snapshot)
        }.store(in: &cancellables)
    }
    
    private func bindVoteIndexSubject() {
        viewModel.voteIndexSubject.sink { [weak self] item in
            if item == self?.viewModel.needToPopViewController {
                self?.votePetpionCoordinator?.popVotePetpionViewController()
            } else {
                self?.votingListCollectionView.isScrollEnabled = true
                self?.votingListCollectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: [], animated: true)
                self?.changeTitle(item)
                self?.votingListCollectionView.isScrollEnabled = false
            }
        }.store(in: &cancellables)
    }
    
    func makeVotingListCollectionViewDataSource() -> UICollectionViewDiffableDataSource<VotePetpionViewModel.VoteCollectionViewSection, PetpionVotePare> {
        let registration = makeVotingListCollectionViewCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: votingListCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func makeVotingListCollectionViewCellRegistration() -> UICollectionView.CellRegistration<VotingListCollectionViewCell, PetpionVotePare> {
        UICollectionView.CellRegistration { [weak self] cell, indexPath, item in
            cell.configureItem(item: item)
            cell.parentableViewController = self
            cell.clipsToBounds = true
        }
    }
    
    private func changeTitle(_ item: Int) {
        titleLabel.text = "\(item+1)/\(viewModel.fetchedVotePare.count)"
        titleLabel.sizeToFit()
    }
}

extension VotePetpionViewController: VotingListCollectionViewCellDelegate {
    
    func voteCollectionViewDidTapped(to section: ImageCollectionViewSection) {
        viewModel.petpionFeedDidSelected(to: section)   
    }
}
