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

import PetpionDomain

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
    func imagesDidPicked(_ images: [UIImage])
    func imageDidCropped(_ image: UIImage)
    func uploadNewFeed(images: [UIImage], message: String?)
    func changeRatio(tag: Int)
    func changeCurrentIndex(_ index: Int)
    
}
protocol FeedUploadViewModelOutput {
    var currentImageIndexSubject: CurrentValueSubject<Int, Never> { get }
    var cellRatioSubject: CurrentValueSubject<CellAspectRatio, Never> { get }
    var imagesSubject: CurrentValueSubject<[UIImage], Never> { get }
    var snapshotSubject: AnyPublisher<NSDiffableDataSourceSnapshot<Int, UIImage>, Publishers.Map<PassthroughSubject<[UIImage], Never>, NSDiffableDataSourceSnapshot<Int, UIImage>>.Failure> { get }
}
protocol FeedUploadViewModelProtocol: FeedUploadViewModelInput, FeedUploadViewModelOutput {
    var uploadFeedUseCase: UploadFeedUseCase { get }
}
public final class FeedUploadViewModel: FeedUploadViewModelProtocol {

    let imagesSubject: CurrentValueSubject<[UIImage], Never> = .init([])
    let currentImageIndexSubject: CurrentValueSubject<Int, Never> = .init(0)
    let cellRatioSubject: CurrentValueSubject<CellAspectRatio, Never> = .init(.square)
    var indexWillChange: Bool = true
    
    lazy var snapshotSubject = imagesSubject.map { items -> NSDiffableDataSourceSnapshot<Int, UIImage> in
        var snapshot = NSDiffableDataSourceSnapshot<Int, UIImage>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        return snapshot
    }.eraseToAnyPublisher()
    
    let uploadFeedUseCase: UploadFeedUseCase
    
    init(uploadFeedUseCase: UploadFeedUseCase) {
        self.uploadFeedUseCase = uploadFeedUseCase
    }
    
    // MARK: - Input
    func imagesDidPicked(_ images: [UIImage]) {
        imagesSubject.send(images)
    }
    
    func imageDidCropped(_ image: UIImage) {
        var currentImages = imagesSubject.value
        currentImages[currentImageIndexSubject.value] = image
        imagesSubject.send(currentImages)

    }
    
    func uploadNewFeed(images: [UIImage], message: String?) {
        let datas: [Data] = images.map{ $0.jpegData(compressionQuality: 0.8) ?? Data() }
        
        let feed: PetpionFeed = PetpionFeed(id: UUID().uuidString,
                                            uploaderID: UUID().uuidString,
                                            uploadDate: Date.init(),
                                            likeCount: 10,
                                            imageCount: datas.count,
                                            message: message ?? "")
        uploadFeedUseCase.uploadNewFeed(feed: feed, imageDatas: datas)
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
    
    func changeCurrentIndex(_ index: Int) {
        if indexWillChange {
            currentImageIndexSubject.send(index)
        }
    }
    // MARK: - Output
    
}
