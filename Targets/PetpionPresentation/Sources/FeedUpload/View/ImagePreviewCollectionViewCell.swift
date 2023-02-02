//
//  ImagePreviewCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/23.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore

public protocol ImagePreviewCollectionViewCellDelegate: AnyObject {
    func editButtonDidTapped(cell: UICollectionViewCell)
}

public final class ImagePreviewCollectionViewCell: UICollectionViewCell {
    
    weak var cellDelegation: ImagePreviewCollectionViewCellDelegate?
    private let imagePreview: UIImageView = UIImageView()
    private let editImageButton: CircleButton = {
        let button = CircleButton(diameter: 40)
        button.setImage(UIImage(systemName: "crop.rotate"), for: .normal)
        button.backgroundColor = .gray
        button.tintColor = .white
        button.alpha = 0.9
        return button
    }()
    
    private var imagePreviewHeight: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        layoutImagePreview()
        layoutEditImageButton()
    }
    
    private func layoutImagePreview() {
        self.addSubview(imagePreview)
        imagePreview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imagePreview.topAnchor.constraint(equalTo: self.topAnchor),
            imagePreview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imagePreview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        imagePreviewHeight = imagePreview.heightAnchor.constraint(equalToConstant: self.frame.width)
        imagePreviewHeight?.isActive = true
        imagePreview.contentMode = .scaleAspectFill
    }
    
    private func layoutEditImageButton() {
        contentView.addSubview(editImageButton)
        editImageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editImageButton.bottomAnchor.constraint(equalTo: imagePreview.bottomAnchor, constant: -20),
            editImageButton.trailingAnchor.constraint(equalTo: imagePreview.trailingAnchor, constant: -20),
        ])
        editImageButton.addTarget(self, action: #selector(editButtonDidTapped), for: .touchUpInside)
    }
    
    @objc private func editButtonDidTapped() {
        cellDelegation?.editButtonDidTapped(cell: self)
    }
    
    // MARK: - Configure
    func configure(with image: UIImage, size: CGFloat) {
        imagePreview.image = image
        imagePreviewHeight?.isActive = false
        imagePreviewHeight = imagePreview.heightAnchor.constraint(equalToConstant: size)
        imagePreviewHeight?.isActive = true
    }
    
    func changeImageViewSize(to height: CGFloat) {
        imagePreviewHeight?.isActive = false
        imagePreviewHeight = imagePreview.heightAnchor.constraint(equalToConstant: height)
        imagePreviewHeight?.isActive = true
        UICollectionView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
        
    }
}
