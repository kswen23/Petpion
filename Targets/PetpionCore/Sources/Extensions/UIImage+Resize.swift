//
//  UIImage+Resize.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/11/25.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

extension UIImage {
    public func resize(newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
//        let scale = newWidth / self.size.width

        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
}
