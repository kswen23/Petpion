//
//  MainLoadingView.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/22.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import Lottie

final class MainLoadingView: UIView {
    
    private let petpionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = .init(named: "petpionLogo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let launchAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView.init(name: LottieJson.launchAnimation)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        [petpionImageView, launchAnimationView].forEach { self.addSubview($0) }
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func layoutSubviews() {
        layoutPetpionImageView()
        layoutLaunchAnimationView()
    }
    
    private func layoutPetpionImageView() {
        NSLayoutConstraint.activate([
            petpionImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            petpionImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            petpionImageView.widthAnchor.constraint(equalToConstant: 300),
            petpionImageView.heightAnchor.constraint(equalToConstant: 430)
        ])
    }
    
    private func layoutLaunchAnimationView() {
        NSLayoutConstraint.activate([
            launchAnimationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            launchAnimationView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
            launchAnimationView.widthAnchor.constraint(equalToConstant: 150),
            launchAnimationView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
}
