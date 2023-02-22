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
    
    private let launchAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView.init(name: LottieJson.launchAnimation)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundColor = .green
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(launchAnimationView)
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func layoutSubviews() {
        layoutLaunchAnimationView()
    }
    
    private func layoutLaunchAnimationView() {
        NSLayoutConstraint.activate([
            launchAnimationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            launchAnimationView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            launchAnimationView.widthAnchor.constraint(equalToConstant: 200),
            launchAnimationView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
}
