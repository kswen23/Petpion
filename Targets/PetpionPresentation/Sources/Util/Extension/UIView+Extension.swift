//
//  UIView+Extension.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/11/23.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

public extension UIView {
    
    func roundCorners(cornerRadius: CGFloat,
                      maskedCorners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
    
    func xValueRatio(_ value: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.maxX*(value/390)
    }
    
    func yValueRatio(_ value: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.maxY*(value/844)
    }
    
    func overSizeYValueRatio(_ value: CGFloat) -> CGFloat {
        let value = Int(value)
        let divisionValue = value / 500
        let remainder = value % 500
        
        return CGFloat((500*divisionValue) + remainder)
    }
    
    func calculateXMax() -> CGFloat {
        return UIScreen.main.bounds.maxX
    }
    
    func calculateYMax() -> CGFloat {
        return UIScreen.main.bounds.maxY
    }

}
