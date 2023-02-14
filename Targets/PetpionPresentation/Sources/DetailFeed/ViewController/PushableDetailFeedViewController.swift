//
//  DetailFeedPushableViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/10.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionCore

final class PushableDetailFeedViewController: HasCoordinatorViewController {
    
    lazy var detailFeedCoordinator: DetailFeedCoordinator? = {
        self.coordinator as? DetailFeedCoordinator
    }()
    private var cancellables = Set<AnyCancellable>()

    let viewModel: DetailFeedViewModelProtocol
    
    private lazy var detailFeedImageCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                                        collectionViewLayout: UICollectionViewLayout())
    private lazy var datasource = viewModel.makeDetailFeedImageCollectionViewDataSource(collectionView: detailFeedImageCollectionView)
    
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
        Task {
            await viewModel.deleteFeed()
        }
        print("setting123")
    }
    
    private lazy var battleStackView: UIStackView = {
        let battleCountView: UIStackView = makeSymbolCountStackView(imageName: "fight", countInt: viewModel.feed.battleCount, countDouble: nil)
        let winCountView: UIStackView = makeSymbolCountStackView(imageName: "win", countInt: viewModel.feed.likeCount, countDouble: nil)
        let winRateCountView: UIStackView = makeSymbolCountStackView(imageName: "winPercent", countInt: nil, countDouble: viewModel.getWinRate())
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
    
    // MARK: - Initialize
    init(viewModel: DetailFeedViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "피드"
        view.backgroundColor = .white
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
        let imageHeight = view.frame.width * viewModel.feed.imageRatio
        NSLayoutConstraint.activate([
            detailFeedImageCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailFeedImageCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            detailFeedImageCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            detailFeedImageCollectionView.heightAnchor.constraint(equalToConstant: imageHeight)
        ])
        detailFeedImageCollectionView.roundCorners(cornerRadius: 10)
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
    }
    
    private func layoutSettingButton() {
        view.addSubview(settingButton)
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingButton.centerYAnchor.constraint(equalTo: profileStackView.centerYAnchor),
            settingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
        ])
    }
    
    private func layoutBattleStackView() {
        view.addSubview(battleStackView)
        battleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            battleStackView.topAnchor.constraint(equalTo: profileStackView.bottomAnchor, constant: 10),
            battleStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func layoutCommentLabel() {
        view.addSubview(commentLabel)
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentLabel.topAnchor.constraint(equalTo: battleStackView.bottomAnchor, constant: 20),
            commentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func layoutTimeLogLabel() {
        view.addSubview(timeLogLabel)
        timeLogLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLogLabel.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 10),
            timeLogLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeLogLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        view.backgroundColor = .white
        configureDetailFeedImageCollectionView()
        configureCommentLabel()
        configureTimeLogLabel()
        imageSlider.numberOfPages = viewModel.feed.imageCount
        configureProfileStackView()
        configureCollectionViewShadowOn()
    }
    
    private func configureDetailFeedImageCollectionView() {
        detailFeedImageCollectionView.contentInsetAdjustmentBehavior = .never
        detailFeedImageCollectionView.alwaysBounceVertical = false
        detailFeedImageCollectionView.showsVerticalScrollIndicator = false
        detailFeedImageCollectionView.showsHorizontalScrollIndicator = false
        detailFeedImageCollectionView.setCollectionViewLayout(viewModel.configureDetailFeedImageCollectionViewLayout(), animated: false)
        
        detailFeedImageCollectionView.layer.shadowColor = UIColor.black.cgColor
        detailFeedImageCollectionView.layer.masksToBounds = false
        detailFeedImageCollectionView.layer.shadowRadius = 5
        detailFeedImageCollectionView.layer.shadowOpacity = 0.3
    }
    
    func configureCollectionViewShadowOn() {
        detailFeedImageCollectionView.layer.shadowOffset = CGSize(width: 0, height: 4)
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
    
    private func configureProfileStackView() {
        profileNameLabel.text = viewModel.feed.uploader.nickname
        profileImageButton.setImage(viewModel.feed.uploader.profileImage, for: .normal)
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
    
    private func makeSymbolCountStackView(imageName: String, countInt: Int?, countDouble: Double?) -> UIStackView {
        
        let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: imageName)
            return imageView
        }()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 25),
            imageView.widthAnchor.constraint(equalToConstant: 25)
        ])
        
        let countLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .darkGray
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
            [imageView, countLabel].forEach {
                stackView.addArrangedSubview($0)
            }
            stackView.spacing = 7
            stackView.alignment = .center
            return stackView
        }()
        
        return symbolCountStackView
    }

}
