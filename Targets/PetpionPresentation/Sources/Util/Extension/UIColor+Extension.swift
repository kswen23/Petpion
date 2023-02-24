//
//  UIColor+Extension.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/02.
//  Copyright © 2023 Petpion. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var petpionRed: UIColor { return UIColor(named: "petpionRed") ?? UIColor.init() }
    
    class var petpionBlue: UIColor { return UIColor(named: "petpionBlue") ?? UIColor.init() }
    
    class var petpionIndigo: UIColor { return UIColor(named: "petpionIndigo") ?? UIColor.init() }
    
    class var petpionOrange: UIColor { return UIColor(named: "petpionOrange") ?? UIColor.init() }
    
    class var petpionLightOrange: UIColor { return UIColor(named: "petpionLightOrange") ?? UIColor.init() }
    
    class var petpionLightGray: UIColor { return UIColor(named: "petpionLightGray") ?? UIColor.init() }
    
    convenience init(hex: String) {
      var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      
      if hexFormatted.hasPrefix("#") {
        hexFormatted = String(hexFormatted.dropFirst())
      }
      
      var color: UInt64 = 0
      Scanner(string: hexFormatted).scanHexInt64(&color)
      
      let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
      let green = CGFloat((color & 0x00FF00) >> 8) / 255.0
      let blue = CGFloat(color & 0x0000FF) / 255.0
      
      self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
