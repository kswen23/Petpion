//
//  Coordinator.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/17.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore
import PetpionDomain

public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

public extension Coordinator {
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

protocol CoordinatorWrapper: AnyObject {
    var coordinator: Coordinator? { get set }
}

class HasCoordinatorViewController: UIViewController, CoordinatorWrapper {
    weak var coordinator: Coordinator?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        view.backgroundColor = .white
    }
}
