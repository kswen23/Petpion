//
//  ReusableView+Identifier.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/11.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

protocol ReusableView: UIView {
    static var identifier: String { get }
}

extension ReusableView {
    static public var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: ReusableView {}
