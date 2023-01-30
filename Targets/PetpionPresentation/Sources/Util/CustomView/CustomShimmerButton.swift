//
//  CustomShimmerButton.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/08.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

final class CustomShimmerButton: UIButton {
    
    let gradientColorOne: CGColor
    let gradientColorTwo: CGColor
    
    private let gradientLayer = CAGradientLayer()
    
    init(gradientColorOne: CGColor, gradientColorTwo: CGColor) {
        self.gradientColorOne = gradientColorOne
        self.gradientColorTwo = gradientColorTwo
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = self.bounds
    }
    
    func addGradientLayer() -> CAGradientLayer {
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        self.layer.addSublayer(gradientLayer)
        
        return gradientLayer
    }
    
    func addAnimation() -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.2
        return animation
    }
    
    func startAnimating() {
        gradientLayer.isHidden = false
        let gradientLayer = addGradientLayer()
        let animation = addAnimation()
        
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
    
    func stopAnimating() {
        gradientLayer.isHidden = true
        gradientLayer.removeAllAnimations()
    }
}
