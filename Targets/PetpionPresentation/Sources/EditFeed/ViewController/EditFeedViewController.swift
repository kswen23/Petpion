//
//  EditFeedViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/15.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionDomain
import PetpionCore

public protocol EditFeedViewControllerListener: NSObject {
    func feedDidEdited(to feed: PetpionFeed)
}

final class EditFeedViewController: HasCoordinatorViewController {
    
    lazy var editFeedCoordinator: EditFeedCoordinator? = {
        self.coordinator as? EditFeedCoordinator
    }()
    private var cancellables = Set<AnyCancellable>()
    
    let viewModel: EditFeedViewModelProtocol
    weak var listener: EditFeedViewControllerListener?
    lazy var dataSource: UICollectionViewDiffableDataSource<Int, URL> = makeDetailFeedImageCollectionViewDataSource()
    var snapshot: NSDiffableDataSourceSnapshot<Int, URL>?
    
    private lazy var detailFeedImageCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                                        collectionViewLayout: UICollectionViewLayout())
    private lazy var baseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.delegate = self
        return scrollView
    }()
    private let containerView: UIView = UIView()
    
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
    
    private let backgroundTextView: UIView = UIView()
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = viewModel.feed.message
        textView.font = UIFont.systemFont(ofSize: 16, weight: .light)
        textView.becomeFirstResponder()
        return textView
    }()
    
    private lazy var doneBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneButtonDidTapped))
        barButton.tintColor = .lightGray
        barButton.isEnabled = false
        return barButton
    }()
    
    @objc private func doneButtonDidTapped() {
        viewModel.doneBarButtonDidTapped()
    }
    
    private lazy var cancelBarButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonDidTapped))
    }()
    
    @objc private func cancelButtonDidTapped() {
        editFeedCoordinator?.popEditFeedView()
    }
    
    private lazy var indicatorBarButton: UIBarButtonItem = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
        return UIBarButtonItem(customView: indicatorView)
    }()
    
    // MARK: - Initialize
    init(viewModel: EditFeedViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        addKeyboardObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeKeyboardObserver()
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem = doneBarButton
        self.navigationItem.leftBarButtonItem = cancelBarButton
        self.navigationItem.title = "정보 수정"
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
        layoutBaseScrollView()
        layoutContainerView()
        layoutDetailFeedImageCollectionView()
        layoutImageSlider()
        layoutProfileStackView()
        layoutBattleStackView()
        layoutTextView()
    }
    
    private func layoutBaseScrollView() {
        view.addSubview(baseScrollView)
        baseScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            baseScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            baseScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            baseScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func layoutContainerView() {
        baseScrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: baseScrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: baseScrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: baseScrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: baseScrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: baseScrollView.widthAnchor)
        ])
        let heightAnchor = containerView.heightAnchor.constraint(equalTo: baseScrollView.heightAnchor)
        heightAnchor.priority = .defaultHigh
        heightAnchor.isActive = true
    }
    
    
    private func layoutDetailFeedImageCollectionView() {
        containerView.addSubview(detailFeedImageCollectionView)
        detailFeedImageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        let imageHeight = view.frame.width * viewModel.feed.imageRatio
        NSLayoutConstraint.activate([
            detailFeedImageCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            detailFeedImageCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            detailFeedImageCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            detailFeedImageCollectionView.heightAnchor.constraint(equalToConstant: imageHeight)
        ])
        detailFeedImageCollectionView.roundCorners(cornerRadius: 10)
    }
    
    private func layoutImageSlider() {
        containerView.addSubview(imageSlider)
        imageSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageSlider.bottomAnchor.constraint(equalTo: detailFeedImageCollectionView.bottomAnchor),
            imageSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageSlider.heightAnchor.constraint(equalToConstant: 30)
        ])
        imageSlider.numberOfPages = viewModel.feed.imageCount
    }
    
    private func layoutProfileStackView() {
        containerView.addSubview(profileStackView)
        profileStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileStackView.topAnchor.constraint(equalTo: detailFeedImageCollectionView.bottomAnchor, constant: 10),
            profileStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
        ])
    }
    
    private func layoutBattleStackView() {
        containerView.addSubview(battleStackView)
        battleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            battleStackView.topAnchor.constraint(equalTo: profileStackView.bottomAnchor, constant: 10),
            battleStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func layoutTextView() {
        containerView.addSubview(backgroundTextView)
        backgroundTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundTextView.topAnchor.constraint(equalTo: battleStackView.bottomAnchor, constant: 15),
            backgroundTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            backgroundTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            backgroundTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        backgroundTextView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: backgroundTextView.topAnchor, constant: 5),
            textView.leadingAnchor.constraint(equalTo: backgroundTextView.leadingAnchor, constant: 5),
            textView.trailingAnchor.constraint(equalTo: backgroundTextView.trailingAnchor, constant: -5),
            textView.bottomAnchor.constraint(equalTo: backgroundTextView.bottomAnchor, constant: -5)
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        configureDetailFeedImageCollectionView()
        configureProfileStackView()
        configureTextView()
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
        detailFeedImageCollectionView.layer.shadowOffset = CGSize(width: 0, height: 4)
        if let snapshot = snapshot {
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    
    private func configureProfileStackView() {
        profileNameLabel.text = viewModel.feed.uploader.nickname
        profileImageButton.setImage(viewModel.feed.uploader.profileImage, for: .normal)
    }
    
    private func configureTextView() {
        backgroundTextView.backgroundColor = .white
        backgroundTextView.layer.borderWidth = 0.3
        backgroundTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        backgroundTextView.roundCorners(cornerRadius: 15)
        textView.delegate = self
    }
    
    // MARK: - Binding
    private func binding() {
        bindCurrentImageIndex()
        bindEditFeedViewState()
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
    
    private func bindEditFeedViewState() {
        viewModel.editFeedViewStateSubject.sink { [weak self] state in
            guard let strongSelf = self else { return }
            switch state {
            case .startEdit:
                self?.navigationItem.rightBarButtonItem = strongSelf.indicatorBarButton
            case .finish:
                self?.listener?.feedDidEdited(to: strongSelf.viewModel.feed)
                self?.editFeedCoordinator?.popEditFeedView()
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
    
    func makeDetailFeedImageCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Int, URL> {
        let cellRegistration = makeCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: detailFeedImageCollectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                         for: indexPath,
                                                         item: itemIdentifier)
        }
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<DetailFeedImageCollectionViewCell, URL> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            cell.configureDetailImageView(item)
        }
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let bottomContentInset = getBottomContentInset(keyBoardHeight: keyboardFrame.size.height)
        let contentInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: bottomContentInset,
            right: 0.0)
        baseScrollView.contentInset = contentInset
        baseScrollView.scrollIndicatorInsets = contentInset
        baseScrollView.setContentOffset(CGPoint(x: 0, y: bottomContentInset), animated: false)
    }
    
    @objc private func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        baseScrollView.contentInset = contentInset
        baseScrollView.scrollIndicatorInsets = contentInset
    }
    
    private func getBottomContentInset(keyBoardHeight: CGFloat) -> CGFloat {
        let collectionViewHeightAnchor = view.frame.width * viewModel.feed.imageRatio
        return collectionViewHeightAnchor + 200 + keyBoardHeight - baseScrollView.frame.height
    }
    
}

extension EditFeedViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension EditFeedViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        if viewModel.configureDoneBarButtonIsEnabled(with: text) {
            doneBarButton.tintColor = .black
            doneBarButton.isEnabled = true
            viewModel.textViewDidChanged(text)
        } else {
            doneBarButton.tintColor = .lightGray
            doneBarButton.isEnabled = false
        }
    }
}
