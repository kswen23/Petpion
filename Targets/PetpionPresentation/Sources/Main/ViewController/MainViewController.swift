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
    private lazy var petFeedCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: UICollectionViewLayout())
    private lazy var popularBarButton = UIBarButtonItem(title: "#인기", style: .done, target: self, action: #selector(popularDidTapped))
    private lazy var latestBarButton = UIBarButtonItem(title: "#최신", style: .done, target: self, action: #selector(latestDidTapped))
    private lazy var petFeedDataSource = viewModel.makePetFeedCollectionViewDataSource(collectionView: petFeedCollectionView)
    private lazy var baseCollectionViewDataSource = viewModel.makeBaseCollectionViewDataSource(collectionView: baseCollectionView)
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
//        layoutPetCollectionView()
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
    
    private func layoutPetCollectionView() {
        view.addSubview(petFeedCollectionView)
        petFeedCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            petFeedCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            petFeedCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            petFeedCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            petFeedCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        petFeedCollectionView.backgroundColor = .white
        petFeedCollectionView.showsVerticalScrollIndicator = false
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationItem()
//        configureBaseCollectionView()
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
        baseCollectionView.setCollectionViewLayout(configureBaseCollectionViewLayout(), animated: true)
        var snapshot = NSDiffableDataSourceSnapshot<MainViewModel.Section, SortingOption>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.baseCollectionViewType)
        baseCollectionViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureBaseCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
            guard self?.viewModel.baseCollectionViewNeedToScroll == true else { return }
            let index = Int(max(0, round(point.x / environment.container.contentSize.width)))
            self?.viewModel.baseCollectionViewDidScrolled(to: index)
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
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
    
    private func configurePetCollectionView() {
        let waterfallLayout = UICollectionViewCompositionalLayout.makeWaterfallLayout(configuration: viewModel.makeWaterfallLayoutConfiguration())
        petFeedCollectionView.setCollectionViewLayout(waterfallLayout, animated: true)
        petFeedCollectionView.delegate = self
    }
    
    // MARK: - binding
    
    private func binding() {
        bindSnapshot()
        bindSortingOption()
    }
    
    private func bindSnapshot() {
        viewModel.snapshotSubject.sink { [weak self] snapshot in
//            self?.configurePetCollectionView()
//            self?.petFeedDataSource.apply(snapshot)
            self?.configureBaseCollectionView()
        }.store(in: &cancellables)
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

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("\(indexPath)didEndDisplaying")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let scrollViewHeight = scrollView.contentSize.height - scrollView.frame.height
        print(scrollViewHeight - scrollView.contentOffset.y)
        if scrollViewHeight - scrollView.contentOffset.y <= 0 {
//            count += 1
//            let afterViewModels = Array(1*(count-1)...22*count).map { _ in SearchViewModel() }
//            viewModels = viewModels + afterViewModels
//            initialData(count: count)
            viewModel.fetchNextFeed()
        }
    }

}
