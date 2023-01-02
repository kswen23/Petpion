//
//  VotingListCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/22.
//  Copyright © 2022 Petpion. All rights reserved.
//

import AVFoundation
import Combine
import Foundation
import UIKit

import Lottie
import PetpionDomain

enum ImageCollectionViewSection {
    case top
    case bottom
}

protocol VotingListCollectionViewCellDelegate {
    func voteCollectionViewDidTapped(to section: ImageCollectionViewSection)
}

final class VotingListCollectionViewCell: UICollectionViewCell {
    private var cancellables = Set<AnyCancellable>()
    
    var viewModel: VotingListCollectionViewCellViewModelProtocol?
    var parentableViewController: VotingListCollectionViewCellDelegate?
    
    private lazy var topImageCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                                 collectionViewLayout: UICollectionViewLayout())
    private lazy var bottomImageCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                                    collectionViewLayout: UICollectionViewLayout())
    private lazy var topImageCollectionViewDataSource = makeImageCollectionViewDataSource(collectionView: topImageCollectionView)
    private lazy var bottomImageCollectionViewDataSource = makeImageCollectionViewDataSource(collectionView: bottomImageCollectionView)
    
    private var topImageCollectionViewBottomAnchor: NSLayoutConstraint?
    private var topImageCollectionViewHeightAnchor: NSLayoutConstraint?
    private var bottomImageCollectionViewTopAnchor: NSLayoutConstraint?
    private var bottomImageCollectionViewHeightAnchor: NSLayoutConstraint?
    
    private lazy var versusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "versusImage")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private lazy var topImagePagingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.tintColor = .white
        return button
    }()
    
    private lazy var bottomImagePagingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.tintColor = .white
        return button
    }()
    
    private lazy var topDoubleTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_ : )))
        tapGesture.numberOfTapsRequired = 2
        return tapGesture
    }()
    
    private lazy var bottomDoubleTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_ : )))
        tapGesture.numberOfTapsRequired = 2
        return tapGesture
    }()
    
    @objc private func doubleTapped(_ sender: UITapGestureRecognizer) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        if sender.view == topImageCollectionView {
            animateAfterVoting(section: .top) {
                self.parentableViewController?.voteCollectionViewDidTapped(to: .top)
            }
        } else if sender.view == bottomImageCollectionView {
            animateAfterVoting(section: .bottom) {
                self.parentableViewController?.voteCollectionViewDidTapped(to: .bottom)
            }
        }
    }
    
    private lazy var winEffectView: LottieAnimationView = {
        let animationView: LottieAnimationView = .init(name: "winEffect")
        animationView.contentMode = .scaleAspectFill
        animationView.isHidden = true
        return animationView
    }()
    
    // MARK: - Cell LifeCycle
    public override func prepareForReuse() {
        super.prepareForReuse()
        resetLayout()
    }
    
    private func resetLayout() {
        viewModel = nil
        topImageCollectionViewHeightAnchor?.isActive = false
        bottomImageCollectionViewHeightAnchor?.isActive = false
        topImageCollectionViewBottomAnchor?.isActive = false
        bottomImageCollectionViewTopAnchor?.isActive = false
        topImageCollectionViewBottomAnchor = topImageCollectionView.bottomAnchor.constraint(equalTo: self.centerYAnchor)
        bottomImageCollectionViewTopAnchor = bottomImageCollectionView.topAnchor.constraint(equalTo: self.centerYAnchor)
        topImageCollectionViewHeightAnchor = topImageCollectionView.heightAnchor.constraint(equalToConstant: self.frame.height/2)
        bottomImageCollectionViewHeightAnchor = bottomImageCollectionView.heightAnchor.constraint(equalToConstant: self.frame.height/2)
        topImageCollectionViewHeightAnchor?.isActive = true
        bottomImageCollectionViewHeightAnchor?.isActive = true
        topImageCollectionViewBottomAnchor?.isActive = true
        bottomImageCollectionViewTopAnchor?.isActive = true
        versusImageView.isHidden = false
        topImageCollectionView.roundCorners(cornerRadius: 45, maskedCorners: [.layerMaxXMinYCorner, .layerMinXMinYCorner])
        bottomImageCollectionView.roundCorners(cornerRadius: 45, maskedCorners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
    }
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        layout()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        layoutTopImageCollectionView()
        layoutBottomImageCollectionView()
        layoutTopImagePagingButton()
        layoutBottomImagePagingButton()
        layoutVersusImageView()
        layoutWinEffectAnimationView()
    }
    
    private func layoutTopImageCollectionView() {
        self.addSubview(topImageCollectionView)
        topImageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topImageCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topImageCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        topImageCollectionViewBottomAnchor = topImageCollectionView.bottomAnchor.constraint(equalTo: self.centerYAnchor)
        topImageCollectionViewHeightAnchor = topImageCollectionView.heightAnchor.constraint(equalToConstant: self.frame.height/2)
        topImageCollectionViewBottomAnchor?.isActive = true
        topImageCollectionViewHeightAnchor?.isActive = true
    }
    
    private func layoutBottomImageCollectionView() {
        self.addSubview(bottomImageCollectionView)
        bottomImageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomImageCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomImageCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        bottomImageCollectionViewTopAnchor = bottomImageCollectionView.topAnchor.constraint(equalTo: self.centerYAnchor)
        bottomImageCollectionViewHeightAnchor = bottomImageCollectionView.heightAnchor.constraint(equalToConstant: self.frame.height/2)
        bottomImageCollectionViewTopAnchor?.isActive = true
        bottomImageCollectionViewHeightAnchor?.isActive = true
    }
    
    private func layoutTopImagePagingButton() {
        self.addSubview(topImagePagingButton)
        topImagePagingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topImagePagingButton.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -10),
            topImagePagingButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            topImagePagingButton.widthAnchor.constraint(equalToConstant: 30),
            topImagePagingButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    private func layoutBottomImagePagingButton() {
        self.addSubview(bottomImagePagingButton)
        bottomImagePagingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomImagePagingButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 10),
            bottomImagePagingButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            bottomImagePagingButton.widthAnchor.constraint(equalToConstant: 30),
            bottomImagePagingButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    private func layoutVersusImageView() {
        self.addSubview(versusImageView)
        versusImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            versusImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            versusImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            versusImageView.widthAnchor.constraint(equalToConstant: 280),
            versusImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func layoutWinEffectAnimationView() {
        self.addSubview(winEffectView)
        winEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            winEffectView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            winEffectView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            winEffectView.heightAnchor.constraint(equalToConstant: 400),
            winEffectView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        configureTopImageCollectionView()
        configureBottomImageCollectionView()
        configureTopImagePagingButton()
        configureBottomImagePagingButton()
    }
    
    private func configureTopImageCollectionView() {
        let topLayoutSection = configureImageCollectionViewSection()
        topLayoutSection.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
            let index = Int(max(0, round(point.x / environment.container.contentSize.width))) + 1
            self?.viewModel?.topImageIndex.send(index)
        }
        topImageCollectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: topLayoutSection), animated: true)
        topImageCollectionView.backgroundColor = .systemBackground
        topImageCollectionView.contentInsetAdjustmentBehavior = .never
        topImageCollectionView.alwaysBounceVertical = false
        topImageCollectionView.showsVerticalScrollIndicator = false
        topImageCollectionView.showsHorizontalScrollIndicator = false
        topImageCollectionView.isScrollEnabled = true
        topImageCollectionView.addGestureRecognizer(topDoubleTapGesture)
        topImageCollectionView.roundCorners(cornerRadius: 45, maskedCorners: [.layerMaxXMinYCorner, .layerMinXMinYCorner])
        topImageCollectionView.layer.borderWidth = 10
        topImageCollectionView.layer.borderColor = CustomColor.VotePetpionRedColor.cgColor
    }
    
    private func configureBottomImageCollectionView() {
        let bottomLayoutSection = configureImageCollectionViewSection()
        bottomLayoutSection.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
            let index = Int(max(0, round(point.x / environment.container.contentSize.width))) + 1
            self?.viewModel?.bottomImageIndex.send(index)
        }
        bottomImageCollectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: bottomLayoutSection), animated: true)
        bottomImageCollectionView.backgroundColor = .systemBackground
        bottomImageCollectionView.contentInsetAdjustmentBehavior = .never
        bottomImageCollectionView.alwaysBounceVertical = false
        bottomImageCollectionView.showsVerticalScrollIndicator = false
        bottomImageCollectionView.showsHorizontalScrollIndicator = false
        bottomImageCollectionView.isScrollEnabled = true
        bottomImageCollectionView.addGestureRecognizer(bottomDoubleTapGesture)
        bottomImageCollectionView.roundCorners(cornerRadius: 45, maskedCorners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        bottomImageCollectionView.layer.borderWidth = 10
        bottomImageCollectionView.layer.borderColor = CustomColor.VotePetpionBlueColor.cgColor
    }
    
    private func configureImageCollectionViewSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    private func configureTopImagePagingButton() {
        topImagePagingButton.roundCorners(cornerRadius: 10)
        topImagePagingButton.titleLabel?.font = .systemFont(ofSize: 14)
        topImagePagingButton.isHidden = true
    }
    
    private func configureBottomImagePagingButton() {
        bottomImagePagingButton.roundCorners(cornerRadius: 10)
        bottomImagePagingButton.titleLabel?.font = .systemFont(ofSize: 14)
        bottomImagePagingButton.isHidden = true
    }
    
    private func configureDetailImage(dataSource: UICollectionViewDiffableDataSource<ImageCollectionViewSection, URL>,
                                      section: ImageCollectionViewSection,
                                      with urlArr: [URL]) {
        var collectionViewSnapshot = NSDiffableDataSourceSnapshot<ImageCollectionViewSection, URL>()
        collectionViewSnapshot.appendSections([section])
        collectionViewSnapshot.appendItems(urlArr, toSection: section)
        dataSource.apply(collectionViewSnapshot)
    }
    
    private func configureImagePagingIndex() {
        guard let topFeedImageCount = viewModel?.votePare.feed1.imageCount,
              let bottomFeedImageCount = viewModel?.votePare.feed2.imageCount else { return }
        topImagePagingButton.isHidden = topFeedImageCount > 1 ? false : true
        bottomImagePagingButton.isHidden = bottomFeedImageCount > 1 ? false : true
        topImageCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: [], animated: false)
        bottomImageCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: [], animated: false)
        
        viewModel?.topImageIndex.sink(receiveValue: { index in
            self.topImagePagingButton.setTitle("\(index)/\(topFeedImageCount)", for: .normal)
        }).store(in: &cancellables)
        
        viewModel?.bottomImageIndex.sink(receiveValue: { index in
            self.bottomImagePagingButton.setTitle("\(index)/\(bottomFeedImageCount)", for: .normal)
        }).store(in: &cancellables)
    }
    
    private func makeImageCollectionViewDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<ImageCollectionViewSection, URL> {
        let registration = makeImageCollectionViewCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func makeImageCollectionViewCellRegistration() -> UICollectionView.CellRegistration<ImageCollectionViewCell, URL> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            cell.configureImageView(with: item)
        }
    }
    
    // MARK: - binding
    func bindViewModel() {
        guard let topURLArr = viewModel?.votePare.feed1.imageURLArr,
              let bottomURLArr = viewModel?.votePare.feed2.imageURLArr else { return }
        configureDetailImage(dataSource: topImageCollectionViewDataSource,
                             section: .top,
                             with: topURLArr)
        configureDetailImage(dataSource: bottomImageCollectionViewDataSource,
                             section: .bottom,
                             with: bottomURLArr)
        configureImagePagingIndex()
    }
    
    // MARK: - Animating
    func animateAfterVoting(section: ImageCollectionViewSection, completion: @escaping (()-> Void)) {
        [topImagePagingButton, bottomImagePagingButton, versusImageView].forEach { view in
            view.isHidden = true
        }
        switch section {
        case .top:
            animateTopSectionSelected(completion: completion)
        case .bottom:
            animateBottomSectionSelected(completion: completion)
        }
    }
    
    private func animateTopSectionSelected(completion: @escaping (()-> Void)) {
        dropDownBottomCollectionView()
        increaseTopCollectionView(completion: completion)
        topImageCollectionView.visibleCells.forEach { cell in
            guard let cell = cell as? ImageCollectionViewCell else { return }
            cell.imageView.contentMode = .scaleAspectFit
        }
    }
    
    private func dropDownBottomCollectionView() {
        bottomImageCollectionViewTopAnchor?.isActive = false
        bottomImageCollectionViewTopAnchor = bottomImageCollectionView.topAnchor.constraint(equalTo: self.bottomAnchor)
        bottomImageCollectionViewTopAnchor?.isActive = true
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.layoutIfNeeded()
        }
    }
    
    private func increaseTopCollectionView(completion: @escaping (()-> Void)) {
        topImageCollectionView.roundCorners(cornerRadius: 45)
        topImageCollectionViewBottomAnchor?.isActive = false
        topImageCollectionViewHeightAnchor?.isActive = false
        topImageCollectionViewBottomAnchor = topImageCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        topImageCollectionViewHeightAnchor = topImageCollectionView.heightAnchor.constraint(equalToConstant: self.frame.height)
        topImageCollectionViewBottomAnchor?.isActive = true
        topImageCollectionViewHeightAnchor?.isActive = true
        UIView.animate(withDuration: 0.4, delay: 0) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.winEffectView.isHidden = false
            self.winEffectView.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.winEffectView.isHidden = true
                completion()
            }
        }
    }
    
    private func animateBottomSectionSelected(completion: @escaping (()-> Void)) {
        raiseUpTopCollectionView()
        increaseBottomCollectionView(completion: completion)
        bottomImageCollectionView.visibleCells.forEach { cell in
            guard let cell = cell as? ImageCollectionViewCell else { return }
            cell.imageView.contentMode = .scaleAspectFit
        }
    }
    
    private func raiseUpTopCollectionView() {
        topImageCollectionViewBottomAnchor?.isActive = false
        topImageCollectionViewBottomAnchor = topImageCollectionView.bottomAnchor.constraint(equalTo: self.topAnchor)
        topImageCollectionViewBottomAnchor?.isActive = true
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.layoutIfNeeded()
        }
    }
    
    private func increaseBottomCollectionView(completion: @escaping (()-> Void)) {
        bottomImageCollectionView.roundCorners(cornerRadius: 45)
        bottomImageCollectionViewTopAnchor?.isActive = false
        bottomImageCollectionViewHeightAnchor?.isActive = false
        bottomImageCollectionViewTopAnchor = bottomImageCollectionView.topAnchor.constraint(equalTo: self.topAnchor)
        bottomImageCollectionViewHeightAnchor = bottomImageCollectionView.heightAnchor.constraint(equalToConstant: self.frame.height)
        bottomImageCollectionViewTopAnchor?.isActive = true
        bottomImageCollectionViewHeightAnchor?.isActive = true
        UIView.animate(withDuration: 0.4, delay: 0) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.winEffectView.isHidden = false
            self.winEffectView.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.winEffectView.isHidden = true
                completion()
            }
        }
    }
}
