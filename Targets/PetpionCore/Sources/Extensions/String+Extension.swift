//
//  String+Extension.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/12/14.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation

public extension String {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter
    }()
    
    static func petpionDateToString(_ date: Date) -> String {
        guard let oneWeekAgo: Date = Calendar.current.date(from: .weekAgoDateComponents()) else { return "" }
        if date < oneWeekAgo {
            return timeToString(date)
        } else {
            return relateTimeToString(date)
        }

    }
    
    static func timeToString(_ time: Date) -> String {
        dateFormatter.dateFormat = "M월 dd일"
        return dateFormatter.string(from: time)
    }
    
    static func relateTimeToString(_ time: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "ko_kr")
        return formatter.localizedString(for: time, relativeTo: Date())
    }
    
}
