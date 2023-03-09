//
//  PetpionHallViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionDomain
import Lottie

final class PetpionHallViewController: HasCoordinatorViewController {
    
    private lazy var petpionHallCoordinator: PetpionHallCoordinator? = {
        self.coordinator as? PetpionHallCoordinator
    }()
    
    private let viewModel: PetpionHallViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let petpionHallTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Date, [PetpionFeed]> = makePetpionHallTableViewDataSource()
    
    private lazy var navigationBarBorder: CALayer = {
        let border = CALayer()
        border.borderColor = UIColor.lightGray.cgColor
        border.borderWidth = 0.2
        border.frame = CGRectMake(0, self.navigationController?.navigationBar.frame.size.height ?? 0, self.navigationController?.navigationBar.frame.size.width ?? 0, 0.2)
        return border
    }()
    
    private lazy var loadingAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView.init(name: LottieJson.launchAnimation)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()

    // MARK: - Initialize
    init(viewModel: PetpionHallViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "명예의 전당"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.layer.addSublayer(navigationBarBorder)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationBarBorder.removeFromSuperlayer()
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutPetpionHallTableView()
        layoutLoadingView()
    }
    
    private func layoutPetpionHallTableView() {
        view.addSubview(petpionHallTableView)
        NSLayoutConstraint.activate([
            petpionHallTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            petpionHallTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            petpionHallTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            petpionHallTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func layoutLoadingView() {
        petpionHallTableView.addSubview(loadingAnimationView)
        NSLayoutConstraint.activate([
            loadingAnimationView.widthAnchor.constraint(equalToConstant: xValueRatio(200)),
            loadingAnimationView.heightAnchor.constraint(equalToConstant: xValueRatio(300)),
            loadingAnimationView.centerXAnchor.constraint(equalTo: petpionHallTableView.centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: petpionHallTableView.centerYAnchor)
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        configurePetpionHallTableView()
    }
    
    private func configurePetpionHallTableView() {
        petpionHallTableView.register(PetpionHallTableViewCell.self, forCellReuseIdentifier: PetpionHallTableViewCell.identifier)
        petpionHallTableView.register(PetpionHallHeaderView.self, forHeaderFooterViewReuseIdentifier: PetpionHallHeaderView.identifer)
        petpionHallTableView.delegate = self
        petpionHallTableView.dataSource = dataSource
        petpionHallTableView.separatorStyle = .none
        petpionHallTableView.showsVerticalScrollIndicator = false
    }
    
    // MARK: - Binding
    private func binding() {
        bindTopPetpionFeedArraySubject()
    }
    
    private func bindTopPetpionFeedArraySubject() {
        viewModel.topPetpionFeedArraySubject
            .sink { [weak self] topPetpionFeeds in
                guard let strongSelf = self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Date, [PetpionFeed]>()
                topPetpionFeeds.forEach { topPetpionFeed in
                    snapshot.appendSections([topPetpionFeed.date])
                    if topPetpionFeed.feedArray.count != 0 {
                        snapshot.appendItems([topPetpionFeed.feedArray], toSection: topPetpionFeed.date)
                        strongSelf.loadingAnimationView.isHidden = true
                    }
                }
                strongSelf.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
    }
}

extension PetpionHallViewController: UITableViewDelegate {
    
    private func makePetpionHallTableViewDataSource() -> UITableViewDiffableDataSource<Date, [PetpionFeed]> {
        return UITableViewDiffableDataSource(tableView: self.petpionHallTableView) { [weak self] tableView, indexPath, item in
            guard let cell = self?.petpionHallTableView.dequeueReusableCell(withIdentifier: PetpionHallTableViewCell.identifier, for: indexPath) as? PetpionHallTableViewCell,
                  let strongSelf = self
            else { fatalError() }
            let sectionIndex = strongSelf.viewModel.indexArray[indexPath.section]
            cell.configureCollectionView(items: item)
            cell.petpionHallTableViewCellListener = self
            cell.configureCollectionViewIndex(sectionIndex)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: PetpionHallHeaderView.identifer) as? PetpionHallHeaderView
        else { return nil }
        let sectionDate = viewModel.topPetpionFeedArraySubject.value[section].date
        headerView.configureHeaderView(date: sectionDate, section: section)
        headerView.petpionHallHeaderViewListener = self
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width*1.1
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let scrollViewHeight = scrollView.contentSize.height - scrollView.frame.height
        if scrollViewHeight - scrollView.contentOffset.y <= 0 {
            viewModel.fetchTopFeed()
        }
    }
}

extension PetpionHallViewController: PetpionHallHeaderViewListener, PetpionHallTableViewCellListener {
    
    func totalButtonDidTapped(_ section: Int) {
        let targetDate = viewModel.topPetpionFeedArraySubject.value[section].date
        petpionHallCoordinator?.pushFeedOfTheMonthView(with: targetDate)
    }
    
    func collectionViewDidScrolled(cell: UITableViewCell, index: Int) {
        guard let tableViewSectionIndex = petpionHallTableView.indexPath(for: cell)?.section else { return }
        viewModel.scrollViewDidScrolled(section: tableViewSectionIndex, index: index)
    }
    
    func collectionViewItemDidSelected(cell: UITableViewCell, index: Int) {
        guard let tableViewSectionIndex = petpionHallTableView.indexPath(for: cell)?.section else { return }
        let selectedFeed = viewModel.topPetpionFeedArraySubject.value[tableViewSectionIndex].feedArray[index]
        petpionHallCoordinator?.pushPushableDetailFeedView(with: selectedFeed)
    }
    
    func profileStackViewDidTapped(cell: UITableViewCell, itemIndex: Int) {
        guard let tableViewSectionIndex = petpionHallTableView.indexPath(for: cell)?.section else { return }
        let selectedUser = viewModel.topPetpionFeedArraySubject.value[tableViewSectionIndex].feedArray[itemIndex].uploader
        petpionHallCoordinator?.pushUserPageView(with: selectedUser)
    }
    
}
