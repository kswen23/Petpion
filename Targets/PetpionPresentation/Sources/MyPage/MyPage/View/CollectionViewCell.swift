//
//  UserFeedsCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import UIKit

import PetpionCore

class UserFeedsCollectionViewCell: UICollectionViewCell {
    
    private let thumbnailImageView: UIImageView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutThumbnailImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
    
    // MARK: - Layout
    private func layoutThumbnailImageView() {
        self.addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: self.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        thumbnailImageView.backgroundColor = .systemGray5
    }
    
    func configureThumbnailImageView(_ url: URL) {
        Task {
            let detailImage = await ImageCache.shared.loadImage(url: url as NSURL)
            await MainActor.run {
                thumbnailImageView.image = detailImage
            }
        }
    }
}
