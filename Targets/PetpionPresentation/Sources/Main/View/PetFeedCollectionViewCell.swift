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

public final class PetFeedCollectionViewCell: UICollectionViewCell {
    
    let baseView: UIView = UIView()
    
    lazy var thumbnailImageView: UIImageView  = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    let imageCountButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.tintColor = .white
        return button
    }()
    
    private let profileImageButton: CircleButton = {
        let circleImageButton = CircleButton(diameter: 25)
        circleImageButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
        circleImageButton.contentMode = .scaleAspectFill
        circleImageButton.tintColor = .petpionLightGray
        circleImageButton.backgroundColor = .white
        circleImageButton.layer.borderWidth = 0.5
        circleImageButton.layer.borderColor = UIColor.lightGray.cgColor
        return circleImageButton
    }()
    
    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
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
    
    private let winImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "win")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        return imageView
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var likeCountStackView: UIStackView = {
        let stackView = UIStackView()
        [winImageView, likeCountLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.spacing = 3
        stackView.alignment = .bottom
        return stackView
    }()
    
    private var heightLayoutAnchor: NSLayoutConstraint?
    
    // MARK: - Cell LifeCycle
    public override func prepareForReuse() {
        super.prepareForReuse()
        heightLayoutAnchor?.isActive = false
        thumbnailImageView.image = nil
        profileImageButton.imageView?.image = nil
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
        layoutBaseView()
        layoutThumbnailImageView()
        layoutImageCountButton()
        layoutProfileStackView()
        layoutCommentLabel()
        layoutLikeCountStackView()
    }
    
    private func layoutBaseView() {
        self.addSubview(baseView)
        baseView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            baseView.topAnchor.constraint(equalTo: self.topAnchor),
            baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func layoutThumbnailImageView() {
        baseView.addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: baseView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
        ])
        thumbnailImageView.roundCorners(cornerRadius: 10)
    }
    
    private func layoutImageCountButton() {
        thumbnailImageView.addSubview(imageCountButton)
        imageCountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageCountButton.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 7),
            imageCountButton.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -7),
            imageCountButton.heightAnchor.constraint(equalToConstant: 20),
            imageCountButton.widthAnchor.constraint(equalToConstant: 25)
        ])
        imageCountButton.roundCorners(cornerRadius: 10)
        imageCountButton.titleLabel?.font = .systemFont(ofSize: 14)
    }
    
    private func layoutProfileStackView() {
        baseView.addSubview(profileStackView)
        profileStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileStackView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 5),
            profileStackView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 5)
        ])
    }
    
    private func layoutCommentLabel() {
        baseView.addSubview(commentLabel)
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentLabel.topAnchor.constraint(equalTo: profileStackView.bottomAnchor, constant: 5),
            commentLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 5),
            commentLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -5)
        ])
        commentLabel.numberOfLines = 2
    }
    
    private func layoutLikeCountStackView() {
        baseView.addSubview(likeCountStackView)
        likeCountStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likeCountStackView.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 5),
            likeCountStackView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 5)
        ])
    }
    
    // MARK: - Configure
    func configure(with viewModel: ViewModel) {
        configureCellHeight(viewModel.thumbnailRatio)
        configureImageCountButtonTitle(with: viewModel.imageCount)
        thumbnailImageView.image = viewModel.thumbnailImage
        profileImageButton.setImage(viewModel.profileImage, for: .normal)
        profileNameLabel.text = viewModel.userNickname
        commentLabel.text = viewModel.comment
        likeCountLabel.text = String(viewModel.likeCount)
    }
    
    private func configureCellHeight(_ thumbnailRatio: Double) {
        heightLayoutAnchor = thumbnailImageView.heightAnchor.constraint(equalToConstant: self.frame.width*thumbnailRatio)
        heightLayoutAnchor?.isActive = true
        
    }
        
    private func configureImageCountButtonTitle(with imageCount: Int) {
        guard imageCount > 1 else {
            return imageCountButton.isHidden = true
        }
        imageCountButton.setTitle("+\(imageCount)", for: .normal)
    }
    
}

extension PetFeedCollectionViewCell {
    
    struct ViewModel {
        
        let thumbnailImage: UIImage
        let profileImage: UIImage
        let thumbnailRatio: Double
        let imageCount: Int
        let userNickname: String
        let comment: String
        let likeCount: Int
        
        init(petpionFeed: PetpionFeed) {
            self.thumbnailImage = petpionFeed.thumbnailImage!
            self.profileImage = petpionFeed.uploader.profileImage!
            self.thumbnailRatio = petpionFeed.imageRatio
            self.imageCount = petpionFeed.imageCount
            self.userNickname = petpionFeed.uploader.nickname
            self.comment = petpionFeed.message
            self.likeCount = petpionFeed.likeCount
        }
    }
}

extension PetFeedCollectionViewCell {
    
    // when Cell did tapped
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        bounceAnimate(isTouched: true)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        bounceAnimate(isTouched: false)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        bounceAnimate(isTouched: false)
    }
    
    private func bounceAnimate(isTouched: Bool) {
        
        if isTouched {
            PetFeedCollectionViewCell.animate(withDuration: 0.5,
                                              delay: 0,
                                              usingSpringWithDamping: 1,
                                              initialSpringVelocity: 1,
                                              options: [.allowUserInteraction], animations: {
                self.transform = .init(scaleX: 0.95, y: 0.95)
                self.layoutIfNeeded()
            }, completion: nil)
        } else {
            PetFeedCollectionViewCell.animate(withDuration: 0.5,
                                              delay: 0,
                                              usingSpringWithDamping: 1,
                                              initialSpringVelocity: 0,
                                              options: .allowUserInteraction, animations: {
                self.transform = .identity
            }, completion: nil)
        }
    }
}
