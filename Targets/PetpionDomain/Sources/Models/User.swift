//
//  User.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/14.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

public struct User {
    
    public let nickName: String
    public let profileImage: UIImage
    
}

extension User {
    
    static let empty: Self = .init(nickName: "", profileImage: UIImage())
}
