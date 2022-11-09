//
//  DIContainer.swift
//  Config
//
//  Created by 김성원 on 2022/11/07.
//

import Swinject

public protocol Containable {
    
    var container: Container { get set }
    
    func register()
}

public final class DIContainer {
    
    public static let shared: Container = Container()
}
