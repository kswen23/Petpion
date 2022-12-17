//
//  FeedTransitionController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/08.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

final class FeedTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    
    let dependency: FeedTransitionDependency
    
    init(dependency: FeedTransitionDependency) {
        self.dependency = dependency
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FeedPresentationController(presentedViewController: presented,
                                          presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FeedTransitionAnimation(animationType: .present, dependency: dependency)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FeedTransitionAnimation(animationType: .dismiss, dependency: dependency)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

}
