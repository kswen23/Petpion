//
//  VoteMainViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/06.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import UIKit

import Lottie

final class VoteMainViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: VoteMainViewModelProtocol
    weak var coordinator: VotePetpionCoordinator?
    
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.roundCorners(cornerRadius: 20)
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.3
        return view
    }()
    private let userHeartStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.borderWidth = 3
        stackView.roundCorners(cornerRadius: 15)
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let heartChargingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(systemName: "bolt.heart.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .red
        return imageView
    }()
    
    private let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    private let catLoadingView: LottieAnimationView = {
        let animationView = LottieAnimationView.init(name: LottieJson.catLoading)
        animationView.loopMode = .loop
        return animationView
    }()
    
    private let appearCatView: LottieAnimationView = {
        let animationResource: [String] = [LottieJson.appearCatBlack, LottieJson.appearCatGreen, LottieJson.appearCatYellow]
        guard let appearCat = animationResource.randomElement() else { return LottieAnimationView.init() }
        let animationView = LottieAnimationView.init(name: appearCat)
        return animationView
    }()
    
    private let mainCommentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initialize
    init(viewModel: VoteMainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        layout()
        binding()
        view.backgroundColor = .purple
        
        view.addSubview(appearCatView)
        appearCatView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appearCatView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appearCatView.topAnchor.constraint(equalTo: catLoadingView.bottomAnchor),
            appearCatView.widthAnchor.constraint(equalToConstant: 300),
            appearCatView.heightAnchor.constraint(equalToConstant: 300)
        ])
        self.appearCatView.play()
        viewModel.fetchChanceCreationRemainingTime()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutHeaderView()
        layoutUserHeartStackView()
        layoutRemainingTimeLabel()
        layoutHeartChargingImageView()
        layoutMainCommentLabel()
        layoutCatLoadingView()
    }
    
    private func layoutHeaderView() {
        view.addSubview(bottomSheetView)
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetView.heightAnchor.constraint(equalToConstant: view.frame.height*0.7)
        ])
    }
    
    private func layoutUserHeartStackView() {
        view.addSubview(userHeartStackView)
        userHeartStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userHeartStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
//            userHeartStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            userHeartStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func layoutRemainingTimeLabel() {
        view.addSubview(remainingTimeLabel)
        remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            remainingTimeLabel.topAnchor.constraint(equalTo: userHeartStackView.bottomAnchor, constant: 5),
            remainingTimeLabel.trailingAnchor.constraint(equalTo: userHeartStackView.trailingAnchor, constant: -3),
            remainingTimeLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func layoutHeartChargingImageView() {
        view.addSubview(heartChargingImageView)
        heartChargingImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heartChargingImageView.centerYAnchor.constraint(equalTo: remainingTimeLabel.centerYAnchor),
            heartChargingImageView.trailingAnchor.constraint(equalTo: remainingTimeLabel.leadingAnchor, constant: -3),
            heartChargingImageView.widthAnchor.constraint(equalToConstant: 25),
            heartChargingImageView.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    private func layoutMainCommentLabel() {
        bottomSheetView.addSubview(mainCommentLabel)
        mainCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainCommentLabel.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: 20),
            mainCommentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainCommentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func layoutCatLoadingView() {
        view.addSubview(catLoadingView)
        catLoadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catLoadingView.topAnchor.constraint(equalTo: mainCommentLabel.bottomAnchor, constant: 20),
            catLoadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            catLoadingView.widthAnchor.constraint(equalToConstant: 300),
            catLoadingView.heightAnchor.constraint(equalToConstant: 300)
        ])
        self.catLoadingView.play()
    }
    
    // MARK: - Binding
    private func binding() {
        bindHeartSubject()
        bindRemainingTimeSubject()
        bindVoteMainStateSubject()
    }
    
    private func bindHeartSubject() {
        viewModel.heartSubject.sink { [weak self] heartTypeArr in
            heartTypeArr
                .map{ $0.makeHeartView() }
                .forEach { self?.userHeartStackView.addArrangedSubview($0) }
        }.store(in: &cancellables)
    }
    
    private func bindRemainingTimeSubject() {
        viewModel.remainingTimeSubject.sink { [weak self] timeInterval in
            if timeInterval == self?.viewModel.maxTimeInterval {
                self?.remainingTimeLabel.text = "MAX"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "mm:ss"
                let zeroDate = dateFormatter.date(from: "00:00")
                let showingDate = zeroDate! + timeInterval
                self?.remainingTimeLabel.text = dateFormatter.string(from: showingDate)
            }
        }.store(in: &cancellables)
    }
    
    private func bindVoteMainStateSubject() {
        viewModel.voteMainStateSubject.sink { [weak self] state in
            
            switch state {
            case .preparing:
                self?.mainCommentLabel.text = "펫들을 부르는 중이에요! 🐱🐶"
            case .ready:
                break
            case .start:
                break
            case .disable:
                break
            }
        }.store(in: &cancellables)
    }
}

extension HeartType {
    
    func makeHeartView() -> UIView {
        let heartAnimatingView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = .init(systemName: self.rawValue)
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.toValue = 1.2
            animation.duration = 1
            animation.autoreverses = true
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.repeatCount = Float.infinity
            imageView.layer.add(animation, forKey: "pulse")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            return imageView
        }()
        
        switch self {
        case .fill:
            heartAnimatingView.tintColor = .red
        case .empty:
            heartAnimatingView.tintColor = .lightGray
        }
        
        return heartAnimatingView
    }
    
}
