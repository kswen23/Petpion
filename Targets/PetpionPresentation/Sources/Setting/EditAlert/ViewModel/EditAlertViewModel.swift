//
//  EditAlertViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/02.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation

import PetpionDomain

protocol EditAlertViewModelInput{
    func toggleSwitchDidChanged(alertType: SettingModel.AlertType, value: Bool)
}

protocol EditAlertViewModelOutput{
    
}

protocol EditAlertViewModelProtocol: EditAlertViewModelInput, EditAlertViewModelOutput {
    var makeNotificationUseCase: MakeNotificationUseCase { get }
}

final class EditAlertViewModel: EditAlertViewModelProtocol {
    
    let makeNotificationUseCase: MakeNotificationUseCase
    
    // MARK: - Initialize
    init(makeNotificationUseCase: MakeNotificationUseCase) {
        self.makeNotificationUseCase = makeNotificationUseCase
    }
    
    // MARK: - Input
    func toggleSwitchDidChanged(alertType: SettingModel.AlertType, value: Bool) {
        switch alertType {
        case .voteChance:
            changeVoteChanceNotification(with: value)
        }
    }
    
    private func changeVoteChanceNotification(with bool: Bool) {
        if bool == true {
            makeNotificationUseCase.allowPetpionVoteNotification()
        } else {
            makeNotificationUseCase.preventPetpionVoteNotification()
        }
    }
}
