//
//  DefaultMakeNotificationUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/11.
//  Copyright © 2023 Petpion. All rights reserved.
//

import UserNotifications

import PetpionCore

public final class DefaultMakeNotificationUseCase: MakeNotificationUseCase {
    
    let petpionVoteIdentifier: String = "petpionVoteIdentifier"
    
    public func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { didAllow, error in
            if let error = error {
                return print(error.localizedDescription)
            }
            
            if didAllow {
                UserDefaults.standard.set(true, forKey: UserInfoKey.userNotificationsPermission)
                UserDefaults.standard.set(true, forKey: UserInfoKey.voteChanceNotification)
            } else {
                print("UserNotifications Permission Denied")
            }
        }
    }
    
    public func createPetpionVoteNotification(heart count: Int, latestVoteTime: Date) {
        if UserDefaults.standard.bool(forKey: UserInfoKey.voteChanceNotification) == true {
            let content = makePetpionNotificationContent()
            let trigger = makeNotificationTrigger(heart: count, latestVoteTime: latestVoteTime)
            let request = UNNotificationRequest(identifier: petpionVoteIdentifier,
                                                content: content,
                                                trigger: trigger)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [petpionVoteIdentifier])
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    public func allowPetpionVoteNotification() {
        UserDefaults.standard.set(true, forKey: UserInfoKey.voteChanceNotification)
    }
    
    public func preventPetpionVoteNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [petpionVoteIdentifier])
        UserDefaults.standard.set(false, forKey: UserInfoKey.voteChanceNotification)
    }
    
    // MARK: - Private
    private func makePetpionNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "펫들이 모두 준비됐어요 🐶"
        content.body = "다시 오셔서 펫피온을 뽑아주세요! 🧐"
        return content
    }
    
    private func makeNotificationTrigger(heart count: Int, latestVoteTime: Date) -> UNCalendarNotificationTrigger {
        let neededHeart = User.voteMaxCountPolicy - count
        let dateComponents = DateComponents.afterHourDateComponents(origin: latestVoteTime,
                                                                    after: neededHeart)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        return trigger
    }

}
