//
//  PresentationDIContainer.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/10.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

import PetpionCore
import PetpionDomain
import Swinject
import YPImagePicker

public struct PresentationDIContainer: Containable {
    
    public var container: Swinject.Container = DIContainer.shared
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func register() {
        registerCoordinators()
    }
    
    // MARK: - Coordinator Container
    private func registerCoordinators() {
        container.register(Coordinator.self, name: "MainCoordinator") { _ in
            MainCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "NeedLoginCoordinator") { _ in
            NeedLoginCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "FeedImagePickerCoordinator") { _ in
            FeedImagePickerCoordinator(navigationController: FeedImagePickerViewController())
        }
        
        container.register(Coordinator.self, name: "FeedUploadCoordinator") { _ in
            FeedUploadCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "VoteMainCoordinator") { _ in
            VoteMainCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "VotePetpionCoordinator") { _ in
            VotePetpionCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "UserPageCoordinator") { _ in
            UserPageCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "ReportCoordinator") { _ in
            ReportCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "SettingCoordinator") { _ in
            SettingCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "DetailFeedCoordinator") { _ in
            DetailFeedCoordinator(navigationController: navigationController)
        }
        
        container.register(Coordinator.self, name: "EditFeedCoordinator") { _ in
            EditFeedCoordinator(navigationController: navigationController)
        }
        
        SettingModel.SettingAction.allCases.forEach { settingAction in
            container.register(Coordinator.self, name: settingAction.coordinatorString) { _ in
                switch settingAction {
                case .profile:
                    return EditProfileCoordinator(navigationController: navigationController)
                case .alert:
                    return EditAlertCoordinator(navigationController: navigationController)
                case .version:
                    return EditProfileCoordinator(navigationController: navigationController)
                case .termsOfService:
                    return EditProfileCoordinator(navigationController: navigationController)
                case .openLicense:
                    return EditProfileCoordinator(navigationController: navigationController)
                case .manageBlockedUser:
                    return EditProfileCoordinator(navigationController: navigationController)
                case .logout:
                    return EditProfileCoordinator(navigationController: navigationController)
                case .signOut:
                    return SignOutCoordinator(navigationController: navigationController)
                }
                
            }
        }
        
    }
}
