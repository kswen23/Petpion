//
//  NotificationObservable.swift
//  PetpionCore
//
//  Created by 김성원 on 2023/02/03.
//  Copyright © 2023 Petpion. All rights reserved.
//

public protocol NotificationObservable: AnyObject {
    func addObserver()
    func removeObserver()
}
