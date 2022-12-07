//
//  MainViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import UIKit

import PetpionCore
import PetpionDomain

final class MainViewController: UIViewController {
        
    weak var coordinator: MainCoordinator?
    private let viewModel: MainViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var baseCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                             collectionViewLayout: UICollectionViewLayout())
    private lazy var popularBarButton = UIBarButtonItem(title: "#인기", style: .done, target: self, action: #selector(popularDidTapped))
    private lazy var latestBarButton = UIBarButtonItem(title: "#최신", style: .done, target: self, action: #selector(latestDidTapped))
    private lazy var baseCollectionViewDataSource = viewModel.makeBaseCollectionViewDataSource(parentViewController: self, collectionView: baseCollectionView)
    
    // MARK: - Initialize
    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        layout()
        configure()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutBaseCollectionView()
    }
    
    private func layoutBaseCollectionView() {
        view.addSubview(baseCollectionView)
        baseCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            baseCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            baseCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            baseCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        baseCollectionView.contentInsetAdjustmentBehavior = .never
        baseCollectionView.alwaysBounceVertical = false
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationItem()
        configureBaseCollectionView()
    }
    
    private func configureNavigationItem() {
        
        navigationItem.leftBarButtonItems = [
            popularBarButton,
            latestBarButton
        ]
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: #selector(personButtonDidTap)),
            UIBarButtonItem(image: UIImage(systemName: "camera"), style: .done, target: self, action: #selector(cameraButtonDidTap)),
            UIBarButtonItem(image: UIImage(systemName: "crown"), style: .done, target: self, action: #selector(cameraButtonDidTap))
        ]
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func configureBaseCollectionView() {
        baseCollectionView.setCollectionViewLayout(viewModel.configureBaseCollectionViewLayout(), animated: true)
        var snapshot = NSDiffableDataSourceSnapshot<MainViewModel.Section, SortingOption>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.baseCollectionViewType)
        baseCollectionViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureLeftBarButton(with option: SortingOption) {
        let font = UIFont.systemFont(ofSize: 27, weight: .heavy)
        switch option {
            
        case .popular:
            popularBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .normal)
            popularBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .highlighted)
            latestBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
            latestBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .highlighted)

        case .latest:
            popularBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .normal)
            popularBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ], for: .highlighted)
            latestBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .normal)
            latestBarButton.setTitleTextAttributes([
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .highlighted)
        }
    }
    
    @objc func popularDidTapped() {
        viewModel.sortingOptionWillChange(with: .popular)
    }
    
    @objc func latestDidTapped() {
        viewModel.sortingOptionWillChange(with: .latest)
    }
    
    @objc func cameraButtonDidTap() {
        coordinator?.presentFeedImagePicker(viewController: self)
    }
    
    @objc func personButtonDidTap() {
        viewModel.fetchNextFeed()
    }
    
    // MARK: - binding
    
    private func binding() {
        bindSortingOption()
    }
    
    private func bindSortingOption() {
        viewModel.sortingOptionSubject.sink { [weak self] sortingOption in
            self?.configureLeftBarButton(with: sortingOption)
            if self?.viewModel.baseCollectionViewNeedToScroll == false {
                self?.baseCollectionView.scrollToItem(at: IndexPath(item: sortingOption.rawValue, section: 0), at: [], animated: true)
                self?.viewModel.sortingOptionDidChanged()
            }
        }.store(in: &cancellables)
    }
}

extension MainViewController: BaseCollectionViewCellDelegation {
    func baseCollectionViewNeedNewFeed() {
        viewModel.fetchNextFeed()
    }
       
}
