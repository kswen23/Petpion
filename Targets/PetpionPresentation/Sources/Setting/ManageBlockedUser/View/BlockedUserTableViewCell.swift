//
//  BlockedUserTableViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/21.
//  Copyright © 2023 Petpion. All rights reserved.
//

import UIKit

import PetpionDomain

protocol BlockedUserTableViewCellListener: NSObject {
    func unblockUser(_ cell: BlockedUserTableViewCell)
}

final class BlockedUserTableViewCell: UITableViewCell {
    
    static let identifier = "BlocekdUserTableViewCell"
    
    weak var blockedUserTableViewCellListener: BlockedUserTableViewCellListener?
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.fill")
        imageView.backgroundColor = .petpionLightGray
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.systemGray2.cgColor
        imageView.layer.borderWidth = 0.2
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var unblockButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("차단 해제", for: .normal)
        button.setTitleColor(.petpionOrange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.addTarget(self, action: #selector(unblockButtonDidTapped), for: .touchUpInside)
        button.sizeToFit()
        return button
    }()
    
    @objc private func unblockButtonDidTapped() {
        blockedUserTableViewCellListener?.unblockUser(self)
    }
    
    // MARK: - Initialize
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        layout()
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        [profileImageView, nicknameLabel].forEach { self.addSubview($0) }
        contentView.addSubview(unblockButton)
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            nicknameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            unblockButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            unblockButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        profileImageView.roundCorners(cornerRadius: 25)
    }
    
    // MARK: - Configure
    func configureCell(with item: User) {
        profileImageView.image = item.profileImage
        nicknameLabel.text = item.nickname
        nicknameLabel.sizeToFit()
    }
    
}
