//
//  PetpionHallViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

final class PetpionHallViewController: HasCoordinatorViewController, UIGestureRecognizerDelegate {
    
    private lazy var petpionHallCoordinator: PetpionHallCoordinator? = {
        self.coordinator as? PetpionHallCoordinator
    }()
    
    private let viewModel: PetpionHallViewModelProtocol
    
    // MARK: - Initialize
    init(viewModel: PetpionHallViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "명예의 전당"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
