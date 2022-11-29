//
//  CollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/11.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

import PetpionDomain

class PetCollectionViewCell: UICollectionViewCell {
    
    private let thumbnailImageView: UIImageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        self.backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        layoutImagePreview()
    }
    
    private func layoutImagePreview() {
        self.addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: self.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.backgroundColor = .lightGray
    }
    // MARK: - Configure
    func configure(with viewModel: ViewModel) {
        thumbnailImageView.heightAnchor.constraint(equalToConstant: self.frame.width*viewModel.thumbnailRatio).isActive = true
        
        downloadImage(with: viewModel.thumbnail) { [weak self] image in
            DispatchQueue.main.async {
                self?.thumbnailImageView.image = image
            }
        }
    }
    
    private func downloadImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(image)
            }
        }
        task.resume()
    }
}

extension PetCollectionViewCell {
    
    struct ViewModel {
        
        let thumbnail: URL
        let thumbnailRatio: Double
        let imageCount: Int
        let userProfile: UIImage
        let userNickname: String
        let comment: String
        let likeCount: Int
        
        init(petpionFeed: PetpionFeed) {
            self.thumbnail = petpionFeed.imageURLArr![0]
            self.thumbnailRatio = petpionFeed.imageRatio
            self.imageCount = petpionFeed.imagesCount
            self.userProfile = UIImage()
            self.userNickname = "TempUser"
            self.comment = petpionFeed.message
            self.likeCount = petpionFeed.likeCount
        }
    }
    
}
