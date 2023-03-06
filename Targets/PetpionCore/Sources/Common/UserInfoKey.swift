//
//  UserInfoKey.swift
//  PetpionCore
//
//  Created by 김성원 on 2023/01/04.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public enum UserInfoKey: String, CaseIterable {
    case isLogin = "isLogin"
    case firebaseUID = "FirebaseUID"
    case userNotificationsPermission = "userNotificationsPermission"
    case voteChanceNotification = "voteChanceNotification"
    
    public static func deleteAllUserDefaultsValue() {
        UserInfoKey.allCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
}

public struct NotificationName {
    public static let profileUpdated = "ProfileUpdated"
    public static let dataDidChange = "DataDidChange"
}
