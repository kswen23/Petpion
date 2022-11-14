//
//  CollectionViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/11.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

class PetCollectionViewCell: UICollectionViewCell {
    
    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: ViewModel) {
        indexLabel.text = viewModel.indexLabelText
        contentView.backgroundColor = viewModel.contentViewBackgroundColor
    }
    
    private func setUp() {
        contentView.addSubview(indexLabel)
        NSLayoutConstraint.activate([
            indexLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            indexLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

}

extension PetCollectionViewCell {
    
    struct ViewModel {
        
        let indexLabelText: String
        
        let contentViewBackgroundColor: UIColor
        
        init(item: WaterfallItem) {
            indexLabelText = "\(item.index + 1)"
            contentViewBackgroundColor = item.color
        }
    }
}
