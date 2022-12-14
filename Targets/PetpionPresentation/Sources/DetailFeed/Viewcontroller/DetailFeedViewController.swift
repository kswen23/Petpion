//
//  DetailFeedViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/08.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionCore

final class DetailFeedViewController: CustomPresentableViewController {
    
    private let dependency: FeedTransitionDependency
    private lazy var detailFeedImageCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                                     collectionViewLayout: UICollectionViewLayout())
    private lazy var datasource = viewModel.makeDetailFeedImageCollectionViewDataSource(parentViewController: self, collectionView: detailFeedImageCollectionView)
    
    private lazy var dismissButton: CircleButton = {
        let button = CircleButton(diameter: 30)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(dismissButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func dismissButtonDidTapped() {
        self.dismiss(animated: true)
    }
    
    private lazy var imageSlider: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = .systemGray
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.addTarget(self, action: #selector(imageSliderValueChanged), for: .valueChanged)
        return pageControl
    }()
    
    @objc private func imageSliderValueChanged() {
        viewModel.pageControlValueChanged(imageSlider.currentPage)
    }
    
    private var detailImageCollectionViewHeightAnchor: NSLayoutConstraint?
    private var viewTopAnchor: NSLayoutConstraint?
    private var viewLeadingAnchor: NSLayoutConstraint?
    private var viewTrailingAnchor: NSLayoutConstraint?
    private var viewBottomAnchor: NSLayoutConstraint?
    private var cancellables = Set<AnyCancellable>()
    let viewModel: DetailFeedViewModelProtocol
    
    init(dependency: FeedTransitionDependency,
         viewModel: DetailFeedViewModelProtocol) {
        self.dependency = dependency
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.setupPresentation()
    }
    
    private func setupPresentation() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatusBar(hidden: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            detailFeedImageCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: [], animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        binding()
        view.backgroundColor = .systemBackground
    }
    
    // MARK: - Layout
    private func layout() {
        layoutDetailFeedImageCollectionView()
        layoutDismissButton()
        layoutImageSlider()
    }
            
    private func layoutDetailFeedImageCollectionView() {
        view.addSubview(detailFeedImageCollectionView)
        detailFeedImageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailFeedImageCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            detailFeedImageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailFeedImageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        detailFeedImageCollectionView.backgroundColor = .lightGray
        detailFeedImageCollectionView.roundCorners(cornerRadius: 10)
    }
    
    private func layoutDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: detailFeedImageCollectionView.topAnchor, constant: 25),
            dismissButton.trailingAnchor.constraint(equalTo: detailFeedImageCollectionView.trailingAnchor, constant: -25)
        ])
        
    }
    
    private func layoutImageSlider() {
        view.addSubview(imageSlider)
        imageSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageSlider.topAnchor.constraint(equalTo: detailFeedImageCollectionView.bottomAnchor, constant: 5),
            imageSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageSlider.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        detailFeedImageCollectionView.contentInsetAdjustmentBehavior = .never
        detailFeedImageCollectionView.alwaysBounceVertical = false
        imageSlider.numberOfPages = viewModel.feed.imagesCount
        detailFeedImageCollectionView.setCollectionViewLayout(viewModel.configureDetailFeedImageCollectionViewLayout(), animated: false)
    }
    
    // MARK: - Binding
    private func binding() {
        bindSnapshot()
        bindCurrentImageIndex()
    }
    
    private func bindSnapshot() {
        viewModel.snapshotSubject.sink { [weak self] snapshot in
            self?.datasource.apply(snapshot)
        }.store(in: &cancellables)
    }

    private func bindCurrentImageIndex() {
        viewModel.currentPageSubject.sink { [weak self] current in
            if self?.viewModel.currentPageChangedByPageControl == true {
                self?.detailFeedImageCollectionView.scrollToItem(at: IndexPath(row: current, section: 0), at: .centeredHorizontally, animated: true)
            } else {
                self?.imageSlider.currentPage = current
            }
            
        }.store(in: &cancellables)

    }
    // MARK: - Animating
    
    func setChildViewLayoutByZoomOut(childView: UIView,
                                     backgroundView: UIView,
                                     childViewFrame: CGRect,
                                     imageFrame: CGRect) {
        [viewTopAnchor, viewLeadingAnchor, viewTrailingAnchor, viewBottomAnchor].forEach { $0?.isActive = false }
        viewTopAnchor = childView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: childViewFrame.minY)
        viewLeadingAnchor = childView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: childViewFrame.minX)
        viewTrailingAnchor = childView.trailingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: childViewFrame.minX + childViewFrame.width)
        viewBottomAnchor = childView.bottomAnchor.constraint(equalTo: backgroundView.topAnchor, constant: childViewFrame.minY + childViewFrame.height)
        [viewTopAnchor, viewLeadingAnchor, viewTrailingAnchor, viewBottomAnchor].forEach { $0?.isActive = true }
        setHeightAnchor(height: imageFrame.height)
    }
    
    func setupChildViewLayoutByZoomIn(childView: UIView,
                                      backgroundView: UIView) {
        [viewTopAnchor, viewLeadingAnchor, viewTrailingAnchor, viewBottomAnchor].forEach { $0?.isActive = false }
        viewTopAnchor = childView.topAnchor.constraint(equalTo: backgroundView.topAnchor)
        viewLeadingAnchor = childView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor)
        viewTrailingAnchor = childView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        viewBottomAnchor = childView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
        
        [viewTopAnchor, viewLeadingAnchor, viewTrailingAnchor, viewBottomAnchor].forEach { $0?.isActive = true }
        // 크기 지정 필요 
        let imageHeight = backgroundView.frame.width * viewModel.feed.imageRatio + 100
        setHeightAnchor(height: imageHeight)
    }
    
    private func setHeightAnchor(height: CGFloat) {
        detailImageCollectionViewHeightAnchor?.isActive = false
        detailImageCollectionViewHeightAnchor = detailFeedImageCollectionView.heightAnchor.constraint(equalToConstant: height)
        detailImageCollectionViewHeightAnchor?.isActive = true
    }
}

extension DetailFeedViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FeedPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FeedTransitionAnimation(animationType: .present, dependency: dependency)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FeedTransitionAnimation(animationType: .dismiss, dependency: dependency)
    }
    
}
