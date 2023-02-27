//
//  UserCardCollectionReusableView.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import UIKit

import PetpionCore
import PetpionDomain

class UserCardCollectionReusableView: UICollectionReusableView {
    
    static let identifier: String = "UserCardCollectionReusableView"
    
    private let userCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .petpionLightGray
        return view
    }()
    
    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .lightGray
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let userNicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "사용자"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    private let firstRankView = RankingView()
    private let secondRankView = RankingView()
    private let thirdRankView = RankingView()
    
    private lazy var userRankingStackView: UIStackView = {
        let stackView = UIStackView()
        [firstRankView, secondRankView, thirdRankView].forEach { stackView.addArrangedSubview($0) }
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        return stackView
    }()

    let cardViewWidth: CGFloat = UIScreen.main.bounds.size.width - 40
    let cardViewHeight: CGFloat = (UIScreen.main.bounds.size.width - 40) * 0.56
    
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
        layoutUserCardView()
        layoutUserProfileImageView()
        layoutUserNicknameLabel()
        layoutUserRankingStackView()
    }
    
    private func layoutUserCardView() {
        self.addSubview(userCardView)
        userCardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userCardView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            userCardView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            userCardView.widthAnchor.constraint(equalToConstant: cardViewWidth),
            userCardView.heightAnchor.constraint(equalToConstant: cardViewHeight)
        ])
        userCardView.roundCorners(cornerRadius: 15)
        userCardView.layer.masksToBounds = false
        userCardView.layer.shadowOffset = CGSize(width: 5, height: 5)
        userCardView.layer.shadowOpacity = 0.7
        userCardView.layer.shadowRadius = 5
        userCardView.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    private func layoutUserProfileImageView() {
        userCardView.addSubview(userProfileImageView)
        userProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        let profileImageViewWidth: CGFloat = cardViewHeight * 0.75
        NSLayoutConstraint.activate([
            userProfileImageView.centerYAnchor.constraint(equalTo: userCardView.centerYAnchor),
            userProfileImageView.leadingAnchor.constraint(equalTo: userCardView.leadingAnchor, constant: 10),
            userProfileImageView.heightAnchor.constraint(equalToConstant: profileImageViewWidth),
            userProfileImageView.widthAnchor.constraint(equalToConstant: profileImageViewWidth)
        ])
        userProfileImageView.roundCorners(cornerRadius: profileImageViewWidth/2)
        userProfileImageView.backgroundColor = .white
        userProfileImageView.bringSubviewToFront(userCardView)
    }
    
    private func layoutUserNicknameLabel() {
        userCardView.addSubview(userNicknameLabel)
        userNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNicknameLabel.centerYAnchor.constraint(equalTo: userCardView.topAnchor, constant: cardViewHeight/4),
            userNicknameLabel.leadingAnchor.constraint(equalTo: userProfileImageView.trailingAnchor, constant: 20),
            userNicknameLabel.trailingAnchor.constraint(equalTo: userCardView.trailingAnchor, constant: -20)
        ])
        userNicknameLabel.bringSubviewToFront(userCardView)
    }
    
    private func layoutUserRankingStackView() {
        userCardView.addSubview(userRankingStackView)
        userRankingStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userRankingStackView.topAnchor.constraint(equalTo: userCardView.centerYAnchor),
            userRankingStackView.leadingAnchor.constraint(equalTo: userProfileImageView.trailingAnchor, constant: 40),
            userRankingStackView.trailingAnchor.constraint(equalTo: userCardView.trailingAnchor, constant: -40),
            userRankingStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
        userRankingStackView.bringSubviewToFront(userCardView)
    }

    func configureUserCardView(with user: User) {
        userProfileImageView.image = user.profileImage
        userNicknameLabel.text = user.nickname
        firstRankView.configureRankingView(ranking: .first, count: user.first)
        secondRankView.configureRankingView(ranking: .second, count: user.second)
        thirdRankView.configureRankingView(ranking: .third, count: user.third)
    }
}
