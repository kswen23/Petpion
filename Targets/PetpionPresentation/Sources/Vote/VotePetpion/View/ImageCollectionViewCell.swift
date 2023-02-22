//
//  ImageCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/27.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

class ImageCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = .init()
    
    // MARK: - Cell LifeCycle
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        layoutImageView()
    }
    
    private func layoutImageView() {
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        imageView.contentMode = .scaleAspectFill
    }
    
    func configureImageView(with url: URL) {
        Task {
            let imageResult = await ImageCache.shared.loadImage(url: url as NSURL)
            await MainActor.run {
                imageView.image = imageResult
            }
        }
    }
}
