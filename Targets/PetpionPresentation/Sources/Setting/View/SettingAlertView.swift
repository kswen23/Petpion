//
//  SettingAlertView.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/02.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore

protocol SettingAlertViewDelegate: AnyObject {
    func toggleSwitchValueChanged(type: SettingModel.AlertType, bool: Bool)
}

final class SettingAlertView: UIView {
    
    let alertType: SettingModel.AlertType
    
    weak var settingAlertViewListener: SettingAlertViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = alertType.rawValue
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.sizeToFit()
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray4
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = alertType.detailDescription
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 7
        [titleLabel, detailLabel].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private lazy var toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.addTarget(self, action: #selector(toggleSwitchValueChanged), for: .valueChanged)
        return toggleSwitch
    }()
    
    @objc private func toggleSwitchValueChanged() {
        settingAlertViewListener?.toggleSwitchValueChanged(type: alertType,
                                                       bool: toggleSwitch.isOn)
    }
    
    let spacing: CGFloat = 25
    
    // MARK: - Initialize
    init(alertType: SettingModel.AlertType) {
        self.alertType = alertType
        super.init(frame: .zero)
        [labelStackView, toggleSwitch].forEach { addSubview($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
        configure()
    }

    // MARK: - Layout
    private func layout() {
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: labelStackView.frame.height),
            labelStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
            toggleSwitch.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
            labelStackView.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -spacing)
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        switch alertType {
        case .voteChance:
            let voteChanceIsOn = UserDefaults.standard.bool(forKey: UserInfoKey.voteChanceNotification)
            toggleSwitch.setOn(voteChanceIsOn, animated: false)
        }
    }
    
}
