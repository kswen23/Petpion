//
//  DetailFeedImageCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/13.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore

public final class DetailFeedImageCollectionViewCell: UICollectionViewCell {
    private let imageView: CustomShimmerImageView = CustomShimmerImageView(gradientColorOne: UIColor.petpionLightGray.cgColor, gradientColorTwo: UIColor.white.cgColor)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        imageView.startShimmerAnimating()
    }
    
    // MARK: - Layout
    private func layoutImageView() {
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        imageView.startShimmerAnimating()
        imageView.roundCorners(cornerRadius: 10)
        imageView.contentMode = .scaleAspectFill
    }
    
    func configureDetailImageView(_ url: URL) {
        Task {
            let detailImage = await ImageCache.shared.loadImage(url: url as NSURL)
            await MainActor.run {
                imageView.stopShimmerAnimating()
                imageView.image = detailImage
            }
        }
    }
}
