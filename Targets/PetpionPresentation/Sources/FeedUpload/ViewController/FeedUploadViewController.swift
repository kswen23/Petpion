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


public final class FeedUploadViewController: UIViewController {
    
    weak var coordinator: FeedUploadCoordinator?
    var viewModel: FeedUploadViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    lazy var imagePreviewCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                             collectionViewLayout: UICollectionViewLayout())
    lazy var cropViewController: CropViewController = {
        let cropViewController = Mantis.cropViewController(image: UIImage())
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        return cropViewController
    }()
    
    var collectionViewHeightAnchor: NSLayoutConstraint?
    
    private let aspectRatioSelectButton: AspectRatioSelectButton = .init(buttonDiameter: 50)
    
    // need change
    lazy var datasource = self.makeDataSource()
    
    // MARK: - Initialize
    init(viewModel: FeedUploadViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutImagePreviewCollectionView()
        layoutAspectRatioSelectButton()
    }
    
    private func layoutImagePreviewCollectionView() {
        view.addSubview(imagePreviewCollectionView)
        imagePreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imagePreviewCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imagePreviewCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imagePreviewCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        collectionViewHeightAnchor = imagePreviewCollectionView.heightAnchor.constraint(equalToConstant: self.view.frame.width)
        collectionViewHeightAnchor?.isActive = true
    }
    
    private func layoutAspectRatioSelectButton() {
        view.addSubview(aspectRatioSelectButton)
        aspectRatioSelectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aspectRatioSelectButton.topAnchor.constraint(equalTo: imagePreviewCollectionView.bottomAnchor, constant: 10),
            aspectRatioSelectButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            aspectRatioSelectButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        view.backgroundColor = .systemBackground
        imagePreviewCollectionView.backgroundColor = .systemBackground
        imagePreviewCollectionView.alwaysBounceVertical = false
        aspectRatioSelectButton.aspectRatioButtonDelegate = self
    }
    
    private func configureCollectionViewLayout(ratio: CellAspectRatio) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(1.0*ratio.heightRatio))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
            let index = Int(max(0, round(point.x / environment.container.contentSize.width)))
            self?.viewModel.changeCurrentIndex(index)
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, UIImage> {
        let cellRegistration = makeCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: imagePreviewCollectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                         for: indexPath,
                                                         item: itemIdentifier)
        }
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<ImagePreviewCollectionViewCell, UIImage> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            let heightRatio = self.viewModel.cellRatioSubject.value.heightRatio
            cell.configure(with: item, size: self.view.frame.width * heightRatio)
            cell.cellDelegation = self
        }
    }
    
    // MARK: - Binding
    private func binding() {
        bindSnapshot()
        bindCellRatio()
    }
    
    private func bindSnapshot() {
        viewModel.snapshotSubject.sink { [weak self] snapshot in
            guard let strongSelf = self else { return }
            self?.imagePreviewCollectionView.setCollectionViewLayout(strongSelf.configureCollectionViewLayout(ratio: strongSelf.viewModel.cellRatioSubject.value), animated: false, completion: { isFinished in
                if isFinished {
                    strongSelf.preventIndexReset()
                }
            })
            self?.datasource.apply(snapshot)
        }.store(in: &cancellables)
    }
    
    private func bindCellRatio() {
        viewModel.cellRatioSubject.sink { [weak self] ratio in
            guard let strongSelf = self else { return }
            self?.imagePreviewCollectionView.setCollectionViewLayout(strongSelf.configureCollectionViewLayout(ratio: strongSelf.viewModel.cellRatioSubject.value), animated: false, completion: { isFinished in
                if isFinished {
                    strongSelf.preventIndexReset()
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
    
    // MARK: - Animating
    private func animateCollectionView(to ratio: CellAspectRatio) {
        let cellHeight = self.view.frame.width * ratio.heightRatio
        collectionViewHeightAnchor?.isActive = false
        collectionViewHeightAnchor = imagePreviewCollectionView.heightAnchor.constraint(equalToConstant: cellHeight)
        collectionViewHeightAnchor?.isActive = true
        UICollectionView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.imagePreviewCollectionView.visibleCells.forEach { cell in
                (cell as? ImagePreviewCollectionViewCell)?.changeImageViewSize(to: cellHeight)
            }
        }
    }
    
}


extension FeedUploadViewController: ImagePreviewCollectionViewCellDelegate {
    public func editButtonDidTapped(cell: UICollectionViewCell) {
        let index = viewModel.currentImageIndexSubject.value
        let image = viewModel.imagesSubject.value[index]
        coordinator?.presentCropViewController(from: self, with: image)
    }
}

extension FeedUploadViewController: CropViewControllerDelegate {
    public func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        viewModel.indexWillChange = false
        viewModel.imageDidCropped(cropped)
        coordinator?.dismissCropViewController()
    }
    
    public func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        
    }
    
    public func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        coordinator?.dismissCropViewController()
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
