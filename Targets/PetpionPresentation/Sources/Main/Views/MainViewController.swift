//
//  MainViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

import PetpionCore
import YPImagePicker

final class MainViewController: UIViewController {
    
    weak var coordinator: MainCoordinator?
    let viewModel: MainViewModelProtocol
    
    lazy var petCollectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: UICollectionViewLayout())
    lazy var imagePicker: YPImagePicker = {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.showsPhotoFilters = false
        config.library.maxNumberOfItems = 5
        config.library.mediaType = YPlibraryMediaType.photo
        let pickerViewController = YPImagePicker(configuration: config)
        return pickerViewController
    }()
    
    private lazy var dataSource = makeDataSource()
    let indexArray = Array(0..<50)
    lazy var data = indexArray.map(WaterfallItem.init)
    let defaultColumnCount = 2
    let defaultSpacing = CGFloat(5)
    let defaultContentInsetsReference = UIContentInsetsReference.automatic
    
    // MARK: - Initialize
    init(mainViewModel: MainViewModelProtocol) {
        self.viewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        layoutPetCollectionView()
        configure()
        initializeData()
    }
    
    private func layoutPetCollectionView() {
        view.addSubview(petCollectionView)
        petCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            petCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            petCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            petCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            petCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        petCollectionView.backgroundColor = .white
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationItem()
        configurePetCollectionView()
        configureImagePicker()
    }
    
    private func configureNavigationItem() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "camera"), style: .done, target: self, action: #selector(cameraButtonDidTap))
        ]
        navigationController?.navigationBar.tintColor = .black
    }
    
    @objc func cameraButtonDidTap() {
        self.present(imagePicker, animated: true)
    }
    
    private func configurePetCollectionView() {
        let waterfallLayout = UICollectionViewCompositionalLayout.makeWaterfallLayout(configuration: makeWaterfallLayoutConfiguration())
        petCollectionView.setCollectionViewLayout(waterfallLayout, animated: true)
    }
    
    private func configureImagePicker() {
        imagePicker.didFinishPicking { [unowned self] items, cancelled in
            var images: [UIImage] = []
            for item in items {
                switch item {
                case .photo(let photo):
                    images.append(photo.image)
                case .video:
                    break
                }
            }
            self.viewModel.uploadNewFeed(images: images, message: "newFeed!")
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
    private func initializeData() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, WaterfallItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(data, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    private func makeWaterfallLayoutConfiguration() -> UICollectionLayoutWaterfallConfiguration {
        return UICollectionLayoutWaterfallConfiguration(
            columnCount: defaultColumnCount,
            spacing: defaultSpacing,
            contentInsetsReference: defaultContentInsetsReference) { [self] indexPath in
                data[indexPath.row].size
            }
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, WaterfallItem> {
        let registration = makeCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: petCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<PetCollectionViewCell, WaterfallItem> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            let viewModel = self.makeViewModel(for: item)
            cell.configure(with: viewModel)
        }
    }
    
    func makeViewModel(for item: WaterfallItem) -> PetCollectionViewCell.ViewModel {
        return PetCollectionViewCell.ViewModel(item: item)
    }

}
struct WaterfallItem {
    
    let index: Int
    
    let size = CGSize(width: 140, height: 50 + .random(in: 0...100))
    
    let color = UIColor.blue
}
extension WaterfallItem: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
}
