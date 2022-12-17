//
//  FeedTransitionAnimation.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/12/08.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

import PetpionDomain

enum AnimationType {
    case present
    case dismiss
}

final class FeedTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    let animationType: AnimationType
    let dependency: FeedTransitionDependency
    
    init(animationType: AnimationType, dependency: FeedTransitionDependency) {
        self.animationType = animationType
        self.dependency = dependency
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if animationType == .present {
            animatePresent(using: transitionContext)
        } else {
            animateDismiss(using: transitionContext)
        }
    }
    
    private func animatePresent(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let transitionViewController = transitionContext.viewController(forKey: .from),
              let fromViewController = (transitionViewController as? UINavigationController)?.viewControllers[0] as? MainViewController,
              let toViewController = transitionViewController.presentedViewController as? DetailFeedViewController,
              let baseCollectionViewCell = fromViewController.baseCollectionView.cellForItem(at: dependency.baseCellIndexPath) as? BaseCollectionViewCell,
              let selectedFeedCell = baseCollectionViewCell.petFeedCollectionView.cellForItem(at: dependency.feedCellIndexPath) as? PetFeedCollectionViewCell else { return }
        let cellImageViewFrame = selectedFeedCell.convert(selectedFeedCell.thumbnailImageView.frame, to: toViewController.view)
        let cellBaseViewFrame = selectedFeedCell.convert(selectedFeedCell.baseView.frame, to: toViewController.view)
        
        containerView.addSubview(toViewController.view)
        toViewController.view.translatesAutoresizingMaskIntoConstraints = false
        toViewController.view.roundCorners(cornerRadius: 10)
        toViewController.setChildViewLayoutByZoomOut(childView: toViewController.view,
                                                     backgroundView: containerView,
                                                     childViewFrame: cellBaseViewFrame,
                                                     imageFrame: cellImageViewFrame)
        containerView.layoutIfNeeded()
        toViewController.setupChildViewLayoutByZoomIn(childView: toViewController.view,
                                                      backgroundView: containerView)
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {
            containerView.layoutIfNeeded()
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
    
    private func animateDismiss(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let transitionViewController = transitionContext.viewController(forKey: .from),
              let fromViewController = transitionViewController as? DetailFeedViewController,
              let toViewController = (transitionContext.viewController(forKey: .to) as? UINavigationController)?.viewControllers[0] as? MainViewController,
              let baseCollectionViewCell = toViewController.baseCollectionView.cellForItem(at: dependency.baseCellIndexPath) as? BaseCollectionViewCell,
              let selectedFeedCell = baseCollectionViewCell.petFeedCollectionView.cellForItem(at: dependency.feedCellIndexPath) as? PetFeedCollectionViewCell else { return }
        let cellImageViewFrame = selectedFeedCell.convert(selectedFeedCell.thumbnailImageView.frame, to: toViewController.view)
        let cellBaseViewFrame = selectedFeedCell.convert(selectedFeedCell.baseView.frame, to: toViewController.view)
        fromViewController.setChildViewLayoutByZoomOut(childView: fromViewController.view,
                                                       backgroundView: containerView,
                                                       childViewFrame: cellBaseViewFrame,
                                                       imageFrame: cellImageViewFrame)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            containerView.layoutIfNeeded()
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
    
}

public struct FeedTransitionDependency {
    
    var baseCellIndexPath: IndexPath
    var feedCellIndexPath: IndexPath
    
    init(baseCellIndexPath: IndexPath,
         feedCellIndexPath: IndexPath) {
        self.baseCellIndexPath = baseCellIndexPath
        self.feedCellIndexPath = feedCellIndexPath
    }
}
