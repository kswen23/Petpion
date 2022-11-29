//
//  AspectRatioSelectButton.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/28.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

import PetpionCore

public protocol AspectRatioButtonDelegate {
    func aspectRatioButtonDidTapped(tag: Int)
}

public final class AspectRatioSelectButton: UIView {
    
    var aspectRatioButtonDelegate: AspectRatioButtonDelegate?
    
    let buttonDiameter: CGFloat
    
    private let selectingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alpha = 0.8
        return stackView
    }()
    private lazy var ratioButtons: [UIButton] = {
        var tagNumber = 1
        var buttons = [UIButton]()
        CellAspectRatio.allCases.forEach { ratio in
            let ratioButton = makeCircleButton(diameter: buttonDiameter)
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
    
    private lazy var currentButton: UIButton = self.makeCircleButton(diameter: buttonDiameter)
    private var stackViewLeadingAnchor: NSLayoutConstraint?
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
            selectingStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        stackViewLeadingAnchor = selectingStackView.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: -buttonDiameter/2)
        stackViewLeadingAnchor?.isActive = true
        stackViewTrailingAnchor = selectingStackView.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: buttonDiameter/2)
        stackViewTrailingAnchor?.isActive = true
        ratioButtons.forEach { selectingStackView.addArrangedSubview($0) }
        selectingStackView.roundCorners(cornerRadius: buttonDiameter/2)
        selectingStackView.backgroundColor = .lightGray
    }
    
    private func configureCurrentButton() {
        selectingStackView.addSubview(currentButton)
        currentButton.leadingAnchor.constraint(equalTo: selectingStackView.leadingAnchor).isActive = true
        currentButton.setAttributedTitle(NSAttributedString(string: "1:1",
                                                            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]), for: .normal)
        currentButton.setTitleColor(.white, for: .normal)
        currentButton.backgroundColor = .systemGray
        currentButton.addTarget(self, action: #selector(currentButtonDidTapped), for: .touchUpInside)
    }
    
    @objc func currentButtonDidTapped() {
        animateStackView()
    }
    
    private func animateStackView() {
        stackViewFolded.toggle()
        stackViewLeadingAnchor?.isActive = false
        stackViewTrailingAnchor?.isActive = false
        switch stackViewFolded {
        case true:
            stackViewLeadingAnchor = selectingStackView.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: -buttonDiameter/2)
            stackViewTrailingAnchor = selectingStackView.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: buttonDiameter/2)
        case false:
            stackViewLeadingAnchor = selectingStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            stackViewTrailingAnchor = selectingStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        }
        stackViewLeadingAnchor?.isActive = true
        stackViewTrailingAnchor?.isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
    
    private func makeCircleButton(diameter: CGFloat) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: diameter).isActive = true
        button.heightAnchor.constraint(equalToConstant: diameter).isActive = true
        button.roundCorners(cornerRadius: diameter/2)
        return button
    }
    
    @objc func ratioButtonDidTapped(_ sender: UIButton) {
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
