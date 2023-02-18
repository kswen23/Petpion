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

protocol PetFeedCollectionViewCellListener: NSObject {
    func profileStackViewDidTapped(with cell: UICollectionViewCell)
}

final class PetFeedCollectionViewCell: UICollectionViewCell {
    
    weak var listener: PetFeedCollectionViewCellListener?
    
    let baseView: UIView = UIView()
    let thumbnailImageView: CustomShimmerImageView = {
        let imageView = CustomShimmerImageView(gradientColorOne: UIColor.petpionLightGray.cgColor, gradientColorTwo: UIColor.white.cgColor)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let imageCountButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.tintColor = .white
        return button
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        let radius: CGFloat = 13
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: radius*2),
            imageView.widthAnchor.constraint(equalToConstant: radius*2)
        ])
        imageView.image = UIImage(systemName: "person.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .petpionLightGray
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.roundCorners(cornerRadius: radius)
        return imageView
    }()
    
    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView()
        [profileImageView, profileNameLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.addGestureRecognizer(profileStackViewTapGesture)
        return stackView
    }()
    
    private lazy var profileStackViewTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(profileStackViewDidTapped))
        return tapGesture
    }()
    
    @objc private func profileStackViewDidTapped() {
        listener?.profileStackViewDidTapped(with: self)
    }
    
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
    override func prepareForReuse() {
        super.prepareForReuse()
        heightLayoutAnchor?.isActive = false
        thumbnailImageView.image = nil
        thumbnailImageView.stopShimmerAnimating()
        profileImageView.image = nil
        imageCountButton.isHidden = true
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
        thumbnailImageView.startShimmerAnimating()
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
        imageCountButton.isHidden = true
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
        configureThumbnailImageView(viewModel.thumbnailImageURL)
//        configureImage(viewModel)
        profileImageView.image = viewModel.profileImage
        profileNameLabel.text = viewModel.userNickname
        commentLabel.text = viewModel.comment
        likeCountLabel.text = String(viewModel.likeCount)
    }
    
    func configureThumbnailImageView(_ url: URL?) {
        Task {
            guard let url = url else { return }
            let thumbnailImage = await ImageCache.shared.loadImage(url: url as NSURL)
            await MainActor.run {
                thumbnailImageView.stopShimmerAnimating()
                thumbnailImageView.image = thumbnailImage
            }
        }
    }
//    func configureThumbnailImageView(_ url: URL?) {
//        guard let url = url else {
//            thumbnailImageView.stopShimmerAnimating()
//            thumbnailImageView.image = nil
//            return
//        }
//
//        // URL을 통해 이미지 다운로드
//        let task = Task {
//
//            await MainActor.run {
//                guard let data = try? Data(contentsOf: url),
//                      let image = UIImage(data: data) else {
//                    return
//                }
//                apply(image: image, to: thumbnailImageView)
//            }
//        }
//
//        // 이미지 로드 도중 셀이 재사용될 경우에 대비하여 취소 처리
////        thumbnailImageView.taskIdentifier = task.id
//    }
    
    func apply(image: UIImage, to thumbnailImageView: UIImageView) {
        let fadeDuration = 0.2
        let animator = UIViewPropertyAnimator(duration: fadeDuration, curve: .linear) {
            thumbnailImageView.alpha = 0.0
        }
        animator.addCompletion { _ in
            thumbnailImageView.image = image
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: fadeDuration, delay: 0, options: .curveLinear) {
                thumbnailImageView.alpha = 1.0
            }
        }
        animator.startAnimation()
    }

    
    private func configureCellHeight(_ thumbnailRatio: Double) {
        heightLayoutAnchor = thumbnailImageView.heightAnchor.constraint(equalToConstant: self.frame.width*thumbnailRatio)
        heightLayoutAnchor?.isActive = true
    }
        
    private func configureImageCountButtonTitle(with imageCount: Int) {
        if imageCount <= 1 {
            imageCountButton.isHidden = true
        } else {
            imageCountButton.isHidden = false
            imageCountButton.setTitle("+\(imageCount)", for: .normal)
        }
    }
    
}

extension PetFeedCollectionViewCell {
    
    struct ViewModel {
        
        let thumbnailImageURL: URL?
        let profileImage: UIImage
        let thumbnailRatio: Double
        let imageCount: Int
        let userNickname: String
        let comment: String
        let likeCount: Int
        
        var image: UIImage?

        init(petpionFeed: PetpionFeed) {
            self.thumbnailImageURL = petpionFeed.imageURLArr?[0]
            self.profileImage = petpionFeed.uploader.profileImage!
            self.thumbnailRatio = petpionFeed.imageRatio
            self.imageCount = petpionFeed.imageCount
            self.userNickname = petpionFeed.uploader.nickname
            self.comment = petpionFeed.message
            self.likeCount = petpionFeed.likeCount
            
            self.image = petpionFeed.image
        }
    }
}

extension PetFeedCollectionViewCell {
    
    // when Cell did tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        bounceAnimate(isTouched: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        bounceAnimate(isTouched: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
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
