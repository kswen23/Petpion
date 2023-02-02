//
//  UITextField+Extension.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/31.
//  Copyright © 2023 Petpion. All rights reserved.
//

import UIKit

public extension UITextField {
    
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
