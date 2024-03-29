//
//  AspectRatioSelectButton.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/28.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

import PetpionCore

public protocol AspectRatioButtonDelegate: AnyObject {
    func aspectRatioButtonDidTapped(tag: Int)
}

public final class AspectRatioSelectButton: UIView {
    
    weak var aspectRatioButtonDelegate: AspectRatioButtonDelegate?
    
    private let buttonDiameter: CGFloat
    
    private lazy var ratioButtons: [UIButton] = {
        var tagNumber = 1
        var buttons = [UIButton]()
        CellAspectRatio.allCases.forEach { ratio in
            let ratioButton = CircleButton(diameter: buttonDiameter)
            ratioButton.translatesAutoresizingMaskIntoConstraints = false
            ratioButton.setAttributedTitle(NSAttributedString(string: ratio.ratioString,
                                                              attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]), for: .normal)
            ratioButton.setTitleColor(.white, for: .normal)
            ratioButton.tag = tagNumber
            ratioButton.addTarget(
                self,
                action: #selector(ratioButtonDidTapped(_:)),
                for: .touchUpInside
            )
            tagNumber += 1
            buttons.append(ratioButton)
        }
        
        buttons.insert(UIButton(), at: 0)
        buttons.append(UIButton())
        return buttons
    }()
    
    private lazy var selectingStackView: UIStackView = {
        let stackView = UIStackView()
        ratioButtons.forEach { stackView.addArrangedSubview($0) }
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alpha = 0.8
        stackView.roundCorners(cornerRadius: buttonDiameter/2)
        return stackView
    }()
    
    private lazy var currentButton: UIButton = CircleButton(diameter: buttonDiameter)
    private var stackViewTrailingAnchor: NSLayoutConstraint?
    
    private var stackViewFolded: Bool = true
    
    init(buttonDiameter: CGFloat) {
        self.buttonDiameter = buttonDiameter
        super.init(frame: CGRect.zero)
        configureStackView()
        configureCurrentButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureStackView() {
        addSubview(selectingStackView)
        selectingStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectingStackView.topAnchor.constraint(equalTo: self.topAnchor),
            selectingStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            selectingStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            selectingStackView.heightAnchor.constraint(equalToConstant: buttonDiameter)
        ])
        stackViewTrailingAnchor = selectingStackView.trailingAnchor.constraint(equalTo: self.leadingAnchor, constant: buttonDiameter)
        ratioButtons.forEach { $0.isHidden = true }
        stackViewTrailingAnchor?.isActive = true
        selectingStackView.backgroundColor = .lightGray
    }
    
    private func configureCurrentButton() {
        selectingStackView.addSubview(currentButton)
        currentButton.translatesAutoresizingMaskIntoConstraints = false
        currentButton.centerYAnchor.constraint(equalTo: selectingStackView.centerYAnchor).isActive = true
        currentButton.leadingAnchor.constraint(equalTo: selectingStackView.leadingAnchor).isActive = true
        currentButton.setAttributedTitle(NSAttributedString(string: "1:1",
                                                            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]), for: .normal)
        currentButton.setTitleColor(.white, for: .normal)
        currentButton.backgroundColor = .systemGray
        currentButton.addTarget(self, action: #selector(currentButtonDidTapped), for: .touchUpInside)
    }
    
    @objc private func currentButtonDidTapped() {
        animateStackView()
    }
    
    private func animateStackView() {
        stackViewFolded.toggle()
        switch stackViewFolded {
        case true:
            ratioButtons.forEach { $0.isHidden = true }
            self.layoutIfNeeded()
            stackViewTrailingAnchor?.isActive = false
            stackViewTrailingAnchor = selectingStackView.trailingAnchor.constraint(equalTo: self.leadingAnchor, constant: buttonDiameter)
        case false:
            ratioButtons.forEach { $0.isHidden = false }
            stackViewTrailingAnchor?.isActive = false
            stackViewTrailingAnchor = selectingStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        }

        stackViewTrailingAnchor?.isActive = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
    
    @objc private func ratioButtonDidTapped(_ sender: UIButton) {
        aspectRatioButtonDelegate?.aspectRatioButtonDidTapped(tag: sender.tag)
        animateStackView()
    }
    
    func configureButton(_ ratio: CellAspectRatio) {
        currentButton.setAttributedTitle(NSAttributedString(string: ratio.ratioString,
                                                            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]), for: .normal)
        ratioButtons.forEach { $0.setTitleColor(.white, for: .normal) }
        ratioButtons[ratio.rawValue].setTitleColor(.yellow, for: .normal)
    }
}
