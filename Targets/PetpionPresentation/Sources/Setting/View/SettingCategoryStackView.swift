//
//  SettingCategoryStackView.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/30.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

protocol SettingCategoryStackViewDelegate: AnyObject {
    func settingActionViewDidTapped(action: SettingModel.SettingAction)
}

class SettingCategoryStackView: UIStackView {
    
    weak var settingCategoryStackViewListener: SettingCategoryStackViewDelegate?
    private let category: SettingModel.SettingCategory
    
    private var actionArray = [SettingModel.SettingAction]()
    private var actionIndex = 0
    private let widthPadding: CGFloat = 25
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return view
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = category.rawValue
        label.textColor = .systemGray4
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        return label
    }()
        
    // MARK: - Initialize
    init(category: SettingModel.SettingCategory) {
        self.category = category
        super.init(frame: .zero)
        self.axis = .vertical
        layout()
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        layoutHeaderLabel()
    }
    
    private func layoutHeaderLabel() {
        headerView.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: widthPadding),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        self.addArrangedSubview(headerView)
    }
    
    // MARK: - Configure
    func configure() {
        SettingModel.getSettingActions(with: category).map { makeActionView(with: $0) }
            .forEach { self.addArrangedSubview($0) }
    }
    
    private func makeActionView(with action: SettingModel.SettingAction) -> UIView {
        let baseButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 45).isActive = true
            button.tag = actionIndex
            button.backgroundColor = .white
            button.addTarget(self, action: #selector(settingActionButtonTouchUpInsideAction), for: .touchUpInside)
            button.addTarget(self, action: #selector(settingActionButtonTouchUpOutsideAction), for: .touchUpOutside)
            button.addTarget(self, action: #selector(settingActionButtonTouchDownAction), for: .touchDown)
            return button
        }()
        
        actionIndex += 1
        actionArray.append(action)
        let borderView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
            view.roundCorners(cornerRadius: 0.1)
            view.backgroundColor = .lightGray
            return view
        }()
                
        let actionLabel: UILabel = {
            let label = UILabel()
            label.text = action.rawValue
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 18)
            label.sizeToFit()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let chevronView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "chevron.right")
            imageView.tintColor = .darkGray
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        baseButton.addSubview(borderView)
        baseButton.addSubview(actionLabel)
        baseButton.addSubview(chevronView)
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: baseButton.leadingAnchor, constant: widthPadding),
            borderView.trailingAnchor.constraint(equalTo: baseButton.trailingAnchor, constant: -widthPadding),
            borderView.bottomAnchor.constraint(equalTo: baseButton.bottomAnchor),
            actionLabel.leadingAnchor.constraint(equalTo: baseButton.leadingAnchor, constant: widthPadding),
            actionLabel.centerYAnchor.constraint(equalTo: baseButton.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: baseButton.trailingAnchor, constant: -widthPadding),
            chevronView.centerYAnchor.constraint(equalTo: baseButton.centerYAnchor)
        ])
        
        return baseButton
    }
    
    @objc private func settingActionButtonTouchUpInsideAction(_ sender: UIButton) {
        sender.backgroundColor = .white
        settingCategoryStackViewListener?.settingActionViewDidTapped(action: actionArray[sender.tag])
    }
    
    @objc private func settingActionButtonTouchDownAction(_ sender: UIButton) {
        sender.backgroundColor = .petpionLightGray
    }
    
    @objc private func settingActionButtonTouchUpOutsideAction(_ sender: UIButton) {
        sender.backgroundColor = .white
    }
    
}
