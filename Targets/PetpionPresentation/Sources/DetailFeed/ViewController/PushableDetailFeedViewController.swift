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

import PetpionDomain
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
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        let radius: CGFloat = 18
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: radius*2),
            imageView.widthAnchor.constraint(equalToConstant: radius*2)
        ])
        imageView.image = UIImage(systemName: "person.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .darkGray
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.roundCorners(cornerRadius: radius)
        return imageView
    }()
    
    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView()
        [profileImageView, profileNameLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()

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
    
    private var settingBarButton: UIBarButtonItem?
    private var settingAlertController: UIAlertController?
    private var deleteAlertController: UIAlertController?
    private var ellipsisBarButton: UIBarButtonItem?
    private var detailFeedAlertController: UIAlertController?
    
    private lazy var indicatorBarButton: UIBarButtonItem = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
        return UIBarButtonItem(customView: indicatorView)
    }()
    
    private let duplicatedToastLabel: UILabel = {
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
    private let duplicatedToastLabelHeightConstant: CGFloat = 40
    private lazy var duplicatedToastLabelTopAnchor: NSLayoutConstraint? = duplicatedToastLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: duplicatedToastLabelHeightConstant)
    
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
        self.navigationItem.title = "피드"
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
    
    private func layoutDuplicatedToastLabel() {
        view.addSubview(duplicatedToastLabel)
        NSLayoutConstraint.activate([
            duplicatedToastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            duplicatedToastLabel.widthAnchor.constraint(equalToConstant: view.frame.width*0.6),
            duplicatedToastLabel.heightAnchor.constraint(equalToConstant: duplicatedToastLabelHeightConstant)
        ])
        duplicatedToastLabelTopAnchor?.isActive = true
        duplicatedToastLabel.roundCorners(cornerRadius: 15)
    }

    
    // MARK: - Configure
    private func configure() {
        configureNavigationItem()
        configureDetailFeedImageCollectionView()
        configureCommentLabel()
        configureTimeLogLabel()
        imageSlider.numberOfPages = viewModel.feed.imageCount
        configureProfileStackView()
        configureCollectionViewShadowOn()
    }
    
    private func configureNavigationItem() {
        switch viewModel.detailFeedStyle {
        case .editableUserDetailFeed:
            configureSettingBarButton()
            configureAlertController()
        case .uneditableUserDetailFeed:
            self.navigationItem.rightBarButtonItem = nil
        case .otherUserDetailFeed:
            layoutDuplicatedToastLabel()
            configureEllipsisBarButton()
            configureDetailFeedAlertViewController()
        }
    }
    
    private func configureSettingBarButton() {
        settingBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(settingButtonDidTapped))
        if let settingBarButton = settingBarButton {
            settingBarButton.tintColor = .black
            self.navigationItem.rightBarButtonItem = settingBarButton
        }
    }
    
    @objc private func settingButtonDidTapped() {
        if let settingAlertController = settingAlertController {
            present(settingAlertController, animated: true)
        }
    }
    
    private func configureEllipsisBarButton() {
        ellipsisBarButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(ellipsisButtonDidTapped))
        if let ellipsisBarButton = ellipsisBarButton {
            ellipsisBarButton.tintColor = .black
            self.navigationItem.rightBarButtonItem = ellipsisBarButton
        }
    }
    
    @objc func ellipsisButtonDidTapped() {
        if let detailFeedAlertController = detailFeedAlertController {
            present(detailFeedAlertController, animated: true)
        }
    }
    
    private func configureDetailFeedAlertViewController() {
        detailFeedAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let detailFeedAlertController = detailFeedAlertController {
            let blockFeed = UIAlertAction(title: "피드 차단", style: .destructive, handler: { [weak self] _ in
                //                self?.viewModel.editFeed()
            })
            let reportFeed = UIAlertAction(title: "피드 신고", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                if strongSelf.viewModel.isReportedFeed() {
                    self?.startDuplicatedLabelToastAnimation(actionType: .report)
                } else {
                    self?.detailFeedCoordinator?.presentReportFeedViewController()
                }
            })
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            
            [blockFeed, reportFeed, cancel].forEach { detailFeedAlertController.addAction($0) }
        }
    }
    
    private func startDuplicatedLabelToastAnimation(actionType: UserActionType) {
        switch actionType {
        case .block:
            duplicatedToastLabel.text = "이미 차단한 피드입니다."
        case .report:
            duplicatedToastLabel.text = "이미 신고한 피드입니다."
        }
        duplicatedToastLabel.isHidden = false
        duplicatedToastLabelTopAnchor?.isActive = false
        duplicatedToastLabelTopAnchor = duplicatedToastLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -(duplicatedToastLabelHeightConstant*2))
        duplicatedToastLabelTopAnchor?.isActive = true
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.popDuplicatedLabelToastAnimation()
        })
    }
    
    private func popDuplicatedLabelToastAnimation() {
        duplicatedToastLabelTopAnchor?.isActive = false
        duplicatedToastLabelTopAnchor = duplicatedToastLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: duplicatedToastLabelHeightConstant)
        duplicatedToastLabelTopAnchor?.isActive = true
        UIView.animate(withDuration: 0.5,
                       delay: 2.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.duplicatedToastLabel.isHidden = true
        })
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
        profileImageView.image = viewModel.feed.uploader.profileImage
    }
    
    private func configureAlertController() {
        settingAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        deleteAlertController = UIAlertController(title: "정말 피드를 삭제하시겠어요?", message: "삭제한 정보들은 되돌릴수 없습니다.", preferredStyle: .alert)
        if  let settingAlertController = settingAlertController,
            let deleteAlertController = deleteAlertController {
            let editAction = UIAlertAction(title: "수정하기", style: .default, handler: { [weak self] _ in
                self?.viewModel.editFeed()
            })
            let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive, handler: { [weak self] _ in
                self?.present(deleteAlertController, animated: true)
            })
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            
            [editAction, deleteAction, cancel].forEach { settingAlertController.addAction($0) }
            let willDelete = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
                self?.viewModel.deleteFeed()
            }
            let willNotDelete = UIAlertAction(title: "취소", style: .default)
            
            [willDelete, willNotDelete].forEach { deleteAlertController.addAction($0) }
        }
    }
    
    // MARK: - Binding
    private func binding() {
        bindSnapshot()
        bindCurrentImageIndex()
        bindDetailFeedViewState()
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
    
    private func bindDetailFeedViewState() {
        switch viewModel.detailFeedStyle {
            
        case .editableUserDetailFeed:
            bindFeedManagingSubject()
        case .uneditableUserDetailFeed:
            return
        case .otherUserDetailFeed:
            return
        }
    }
    
    private func bindFeedManagingSubject() {
        viewModel.feedManagingSubject.sink { [weak self] state in
            guard let strongSelf = self else { return }
            switch state {
            case .delete:
                self?.navigationItem.rightBarButtonItem = strongSelf.indicatorBarButton
            case .edit:
                self?.detailFeedCoordinator?.pushEditFeedView(listener: strongSelf, snapshot: strongSelf.datasource.snapshot())
            case .finish:
                self?.navigationItem.rightBarButtonItem = strongSelf.settingBarButton
                self?.detailFeedCoordinator?.popDetailFeedView()
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

extension PushableDetailFeedViewController: EditFeedViewControllerListener {
    
    func feedDidEdited(to feed: PetpionFeed) {
        commentLabel.text = feed.message
    }
}
