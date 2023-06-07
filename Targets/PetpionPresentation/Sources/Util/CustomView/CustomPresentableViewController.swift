//
//  CustomPresentableViewController.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/12/08.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

import PetpionCore

open class CustomPresentableViewController: UIViewController, CoordinatorWrapper {
    
    weak var coordinator: Coordinator?
    
    var statusBarShouldBeHidden: Bool = false
    
    lazy var toastAnimationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: xValueRatio(16), weight: .medium)
        label.backgroundColor = .black
        label.textAlignment = .center
        label.textColor = .white
        label.alpha = 0.9
        label.isHidden = true
        return label
    }()
    private lazy var toastAnimationLabelHeightConstant: CGFloat = xValueRatio(40)
    
    private lazy var toastAnimationLabelTopAnchor: NSLayoutConstraint? = toastAnimationLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: toastAnimationLabelHeightConstant)
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
    
    public override var prefersStatusBarHidden: Bool {
        statusBarShouldBeHidden
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func updateStatusBar(hidden: Bool, completion: ((Bool) -> Void)?) {
        statusBarShouldBeHidden = hidden
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func layoutToastAnimationLabel() {
        view.addSubview(toastAnimationLabel)
        NSLayoutConstraint.activate([
            toastAnimationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastAnimationLabel.widthAnchor.constraint(equalToConstant: view.frame.width*0.6),
            toastAnimationLabel.heightAnchor.constraint(equalToConstant: toastAnimationLabelHeightConstant)
        ])
        toastAnimationLabelTopAnchor?.isActive = true
        toastAnimationLabel.roundCorners(cornerRadius: 15)
    }

    func startToastLabelAnimation() {
        toastAnimationLabel.isHidden = false
        toastAnimationLabelTopAnchor?.isActive = false
        toastAnimationLabelTopAnchor = toastAnimationLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -(toastAnimationLabelHeightConstant*2))
        toastAnimationLabelTopAnchor?.isActive = true
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.popDuplicatedLabelToastAnimation()
        })
    }
    
    func popDuplicatedLabelToastAnimation() {
        toastAnimationLabelTopAnchor?.isActive = false
        toastAnimationLabelTopAnchor = toastAnimationLabel.topAnchor.constraint(equalTo: view.bottomAnchor, constant: toastAnimationLabelHeightConstant)
        toastAnimationLabelTopAnchor?.isActive = true
        UIView.animate(withDuration: 0.5,
                       delay: 2.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.toastAnimationLabel.isHidden = true
        })
    }
    
    func postRefreshAction() {
        NotificationCenter.default.post(name: Notification.Name(NotificationName.dataDidChange), object: nil, userInfo: ["action": "refresh"])
    }
}
