//
//  PetpionHallHeaderView.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/28.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

protocol PetpionHallHeaderViewListener: NSObject {
    
    func totalButtonDidTapped(_ section: Int)
}

class PetpionHallHeaderView: UITableViewHeaderFooterView {
    
    static let identifer = "PetpionHallHeaderView"
    
    weak var petpionHallHeaderViewListener: PetpionHallHeaderViewListener?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var totalButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("전체 보기", for: .normal)
        button.setTitleColor(.petpionOrange, for: .normal)
        button.titleLabel!.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(totalButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func totalButtonDidTapped() {
        petpionHallHeaderViewListener?.totalButtonDidTapped(totalButton.tag)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        layoutTitleLabel()
        layoutTotalButton()
    }
    
    private func layoutTitleLabel() {
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
        ])
    }
    
    private func layoutTotalButton() {
        contentView.addSubview(totalButton)
        NSLayoutConstraint.activate([
            totalButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            totalButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    // MARK: - Congfigure
    func configureHeaderView(date: Date, section: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        titleLabel.text = dateFormatter.string(from: date)
        titleLabel.sizeToFit()
        totalButton.tag = section
    }
}
