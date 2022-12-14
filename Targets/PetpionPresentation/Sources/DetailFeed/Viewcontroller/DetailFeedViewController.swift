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
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium, scale: .large)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray6
        button.addTarget(self, action: #selector(dismissButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func dismissButtonDidTapped() {
        self.dismiss(animated: true)
    }
    
    private lazy var imageSlider: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = .darkGray
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.addTarget(self, action: #selector(imageSliderValueChanged), for: .valueChanged)
        return pageControl
    }()
    
    @objc private func imageSliderValueChanged() {
        viewModel.pageControlValueChanged(imageSlider.currentPage)
    }
    
    private let profileImageButton: CircleButton = {
        let circleImageButton = CircleButton(diameter: 35)
        circleImageButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
        circleImageButton.tintColor = .darkGray
        circleImageButton.backgroundColor = .white
        circleImageButton.layer.borderWidth = 1
        circleImageButton.layer.borderColor = UIColor.lightGray.cgColor
        return circleImageButton
    }()
    
    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView()
        [profileImageButton, profileNameLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular, scale: .medium)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(settingButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func settingButtonDidTapped() {
        print("setting123")
    }
    
    private lazy var battleStackView: UIStackView = {
        let battleCountView: UIStackView = makeSymbolCountStackView(symbol: "flag.2.crossed.fill", countInt: 66, countDouble: nil)
        let winCountView: UIStackView = makeSymbolCountStackView(symbol: "hand.thumbsup.fill", countInt: viewModel.feed.likeCount, countDouble: nil)
        let winRateCountView: UIStackView = makeSymbolCountStackView(symbol: "flame.fill", countInt: nil, countDouble: viewModel.getWinRate())
        let stackView = UIStackView()
        [battleCountView, winCountView, winRateCountView].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.spacing = view.frame.width/6
        stackView.alignment = .bottom
        return stackView
    }()
    private lazy var commentLabel: UILabel = UILabel()
    private lazy var timeLogLabel: UILabel = UILabel()
    
    private var detailImageCollectionViewHeightAnchor: NSLayoutConstraint?
    private var viewTopAnchor: NSLayoutConstraint?
    private var viewLeadingAnchor: NSLayoutConstraint?
    private var viewTrailingAnchor: NSLayoutConstraint?
    private var viewBottomAnchor: NSLayoutConstraint?
    private var dismissButtonTrailingAnchor: NSLayoutConstraint?
    
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
    
    lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(_ :)))
    
    @objc func panAction (_ gesture : UIPanGestureRecognizer){
        let yValue = gesture.translation(in: self.view).y
        guard yValue > 0 else { return }
        
        switch gesture.state {
            
        case .began, .changed:
            animateShrink(currentY: yValue, until: 200)
            
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2) {
                self.view?.transform = CGAffineTransform.identity
            }
            
        default:
            break
        }
    }
    
    private func animateShrink(currentY: CGFloat,until lastPoint: CGFloat) {
        let targetShrinkScale: CGFloat = 0.84
        if currentY < lastPoint {
            let willShrinkScale = (currentY*(1 - targetShrinkScale)) / lastPoint
            let shrinkedScale: CGFloat = 1 - willShrinkScale
            UIView.animate(withDuration: 0.2) {
                self.view?.transform = CGAffineTransform(scaleX: shrinkedScale, y: shrinkedScale)
            }
        } else if currentY > lastPoint + 30 {
            self.dismiss(animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatusBar(hidden: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutDetailFeedImageCollectionView()
        layoutDismissButton()
        layoutImageSlider()
        layoutProfileStackView()
        layoutSettingButton()
        layoutBattleStackView()
        layoutCommentLabel()
        layoutTimeLogLabel()
    }
    
    private func layoutDetailFeedImageCollectionView() {
        view.addSubview(detailFeedImageCollectionView)
        detailFeedImageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailFeedImageCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            detailFeedImageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailFeedImageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        detailFeedImageCollectionView.roundCorners(cornerRadius: 10)
    }
    
    private func layoutDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: detailFeedImageCollectionView.topAnchor, constant: 18),
            dismissButton.heightAnchor.constraint(equalToConstant: 35),
            dismissButton.widthAnchor.constraint(equalToConstant: 35)
        ])
        dismissButtonTrailingAnchor = dismissButton.trailingAnchor.constraint(equalTo: detailFeedImageCollectionView.trailingAnchor, constant: 50)
        dismissButtonTrailingAnchor?.isActive = true
    }
    
    private func layoutImageSlider() {
        view.addSubview(imageSlider)
        imageSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageSlider.bottomAnchor.constraint(equalTo: detailFeedImageCollectionView.bottomAnchor),
            imageSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageSlider.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func layoutProfileStackView() {
        view.addSubview(profileStackView)
        profileStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileStackView.topAnchor.constraint(equalTo: detailFeedImageCollectionView.bottomAnchor, constant: 10),
            profileStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
        ])
        profileStackView.isHidden = true
    }
    
    private func layoutSettingButton() {
        view.addSubview(settingButton)
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingButton.centerYAnchor.constraint(equalTo: profileStackView.centerYAnchor),
            settingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
        ])
        settingButton.isHidden = true
    }
    
    private func layoutBattleStackView() {
        view.addSubview(battleStackView)
        battleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            battleStackView.topAnchor.constraint(equalTo: profileStackView.bottomAnchor, constant: 10),
            battleStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        battleStackView.isHidden = true
    }
    
    private func layoutCommentLabel() {
        view.addSubview(commentLabel)
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentLabel.topAnchor.constraint(equalTo: battleStackView.bottomAnchor, constant: 20),
            commentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        commentLabel.isHidden = true
    }
    
    private func layoutTimeLogLabel() {
        view.addSubview(timeLogLabel)
        timeLogLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLogLabel.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 10),
            timeLogLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeLogLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        timeLogLabel.isHidden = true
    }
    
    // MARK: - Configure
    private func configure() {
        view.addGestureRecognizer(panGestureRecognizer)
        view.backgroundColor = .systemBackground
        configureDetailFeedImageCollectionView()
        configureCommentLabel()
        configureTimeLogLabel()
        imageSlider.numberOfPages = viewModel.feed.imagesCount
        profileNameLabel.text = "TempUser"
        
    }
    
    private func configureDetailFeedImageCollectionView() {
        detailFeedImageCollectionView.contentInsetAdjustmentBehavior = .never
        detailFeedImageCollectionView.alwaysBounceVertical = false
        detailFeedImageCollectionView.showsVerticalScrollIndicator = false
        detailFeedImageCollectionView.showsHorizontalScrollIndicator = false
        detailFeedImageCollectionView.setCollectionViewLayout(viewModel.configureDetailFeedImageCollectionViewLayout(), animated: false)
        
        // make shadow hide when dismiss
        detailFeedImageCollectionView.layer.shadowColor = UIColor.black.cgColor
        detailFeedImageCollectionView.layer.masksToBounds = false
        detailFeedImageCollectionView.layer.shadowOffset = CGSize(width: 0, height: 4)
        detailFeedImageCollectionView.layer.shadowRadius = 5
        detailFeedImageCollectionView.layer.shadowOpacity = 0.3
    }
    
    private func configureCommentLabel() {
        commentLabel.text = viewModel.feed.message
        commentLabel.numberOfLines = 0
        commentLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        commentLabel.sizeToFit()
    }
    
    private func configureTimeLogLabel() {
        timeLogLabel.text = .petpionDateToString(viewModel.feed.uploadDate)
        timeLogLabel.numberOfLines = 0
        timeLogLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        timeLogLabel.textColor = .gray
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
    enum ZoomState {
        case zoomIn
        case zoomOut
    }
    func setChildViewLayoutByZoomOut(childView: UIView,
                                     backgroundView: UIView,
                                     childViewFrame: CGRect,
                                     imageFrame: CGRect) {
        self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        imageSlider.isHidden = true
        settingButton.isHidden = true
        profileStackView.isHidden = true
        battleStackView.isHidden = true
        commentLabel.isHidden = true
        timeLogLabel.isHidden = true
        view.backgroundColor = .clear
        detailFeedImageCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: [], animated: false)
        detailFeedImageCollectionView.layer.shadowOffset = CGSize(width: 0, height: 0)
        [viewTopAnchor, viewLeadingAnchor, viewTrailingAnchor, viewBottomAnchor, dismissButtonTrailingAnchor].forEach { $0?.isActive = false }
        dismissButtonTrailingAnchor = dismissButton.trailingAnchor.constraint(equalTo: detailFeedImageCollectionView.trailingAnchor, constant: 50)
        changeViewLayoutAnchors(state: .zoomOut, childView: childView, backgroundView: backgroundView, frame: childViewFrame)
        [viewTopAnchor, viewLeadingAnchor, viewTrailingAnchor, viewBottomAnchor, dismissButtonTrailingAnchor].forEach { $0?.isActive = true }
        setHeightAnchor(height: imageFrame.height)
    }
    
    func setupChildViewLayoutByZoomIn(childView: UIView,
                                      backgroundView: UIView) {
        if viewModel.feed.imagesCount > 1 {
            imageSlider.numberOfPages = viewModel.feed.imagesCount
            imageSlider.isHidden = false
        }
        detailFeedImageCollectionView.layer.shadowOffset = CGSize(width: 0, height: 4)
        settingButton.isHidden = false
        profileStackView.isHidden = false
        battleStackView.isHidden = false
        commentLabel.isHidden = false
        timeLogLabel.isHidden = false
        view.backgroundColor = .systemBackground
        [viewTopAnchor, viewLeadingAnchor, viewTrailingAnchor, viewBottomAnchor, dismissButtonTrailingAnchor].forEach { $0?.isActive = false }
        dismissButtonTrailingAnchor = dismissButton.trailingAnchor.constraint(equalTo: detailFeedImageCollectionView.trailingAnchor, constant: -18)
        changeViewLayoutAnchors(state: .zoomIn, childView: childView, backgroundView: backgroundView)
        [viewTopAnchor, viewLeadingAnchor, viewTrailingAnchor, viewBottomAnchor, dismissButtonTrailingAnchor].forEach { $0?.isActive = true }
        // 크기 지정 필요
        let imageHeight = backgroundView.frame.width * viewModel.feed.imageRatio
        setHeightAnchor(height: imageHeight)
    }
    
    private func changeViewLayoutAnchors(state: ZoomState,
                                         childView: UIView,
                                         backgroundView: UIView,
                                         frame: CGRect = .init()) {
        switch state {
        case .zoomIn:
            viewTopAnchor = childView.topAnchor.constraint(equalTo: backgroundView.topAnchor)
            viewLeadingAnchor = childView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor)
            viewTrailingAnchor = childView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
            viewBottomAnchor = childView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
        case .zoomOut:
            viewTopAnchor = childView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: frame.minY)
            viewLeadingAnchor = childView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: frame.minX)
            viewTrailingAnchor = childView.trailingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: frame.minX + frame.width)
            viewBottomAnchor = childView.bottomAnchor.constraint(equalTo: backgroundView.topAnchor, constant: frame.minY + frame.height)
        }
    }
    
    private func setHeightAnchor(height: CGFloat) {
        detailImageCollectionViewHeightAnchor?.isActive = false
        detailImageCollectionViewHeightAnchor = detailFeedImageCollectionView.heightAnchor.constraint(equalToConstant: height)
        detailImageCollectionViewHeightAnchor?.isActive = true
    }
    
    private func makeSymbolCountStackView(symbol: String, countInt: Int?, countDouble: Double?) -> UIStackView {
        
        let symbolImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: symbol)
            imageView.tintColor = .black
            return imageView
        }()
        
        let countLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 15)
            if let countInt = countInt {
                label.text = String(countInt)
            }
            if let countDouble = countDouble {
                label.text = String(countDouble)+"%"
            }
            return label
        }()
        
        let symbolCountStackView: UIStackView = {
            let stackView = UIStackView()
            [symbolImageView, countLabel].forEach {
                stackView.addArrangedSubview($0)
            }
            stackView.spacing = 5
            stackView.alignment = .bottom
            return stackView
        }()
        
        return symbolCountStackView
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
