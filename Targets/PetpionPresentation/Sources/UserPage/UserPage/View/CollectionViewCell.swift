//
//  UserFeedsCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import UIKit

import PetpionDomain
import PetpionCore

class UserFeedsCollectionViewCell: UICollectionViewCell {
    
    private let thumbnailImageView: UIImageView = .init()
    private let multipleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "rectangle.fill.on.rectangle.fill")
        imageView.tintColor = .white
        return imageView
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutThumbnailImageView()
        layoutMultipleImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        multipleImageView.isHidden = true
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
        thumbnailImageView.contentMode = .scaleAspectFill
    }
    
    private func layoutMultipleImageView() {
        thumbnailImageView.addSubview(multipleImageView)
        multipleImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            multipleImageView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 7),
            multipleImageView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -7),
            multipleImageView.heightAnchor.constraint(equalToConstant: 20),
            multipleImageView.widthAnchor.constraint(equalToConstant: 20)
        ])
        multipleImageView.isHidden = true
    }

    // MARK: - Configure
    func configureCell(with feed: PetpionFeed) {
        configureThumbnailImageView(feed)
        configureMultipleImageView(feed)
    }
    
    private func configureThumbnailImageView(_ feed: PetpionFeed) {
        Task {
            guard let url = feed.imageURLArr?[0] else { return }
            let thumbnailImage = await ImageCache.shared.loadImage(url: url as NSURL)
            await MainActor.run {
                thumbnailImageView.image = thumbnailImage
            }
        }

    }
    
    private  func configureMultipleImageView(_ feed: PetpionFeed) {
        if feed.imageCount < 2 {
            multipleImageView.isHidden = true
        } else {
            multipleImageView.isHidden = false
        }
    }
}
