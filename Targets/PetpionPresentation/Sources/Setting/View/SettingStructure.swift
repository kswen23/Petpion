//
//  SettingStructure.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/30.
//  Copyright © 2023 Petpion. All rights reserved.
//

struct SettingModel {
    
    enum SettingCategory: String, CaseIterable {
        case appSetting = "앱설정"
        case appPolicy = "약관 및 정책"
        case account = "계정"
    }
    
    enum SettingAction: String {
        // 앱설정
        case alert = "알림설정"
        // 약관 및 정책
        case version = "앱 버전정보"
        case termsOfService = "서비스 이용약관"
        case openLicense = "오픈라이센스"
        // 계정
        case manageBlockedUser = "차단 사용자 관리"
        case logout = "로그아웃"
        case delete = "탈퇴하기"
    }
    
    static func getSettingActions(with category: SettingCategory) -> [SettingAction] {
        switch category {
        case .appSetting:
            return [.alert]
        case .appPolicy:
            return [.version, .termsOfService, .openLicense]
        case .account:
            return [.manageBlockedUser, .logout, .delete]
        }
    }
}
