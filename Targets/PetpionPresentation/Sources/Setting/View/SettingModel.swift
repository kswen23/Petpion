//
//  SettingModel.swift
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
    
    enum SettingAction: String, CaseIterable {
        case profile = "프로필"
        // 앱설정
        case alert = "알림설정"
        case inquire = "문의하기"
        // 약관 및 정책
        case termsOfService = "서비스 이용약관"
        // 계정
        case manageBlockedUser = "차단 유저 관리"
        case logout = "로그아웃"
        case signOut = "탈퇴하기"
        
        var coordinatorString: String {
            switch self {
            case .profile:
                return "EditProfileCoordinator"
            case .alert:
                return "EditAlertCoordinator"
            case .termsOfService:
                return "TermsOfServiceCoordinator"
            case .manageBlockedUser:
                return "ManageBlockedUserCoordinator"
            case .logout:
                return ""
            case .signOut:
                return "SignOutCoordinator"
            case .inquire:
                return ""
            }
        }
    }
    
    static func getSettingActions(with category: SettingCategory) -> [SettingAction] {
        switch category {
        case .appSetting:
            return [.alert, .inquire]
        case .appPolicy:
            return [.termsOfService]
        case .account:
            return [.manageBlockedUser, .logout, .signOut]
        }
    }
}

extension SettingModel {
    
    enum AlertType: String, CaseIterable {
        
        case voteChance = "투표기회 충전완료시 알림"
        
        var detailDescription: String {
            switch self {
            case .voteChance:
                return "투표기회가 충전완료되면 알림을 통해 알려드려요."
            }
        }
    }
    
    
}
