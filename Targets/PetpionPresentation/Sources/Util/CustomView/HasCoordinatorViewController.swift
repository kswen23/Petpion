//
//  HasCoordinatorViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/13.
//  Copyright © 2023 Petpion. All rights reserved.
//

import UIKit

protocol CoordinatorWrapper: AnyObject {
    var coordinator: Coordinator? { get set }
}

class HasCoordinatorViewController: UIViewController, CoordinatorWrapper {
    weak var coordinator: Coordinator?
}
