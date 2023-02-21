//
//  ReportStyleStackView.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/18.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionDomain

protocol ReportTypeStackViewDelegate: AnyObject {
    func reportActionViewDidTapped(type: ReportCase)
}

final class ReportTypeStackView: UIStackView {
    
    weak var settingCategoryStackViewListener: ReportTypeStackViewDelegate?
    
    private var typeArray = [ReportCase]()
    private var typeIndex = 0
    private let widthPadding: CGFloat = 15
    
    let headerBorderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.roundCorners(cornerRadius: 0.2)
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
        return indicatorView
    }()
    
    private var chevronImageViewArray = [UIImageView]()
    
    // MARK: - Initialize
    init(typeArray: [ReportCase]) {
        self.typeArray = typeArray
        super.init(frame: .zero)
        self.axis = .vertical
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(headerBorderView)
        NSLayoutConstraint.activate([
            headerBorderView.topAnchor.constraint(equalTo: self.topAnchor),
            headerBorderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            headerBorderView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    // MARK: - Configure
    func configure() {
        typeArray.map { makeReportDetailView(with: $0) }
            .forEach { self.addArrangedSubview($0) }
    }
    
    private func makeReportDetailView(with type: ReportCase) -> UIView {
        let baseButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
            button.tag = typeIndex
            button.backgroundColor = .white
            button.addTarget(self, action: #selector(settingActionButtonTouchUpInsideAction), for: .touchUpInside)
            button.addTarget(self, action: #selector(settingActionButtonTouchUpOutsideAction), for: [.touchUpOutside, .touchCancel])
            button.addTarget(self, action: #selector(settingActionButtonTouchDownAction), for: .touchDown)
            return button
        }()
        
        typeIndex += 1
        typeArray.append(type)
        let borderView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            view.roundCorners(cornerRadius: 0.2)
            view.backgroundColor = .lightGray
            return view
        }()
        
        let chevronView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "chevron.right")
            imageView.tintColor = .lightGray
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
                
        let actionLabel: UILabel = {
            let label = UILabel()
            label.text = type.rawValue
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 15)
            label.sizeToFit()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        baseButton.addSubview(borderView)
        baseButton.addSubview(actionLabel)
        baseButton.addSubview(chevronView)
        chevronImageViewArray.append(chevronView)
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: baseButton.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: baseButton.trailingAnchor),
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
        configureLoading(index: sender.tag)
        settingCategoryStackViewListener?.reportActionViewDidTapped(type: typeArray[sender.tag])
    }
    
    @objc private func settingActionButtonTouchDownAction(_ sender: UIButton) {
        sender.backgroundColor = .petpionLightGray
    }
    
    @objc private func settingActionButtonTouchUpOutsideAction(_ sender: UIButton) {
        sender.backgroundColor = .white
    }
    
    private func configureLoading(index: Int) {
        chevronImageViewArray[index].isHidden = true
        self.arrangedSubviews[index].addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.trailingAnchor.constraint(equalTo: self.arrangedSubviews[index].trailingAnchor, constant: -widthPadding),
            indicatorView.centerYAnchor.constraint(equalTo: self.arrangedSubviews[index].centerYAnchor)
        ])
    }
}

