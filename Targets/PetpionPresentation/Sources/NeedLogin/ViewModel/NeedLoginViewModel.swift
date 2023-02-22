//
//  NeedLoginViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

protocol NeedLoginViewModelInput {
    
}

protocol NeedLoginViewMOdelOutput {
    
}

protocol NeedLoginViewModelProtocol: NeedLoginViewModelInput, NeedLoginViewMOdelOutput {
    var navigationItemType: NavigationItemType { get }
}

final class NeedLoginViewModel: NeedLoginViewModelProtocol {
    
    let navigationItemType: NavigationItemType
    
    // MARK: - Initialize
    init(navigationItemType: NavigationItemType) {
        self.navigationItemType = navigationItemType
    }
}
