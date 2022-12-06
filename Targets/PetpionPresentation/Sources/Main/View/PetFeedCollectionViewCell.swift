//
//  PetFeedCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/11.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

import PetpionCore
import PetpionDomain

class PetFeedCollectionViewCell: UICollectionViewCell {
    
    private let thumbnailImageView: UIImageView = UIImageView()
    private let imageCountButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.tintColor = .white
        return button
    }()
    
    private let profileImageButton: CircleButton = {
        let circleImageButton = CircleButton(diameter: 25)
        circleImageButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
        circleImageButton.tintColor = .darkGray
        circleImageButton.backgroundColor = .white
        return circleImageButton
    }()
    
    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView()
        [profileImageButton, profileNameLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.spacing = 3
        stackView.alignment = .center
        return stackView
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private let thumbUpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "hand.thumbsup.fill")
        imageView.tintColor = .black
        return imageView
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var likeCountStackView: UIStackView = {
        let stackView = UIStackView()
        [thumbUpImageView, likeCountLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.spacing = 3
        stackView.alignment = .bottom
        return stackView
    }()
    
    private var heightLayoutAnchor: NSLayoutConstraint?

    // MARK: - Cell LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
        heightLayoutAnchor?.isActive = false
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
        layoutImagePreview()
        layoutImageCountButton()
        layoutProfileStackView()
        layoutCommentLabel()
        layoutLikeCountStackView()
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
        thumbnailImageView.roundCorners(cornerRadius: 10)
        thumbnailImageView.backgroundColor = .lightGray
    }
    
    private func layoutImageCountButton() {
        thumbnailImageView.addSubview(imageCountButton)
        imageCountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageCountButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 7),
            imageCountButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -7),
            imageCountButton.heightAnchor.constraint(equalToConstant: 20),
            imageCountButton.widthAnchor.constraint(equalToConstant: 25)
        ])
        imageCountButton.roundCorners(cornerRadius: 10)
        imageCountButton.titleLabel?.font = .systemFont(ofSize: 14)
    }
    
    private func layoutProfileStackView() {
        self.addSubview(profileStackView)
        profileStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileStackView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 5),
            profileStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5)
        ])
    }
    
    private func layoutCommentLabel() {
        self.addSubview(commentLabel)
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentLabel.topAnchor.constraint(equalTo: profileStackView.bottomAnchor, constant: 5),
            commentLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            commentLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
        ])
        commentLabel.numberOfLines = 2
    }
    
    private func layoutLikeCountStackView() {
        self.addSubview(likeCountStackView)
        likeCountStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likeCountStackView.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 5),
            likeCountStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5)
        ])
    }
    // MARK: - Configure
    func configure(with viewModel: ViewModel) {
        configureCellHeight(viewModel.thumbnailRatio)
        configureThumbnailImageView(viewModel.thumbnailImageURL)
        configureImageCountButtonTitle(with: viewModel.imageCount)
        profileNameLabel.text = viewModel.userNickname
        commentLabel.text = viewModel.comment
        likeCountLabel.text = String(viewModel.likeCount)
    }
    
    private func configureCellHeight(_ thumbnailRatio: Double) {
        heightLayoutAnchor = thumbnailImageView.heightAnchor.constraint(equalToConstant: self.frame.width*thumbnailRatio)
        heightLayoutAnchor?.isActive = true

    }
    
    private func configureThumbnailImageView(_ url: URL) {
        Task {
            let thumbnailImage = await ImageCache.shared.loadImage(url: url as NSURL)
            await MainActor.run {
                thumbnailImageView.image = thumbnailImage
            }
        }
    }
    
    private func configureImageCountButtonTitle(with imageCount: Int) {
        let buttonTitle = imageCount - 1
        guard buttonTitle > 0 else {
            return imageCountButton.isHidden = true
        }
        imageCountButton.setTitle("+\(buttonTitle)", for: .normal)
    }
    
}

extension PetFeedCollectionViewCell {
    
    struct ViewModel {
        
        let thumbnailImageURL: URL
        let thumbnailRatio: Double
        let imageCount: Int
        let userProfile: UIImage
        let userNickname: String
        let comment: String
        let likeCount: Int
        
        init(petpionFeed: PetpionFeed) {
            self.thumbnailImageURL = petpionFeed.imageURLArr![0]
            self.thumbnailRatio = petpionFeed.imageRatio
            self.imageCount = petpionFeed.imagesCount
            self.userProfile = UIImage()
            self.userNickname = "TempUser"
            self.comment = petpionFeed.message
            self.likeCount = petpionFeed.likeCount
        }
    }
    
}
