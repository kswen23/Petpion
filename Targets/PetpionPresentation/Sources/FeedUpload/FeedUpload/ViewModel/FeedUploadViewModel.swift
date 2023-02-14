//
//  FeedUploadViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/23.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionCore
import PetpionDomain

public enum FeedUploadViewState {
    case startUploading
    case finishUploading
}

public enum CellAspectRatio: Int, CaseIterable {
    case square = 1
    case horizontalRectangle = 2
    case verticalRectangle = 3
    
    var heightRatio: Double {
        switch self {
        case .square:
            return 1.0
        case .horizontalRectangle:
            return 3.0/4.0
        case .verticalRectangle:
            return 4.0/3.0
        }
    }
    
    var double: Double {
        switch self {
        case .square:
            return 1.0
        case .horizontalRectangle:
            return 4.0/3.0
        case .verticalRectangle:
            return 3.0/4.0
        }
    }
    
    
    var ratioString: String {
        switch self {
        case .square:
            return "1:1"
        case .horizontalRectangle:
            return "4:3"
        case .verticalRectangle:
            return "3:4"

        }
    }
}

protocol FeedUploadViewModelInput {
    var indexWillChange: Bool { get set }
    func imageDidCropped(_ image: UIImage)
    func uploadNewFeed(message: String)
    func changeRatio(tag: Int)
    func imageSliderValueChanged(_ index: Int)
}

protocol FeedUploadViewModelOutput {
    var textViewPlaceHolder: String { get }
    func configureCollectionViewLayout(ratio: CellAspectRatio) -> UICollectionViewLayout
    }

protocol FeedUploadViewModelProtocol: FeedUploadViewModelInput, FeedUploadViewModelOutput {
    var selectedImages: [UIImage] { get }
    var uploadFeedUseCase: UploadFeedUseCase { get }
    var currentImageIndexSubject: CurrentValueSubject<Int, Never> { get }
    var cellRatioSubject: CurrentValueSubject<CellAspectRatio, Never> { get }
    var imagesSubject: CurrentValueSubject<[UIImage], Never> { get }
    var loadingSubject: PassthroughSubject<FeedUploadViewState, Never> { get }
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<Int, UIImage>,Publishers.Map<PassthroughSubject<[UIImage], Never>,NSDiffableDataSourceSnapshot<Int, UIImage>>.Failure> { get }

}
final class FeedUploadViewModel: FeedUploadViewModelProtocol {

    lazy var imagesSubject: CurrentValueSubject<[UIImage], Never> = .init(selectedImages)
    let currentImageIndexSubject: CurrentValueSubject<Int, Never> = .init(0)
    let cellRatioSubject: CurrentValueSubject<CellAspectRatio, Never> = .init(.square)
    let loadingSubject: PassthroughSubject<FeedUploadViewState, Never> = .init()
    var indexWillChange: Bool = true
    
    lazy var snapshotSubject = imagesSubject.map { items -> NSDiffableDataSourceSnapshot<Int, UIImage> in
        var snapshot = NSDiffableDataSourceSnapshot<Int, UIImage>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        return snapshot
    }.eraseToAnyPublisher()
    
    let textViewPlaceHolder: String = "내 펫을 소개해주세요!"
    let selectedImages: [UIImage]
    let uploadFeedUseCase: UploadFeedUseCase
    
    // MARK: Initialize
    init(selectedImages: [UIImage],
         uploadFeedUseCase: UploadFeedUseCase) {
        self.selectedImages = selectedImages
        self.uploadFeedUseCase = uploadFeedUseCase
    }
    
    deinit {
        print("FeedUploadViewModel deinit")
    }
    
    // MARK: - Input
    func imageDidCropped(_ image: UIImage) {
        var currentImages = imagesSubject.value
        currentImages[currentImageIndexSubject.value] = image
        imagesSubject.send(currentImages)

    }
    
    func uploadNewFeed(message: String) {
        loadingSubject.send(.startUploading)
        let datas = imagesSubject.value.map { convertImageToData(image: $0) }
        guard let uploaderId = UserDefaults.standard.string(forKey: UserInfoKey.firebaseUID) else { return }
        
        let feed: PetpionFeed = PetpionFeed(id: UUID().uuidString,
                                            uploader: User.empty,
                                            uploaderID: uploaderId,
                                            uploadDate: Date.init(),
                                            battleCount: 0,
                                            likeCount: 0,
                                            imageCount: datas.count,
                                            message: message,
                                            feedSize: getFeedSize(imageRatio: cellRatioSubject.value,
                                                                       message: message),
                                            imageRatio: cellRatioSubject.value.heightRatio)
        
        Task {
            let uploadingComplete = await uploadFeedUseCase.uploadNewFeed(feed: feed, imageDatas: datas)            
            if uploadingComplete {
                await MainActor.run {
                    loadingSubject.send(.finishUploading)
                }
            }
        }
    }
    
    private func convertImageToData(image: UIImage) -> Data {
        let targetImageRatio = 600/image.size.width
        let targetHeight = image.size.height*targetImageRatio
        let targetWidth = image.size.width*targetImageRatio
        
        let newSize: CGSize = CGSize(width: targetWidth, height: targetHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage?.jpegData(compressionQuality: 1.0) ?? .init()
    }
    
    func changeRatio(tag: Int) {
        switch tag {
        case CellAspectRatio.square.rawValue:
            cellRatioSubject.send(.square)
        case CellAspectRatio.horizontalRectangle.rawValue:
            cellRatioSubject.send(.horizontalRectangle)
        case CellAspectRatio.verticalRectangle.rawValue:
            cellRatioSubject.send(.verticalRectangle)
        default: break
        }
    }
    
    private func changeCurrentIndex(_ index: Int) {
        if indexWillChange {
            currentImageIndexSubject.send(index)
        }
    }
    
    func imageSliderValueChanged(_ index: Int) {
        currentImageIndexSubject.send(index)
    }
    
    // MARK: - Output
    func configureCollectionViewLayout(ratio: CellAspectRatio) -> UICollectionViewLayout {
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
            self?.changeCurrentIndex(index)
        }
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    // MARK: - Private
    private func getFeedSize(imageRatio: CellAspectRatio, message: String) -> CGSize {
        var height = imageRatio.heightRatio*12 + 4
        if message.count > 15 {
            height += 2
        } else if message.count > 0 {
            height += 1
        }
        return CGSize(width: 12, height: height)
    }
}
