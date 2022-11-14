//
//  Pet.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/14.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

public struct Pet {
    
    public let ID: String
    public let owner: User
    public let uploadDate: Date
    public var likeCount: Int
    public let image: UIImage
    
}

extension Pet {
    static let mock: [Pet] = {
       [
       ]
    }()
}
