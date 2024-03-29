//
//  FeedUploadViewController.swift
//  Petpion
//
//  Created by 김성원 on 2022/11/23.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import Mantis
import PetpionCore


final class FeedUploadViewController: HasCoordinatorViewController {
    
    lazy var feedUploadCoordinator: FeedUploadCoordinator? = {
        self.coordinator as? FeedUploadCoordinator
    }()
    private var viewModel: FeedUploadViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var baseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.delegate = self
        return scrollView
    }()
    private let containerView: UIView = UIView()
    private lazy var imagePreviewCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private lazy var cropViewController: CropViewController = {
        let cropViewController = Mantis.cropViewController(image: UIImage())
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        return cropViewController
    }()
    
    private lazy var imageSlider: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = .systemGray
        pageControl.pageIndicatorTintColor = .systemGray3
        return pageControl
    }()
    private let backgroundTextView: UIView = UIView()
    private let textView: UITextView = UITextView()
    private var collectionViewHeightAnchor: NSLayoutConstraint?
    
    private lazy var loadingAlertController = UIAlertController(title: nil,
                                                                message: "피드를 업로드 중입니다..",
                                                                preferredStyle: .alert)
    
    private let aspectRatioSelectButton: AspectRatioSelectButton = .init(buttonDiameter: 50)
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, UIImage>?
    // MARK: - Initialize
    init(viewModel: FeedUploadViewModelProtocol) {
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
        layoutImagePreviewCollectionView()
        layoutImageSlider()
        layoutAspectRatioSelectButton()
        layoutTextView()
        layoutLoadingAlert()
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
    
    private func layoutImagePreviewCollectionView() {
        containerView.addSubview(imagePreviewCollectionView)
        imagePreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imagePreviewCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imagePreviewCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imagePreviewCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        collectionViewHeightAnchor = imagePreviewCollectionView.heightAnchor.constraint(equalToConstant: self.view.frame.width)
        collectionViewHeightAnchor?.isActive = true
    }
    
    private func layoutImageSlider() {
        containerView.addSubview(imageSlider)
        imageSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageSlider.topAnchor.constraint(equalTo: imagePreviewCollectionView.bottomAnchor, constant: 15),
            imageSlider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageSlider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageSlider.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func layoutAspectRatioSelectButton() {
        containerView.addSubview(aspectRatioSelectButton)
        aspectRatioSelectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aspectRatioSelectButton.topAnchor.constraint(equalTo: imagePreviewCollectionView.bottomAnchor, constant: 10),
            aspectRatioSelectButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            aspectRatioSelectButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        containerView.bringSubviewToFront(aspectRatioSelectButton)
    }
    
    private func layoutTextView() {
        containerView.addSubview(backgroundTextView)
        backgroundTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundTextView.topAnchor.constraint(equalTo: aspectRatioSelectButton.bottomAnchor, constant: 30),
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
    
    private func layoutLoadingAlert() {
        let loadingIndicator = UIActivityIndicatorView()
        loadingAlertController.view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingAlertController.view.centerYAnchor),
            loadingIndicator.leadingAnchor.constraint(equalTo: loadingAlertController.view.leadingAnchor,
                                                      constant: 18)
        ])
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationBar()
        baseScrollView.showsVerticalScrollIndicator = false
        baseScrollView.backgroundColor = .systemBackground
        containerView.backgroundColor = .systemBackground
        imagePreviewCollectionView.backgroundColor = .systemBackground
        imagePreviewCollectionView.alwaysBounceVertical = false
        aspectRatioSelectButton.aspectRatioButtonDelegate = self
        imageSlider.numberOfPages = viewModel.imagesSubject.value.count
        configureTextView()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "새 게시물"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "공유", style: .plain, target: self, action: #selector(uploadButtonDidTapped))
        ]
        navigationController?.navigationBar.tintColor = .black
    }
    
    @objc private func uploadButtonDidTapped() {
        if textView.text == viewModel.textViewPlaceHolder {
            textView.text = ""
        }
        viewModel.uploadNewFeed(message: textView.text)
    }
    
    private func configureTextView() {
        backgroundTextView.backgroundColor = .white
        backgroundTextView.layer.borderWidth = 0.3
        backgroundTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        backgroundTextView.roundCorners(cornerRadius: 15)
        textView.font = .systemFont(ofSize: 15)
        textView.text = viewModel.textViewPlaceHolder
        textView.textColor = .lightGray
        textView.delegate = self
    }
    
    // MARK: - Binding
    private func binding() {
        bindSnapshot()
        bindCellRatio()
        bindCurrentImageIndex()
        bindLoading()
    }
    
    private func bindSnapshot() {
        viewModel.snapshotSubject.sink { [weak self] snapshot in
            guard let ratio = self?.viewModel.cellRatioSubject.value,
                  let collectionViewLayout = self?.viewModel.configureCollectionViewLayout(ratio: ratio) else { return }
            self?.imagePreviewCollectionView.setCollectionViewLayout(collectionViewLayout, animated: false, completion: { isFinished in
                if isFinished {
                    self?.preventIndexReset()
                }
            })
            self?.dataSource = self?.makeImagePreviewCollectionViewDataSource()
            self?.dataSource?.apply(snapshot)
        }.store(in: &cancellables)
    }
    
    func makeImagePreviewCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Int, UIImage> {
        let cellRegistration = makeCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: imagePreviewCollectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                         for: indexPath,
                                                         item: itemIdentifier)
        }
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<ImagePreviewCollectionViewCell, UIImage> {
        UICollectionView.CellRegistration { [weak self] cell, indexPath, item in
            let heightRatio = self?.viewModel.cellRatioSubject.value.heightRatio
            cell.configure(with: item, size: UIScreen.main.bounds.width * (heightRatio ?? 0))
            cell.cellDelegation = self
            cell.clipsToBounds = true
        }
    }

    
    private func bindCellRatio() {
        viewModel.cellRatioSubject.sink { [weak self] ratio in
            guard let ratio = self?.viewModel.cellRatioSubject.value,
                  let collectionViewLayout = self?.viewModel.configureCollectionViewLayout(ratio: ratio) else { return }
            self?.imagePreviewCollectionView.setCollectionViewLayout(collectionViewLayout, animated: false, completion: { isFinished in
                if isFinished {
                    self?.preventIndexReset()
                    self?.animateCollectionView(to: ratio)
                }
            })
            self?.aspectRatioSelectButton.configureButton(ratio)
        }.store(in: &cancellables)
    }
    
    private func preventIndexReset() {
        imagePreviewCollectionView.scrollToItem(at: IndexPath(item: viewModel.currentImageIndexSubject.value, section: 0), at: [], animated: false)
        viewModel.indexWillChange = true
    }
    
    private func bindCurrentImageIndex() {
        viewModel.currentImageIndexSubject.sink { [weak self] current in
            self?.imageSlider.currentPage = current
        }.store(in: &cancellables)
    }
    
    private func bindLoading() {
        viewModel.loadingSubject.sink { [weak self] loading in
            guard let strongSelf = self else { return }
            switch loading {
            case .startUploading:
                self?.present(strongSelf.loadingAlertController, animated: true)
            case .finishUploading:
                self?.postRefreshAction()
                self?.dismiss(animated: true)
                self?.feedUploadCoordinator?.dismissViewController()
            }
        }.store(in: &cancellables)
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
        guard let collectionViewHeightAnchor = collectionViewHeightAnchor else { return 0 }
        return collectionViewHeightAnchor.constant + 200 + keyBoardHeight - baseScrollView.frame.height
    }
    
    // MARK: - Animating
    private func animateCollectionView(to ratio: CellAspectRatio) {
        let cellHeight = self.view.frame.width * ratio.heightRatio
        collectionViewHeightAnchor?.isActive = false
        collectionViewHeightAnchor = imagePreviewCollectionView.heightAnchor.constraint(equalToConstant: cellHeight)
        collectionViewHeightAnchor?.isActive = true
        UICollectionView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) { [weak self] in
            self?.imagePreviewCollectionView.visibleCells.forEach { cell in
                (cell as? ImagePreviewCollectionViewCell)?.changeImageViewSize(to: cellHeight)
            }
            self?.view.layoutIfNeeded()
        }
    }
}

extension FeedUploadViewController: ImagePreviewCollectionViewCellDelegate {
    public func editButtonDidTapped(cell: UICollectionViewCell) {
        let index = viewModel.currentImageIndexSubject.value
        let image = viewModel.imagesSubject.value[index]
        let cellRatio = viewModel.cellRatioSubject.value
        feedUploadCoordinator?.presentCropViewController(from: self, with: image, ratio: cellRatio)
    }
}

extension FeedUploadViewController: CropViewControllerDelegate {
    public func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        viewModel.indexWillChange = false
        viewModel.imageDidCropped(cropped)
        feedUploadCoordinator?.dismissViewController()
    }
    
    public func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        
    }
    
    public func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        feedUploadCoordinator?.dismissViewController()
    }
    
    public func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {
        
    }
    
    public func cropViewControllerDidEndResize(_ cropViewController: Mantis.CropViewController, original: UIImage, cropInfo: Mantis.CropInfo) {
        
    }
    
    public func cropViewControllerDidImageTransformed(_ cropViewController: Mantis.CropViewController) {
        
    }
    
}

extension FeedUploadViewController: AspectRatioButtonDelegate {
    public func aspectRatioButtonDidTapped(tag: Int) {
        viewModel.indexWillChange = false
        viewModel.changeRatio(tag: tag)
    }
}

extension FeedUploadViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension FeedUploadViewController: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == viewModel.textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = viewModel.textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
}
