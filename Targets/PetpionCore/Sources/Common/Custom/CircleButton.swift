//
//  CircleButton.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/12/01.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

public final class CircleButton: UIButton {
    private let diameter: CGFloat
    
    public init(diameter: CGFloat) {
        self.diameter = diameter
        super.init(frame: .zero)
        LayoutCircleButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func LayoutCircleButton() {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: diameter),
            self.heightAnchor.constraint(equalToConstant: diameter)
        ])
        self.roundCorners(cornerRadius: diameter/2)
    }

}
