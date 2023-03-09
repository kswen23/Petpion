//
//  TopFeedCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/28.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

protocol TopFeedCollectionViewCellListener: NSObject {
    func profileStackViewDidTapped(with cell: UICollectionViewCell)
}

final class TopFeedCollectionViewCell: UICollectionViewCell {
    
    weak var topFeedCollectionViewCellListener: TopFeedCollectionViewCellListener?
    
    private let thumbnailImageView: CustomShimmerImageView = CustomShimmerImageView(gradientColorOne: UIColor.petpionLightGray.cgColor, gradientColorTwo: UIColor.white.cgColor)
    
    private let rankingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = false
        return imageView
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        let radius: CGFloat = xValueRatio(15)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: radius*2),
            imageView.widthAnchor.constraint(equalToConstant: radius*2)
        ])
        imageView.image = UIImage(systemName: "person.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .darkGray
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.roundCorners(cornerRadius: radius)
        return imageView
    }()
    
    private lazy var profileNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: xValueRatio(16))
        label.text = "user"
        label.textColor = .black
        return label
    }()
    
    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView()
        [profileImageView, profileNameLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.addGestureRecognizer(profileStackViewTapGesture)
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var profileStackViewTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(profileStackViewDidTapped))
        return tapGesture
    }()
    
    @objc private func profileStackViewDidTapped() {
        topFeedCollectionViewCellListener?.profileStackViewDidTapped(with: self)
    }
    
    private lazy var battleCountLabel: UILabel = makeCountLabel()
    private lazy var winCountLabel: UILabel = makeCountLabel()
    private lazy var winRateCountLabel: UILabel = makeCountLabel()
    
    private lazy var battleStackView: UIStackView = {
        let battleCountView: UIStackView = makeSymbolCountStackView(imageName: "fight", countLabel: battleCountLabel)
        
        let winCountView: UIStackView = makeSymbolCountStackView(imageName: "win", countLabel: winCountLabel)
        
        let winRateCountView: UIStackView = makeSymbolCountStackView(imageName: "winPercent", countLabel: winRateCountLabel)
        let stackView = UIStackView()
        [battleCountView, winCountView, winRateCountView].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = xValueRatio(40)
        stackView.alignment = .bottom
        stackView.isHidden = true
        return stackView
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        rankingImageView.isHidden = true
        battleStackView.isHidden = true
        profileStackView.isHidden = true
    }
    
    // MARK: - Layout
    private func layout() {
        layoutBattleStackView()
        layoutProfileStackView()
        layoutImageView()
        layoutRankingImageView()
    }
    
    private func layoutBattleStackView() {
        self.addSubview(battleStackView)
        NSLayoutConstraint.activate([
            battleStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            battleStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
    }
    
    private func layoutProfileStackView() {
        self.addSubview(profileStackView)
        profileStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileStackView.bottomAnchor.constraint(equalTo: battleStackView.topAnchor, constant: yValueRatio(-10)),
            profileStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: xValueRatio(10))
        ])
    }

    private func layoutImageView() {
        self.addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: self.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: profileStackView.topAnchor, constant: yValueRatio(-10))
        ])
        thumbnailImageView.roundCorners(cornerRadius: 15)
        thumbnailImageView.backgroundColor = .petpionLightGray
        thumbnailImageView.contentMode = .scaleAspectFill
    }
    
    private func layoutRankingImageView() {
        thumbnailImageView.addSubview(rankingImageView)
        rankingImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rankingImageView.widthAnchor.constraint(equalToConstant: xValueRatio(40)),
            rankingImageView.heightAnchor.constraint(equalToConstant: yValueRatio(40)),
            rankingImageView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 10),
            rankingImageView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 10)
        ])
    }
    
    // MARK: - Configure
    func configureCollectionViewCell(_ item: PetpionFeed) {
        configureImageView(item)
        configureRankingImageView(item)
        configureCountStackView(battle: item.battleCount, win: item.likeCount)
        configureProfileStackView(uploader: item.uploader)
    }
    
    private func configureImageView(_ item: PetpionFeed) {
        guard let url = item.imageURLArr?[0] else { return }
        if let cachedImage = ImageCache.shared.image(url: url as NSURL) {
            thumbnailImageView.image = cachedImage
        } else {
            Task {
                let detailImage = await ImageCache.shared.loadImage(url: url as NSURL)
                await MainActor.run {
                    thumbnailImageView.image = detailImage
                }
            }
        }
        
    }
    
    private func configureRankingImageView(_ item: PetpionFeed) {
        guard let ranking = item.ranking else { return }
        rankingImageView.isHidden = false
        switch ranking {
        case 1:
            rankingImageView.image = UIImage(named: Ranking.first.description)
        case 2:
            rankingImageView.image = UIImage(named: Ranking.second.description)
        case 3:
            rankingImageView.image = UIImage(named: Ranking.third.description)
        default:
            break
        }
    }
    
    private func configureProfileStackView(uploader: User) {
        profileNameLabel.text = uploader.nickname
        profileImageView.image = uploader.profileImage
        profileNameLabel.sizeToFit()
        profileStackView.isHidden = false
    }
    
    private func configureCountStackView(battle: Int, win: Int) {
        battleCountLabel.text = String(battle)
        winCountLabel.text = String(win)
        let winRate = (Double(win)/Double(battle)*100).roundDecimal(to: 1)
        winRateCountLabel.text = String(winRate.isNaN ? 0 : winRate)+"%"
        battleStackView.isHidden = false
    }
    
    // MARK: - Make
    private func makeSymbolCountStackView(imageName: String, countLabel: UILabel) -> UIStackView {
        
        let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: imageName)
            return imageView
        }()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: xValueRatio(25)),
            imageView.widthAnchor.constraint(equalToConstant: xValueRatio(25))
        ])
        
        let symbolCountStackView: UIStackView = {
            let stackView = UIStackView()
            [imageView, countLabel].forEach {
                stackView.addArrangedSubview($0)
            }
            stackView.spacing = 7
            stackView.alignment = .center
            return stackView
        }()
        
        return symbolCountStackView
    }
    
    private func makeCountLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: xValueRatio(15))
        label.textColor = .darkGray
        return label
    }
}

extension TopFeedCollectionViewCell {
    
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
