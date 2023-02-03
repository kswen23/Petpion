//
//  SettingCustomViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/02.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Foundation
import UIKit

class SettingCustomViewController: UIViewController {
    
    private lazy var navigationBarBorder: CALayer = {
        let border = CALayer()
        border.borderColor = UIColor.lightGray.cgColor
        border.borderWidth = 0.2
        border.frame = CGRectMake(0, self.navigationController?.navigationBar.frame.size.height ?? 0, self.navigationController?.navigationBar.frame.size.width ?? 0, 0.2)
        return border
    }()
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        self.navigationController?.navigationBar.layer.addSublayer(navigationBarBorder)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationBarBorder.removeFromSuperlayer()
        super.viewWillDisappear(animated)
    }
}
