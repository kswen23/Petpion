//
//  MainViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
    
    let mainViewModel: MainViewModelProtocol
    
    // MARK: - Initialize
    init(mainViewModel: MainViewModelProtocol) {
        self.mainViewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
        vcStart()
    }
    
    private func vcStart() {
        print("mainViewController start")
        mainViewModel.vmStart()
    }
}
