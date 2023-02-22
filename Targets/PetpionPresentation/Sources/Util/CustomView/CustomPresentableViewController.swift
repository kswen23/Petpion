//
//  CustomPresentableViewController.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/12/08.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

open class CustomPresentableViewController: UIViewController, CoordinatorWrapper {
    
    weak var coordinator: Coordinator?
    
    var statusBarShouldBeHidden: Bool = false
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
    
    public override var prefersStatusBarHidden: Bool {
        statusBarShouldBeHidden
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    public func updateStatusBar(hidden: Bool, completion: ((Bool) -> Void)?) {
        statusBarShouldBeHidden = hidden
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

}
