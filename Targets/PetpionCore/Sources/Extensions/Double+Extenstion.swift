//
//  Double+Extenstion.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/12/16.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
public extension Double {
    
    func roundDecimal(to place: Int) -> Double {
        let modifiedNumber = pow(10, Double(place))
        var n = self
        n = n * modifiedNumber
        n.round()
        n = n / modifiedNumber
        return n
    }
}
