//
//  ReportCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/02/18.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

public enum ReportType {
    case user
    case feed
}

public enum ReportActionType {
    case block
    case report
}


public enum ReportCase: String {
    
    public static let user: [ReportCase] = [.unrelatedUserWithPet, .inappropriateUserImage, .inappropriateUserNickname, .other]
    
    public static let feed: [ReportCase] = [.unrelatedFeedWithPet, .containsPromotional, .inappropriateFeed, .other]
    
    // User
    case unrelatedUserWithPet =  "펫과 관련된 게시글을 올리지 않아요"
    case inappropriateUserImage =  "프로필사진이 부적절해요"
    case inappropriateUserNickname = "닉네임이 부적절해요"
    
    // Feed
    case unrelatedFeedWithPet = "펫과 관련된 내용이 아니에요"
    case containsPromotional = "스팸·홍보성 내용이 포함되어 있어요"
    case inappropriateFeed = "게시글에 부적절한 이미지 혹은 내용이 포함되어 있어요"
    
    case other = "기타 (직접 입력)"
}
