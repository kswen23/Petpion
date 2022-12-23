//
//  VotingListCollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/22.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

class VotingListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("abc")
        layout()
        let view = UIView()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.widthAnchor.constraint(equalToConstant: 50),
            view.heightAnchor.constraint(equalToConstant: 50),
        ])
        view.backgroundColor = .cyan
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        
    }
    
    // MARK: - Configure
    private func configure() {
        
    }
    
}
