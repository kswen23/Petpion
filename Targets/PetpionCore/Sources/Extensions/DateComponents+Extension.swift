//
//  DateComponents+Extension.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/11.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public extension DateComponents {
    
    static let currentDateTime = Date()
    static let userCalendar = Calendar.current
    
    static func currentDateTimeComponents() -> DateComponents {
        let requestedComponents: Set<Calendar.Component> = [
            .year,
            .month,
            .day
        ]
        return userCalendar.dateComponents(requestedComponents, from: currentDateTime)
    }
    
    static func weekAgoDateComponents() -> DateComponents {
        var currentDateComponents: DateComponents = .currentDateTimeComponents()
        currentDateComponents.day = currentDateComponents.day! - 7
        return currentDateComponents
    }
}
