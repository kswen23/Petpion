//
//  RankingView.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

enum Ranking {
    case first
    case second
    case third
    
    var description: String {
        switch self {
        case .first:
            return "firstRank"
        case .second:
            return "secondRank"
        case .third:
            return "thirdRank"
        }
    }
}

class RankingView: UIView {
    
    private let rankingImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let rankingCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.sizeToFit()
        label.textColor = .darkGray
        return label
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutRankingImageView()
        layoutRankingCountLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutRankingImageView() {
        addSubview(rankingImageView)
        rankingImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rankingImageView.topAnchor.constraint(equalTo: self.topAnchor),
            rankingImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            rankingImageView.widthAnchor.constraint(equalToConstant: 40),
            rankingImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func layoutRankingCountLabel() {
        addSubview(rankingCountLabel)
        rankingCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rankingCountLabel.topAnchor.constraint(equalTo: rankingImageView.bottomAnchor, constant: 5),
            rankingCountLabel.centerXAnchor.constraint(equalTo: rankingImageView.centerXAnchor)
        ])
    }
    
    func configureRankingView(ranking: Ranking, count: Int) {
        rankingImageView.image = UIImage(named: ranking.description)
        rankingCountLabel.text = "\(count)"
        rankingCountLabel.sizeToFit()
    }
}
