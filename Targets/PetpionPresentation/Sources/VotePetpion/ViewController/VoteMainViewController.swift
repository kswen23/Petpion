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
import PetpionDomain

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
    private lazy var userHeartStackView: UIStackView = {
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
        for i in 0 ..< User.voteMaxCountPolicy {
            let heartView = makeHeartView()
            stackView.addArrangedSubview(heartView)
        }
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
        label.text = "00:00"
        label.textColor = .white
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
    
    private let sleepingCatView: LottieAnimationView = {
        let animationView = LottieAnimationView.init(name: LottieJson.sleepingCat)
        animationView.loopMode = .loop
        return animationView
    }()
    
    private let mainCommentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var startVoteButton: CustomShimmerButton = {
        guard let petpionOrange: CGColor = UIColor.petpionOrange?.cgColor,
              let petpionLightOrange: CGColor = UIColor.petpionLightOrange?.cgColor else {
            return UIButton() as! CustomShimmerButton
        }
        let button = CustomShimmerButton(gradientColorOne: petpionOrange, gradientColorTwo: petpionLightOrange)
        button.setTitle("투표 시작", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        button.addTarget(self, action: #selector(startVoteButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func startVoteButtonDidTapped() {
        viewModel.startVoting()
    }
    
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
        layout()
        configure()
        binding()
        print("viewDidLoad")
//        viewModel.synchronizeWithServer()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutBottomSheetView()
        layoutUserHeartStackView()
        layoutRemainingTimeLabel()
        layoutHeartChargingImageView()
        layoutMainCommentLabel()
        layoutCatLoadingView()
        layoutSleepingCatView()
        layoutStartVoteButton()
        layoutAppearCatView()
    }
    
    private func layoutBottomSheetView() {
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
            mainCommentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainCommentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func layoutCatLoadingView() {
        bottomSheetView.addSubview(catLoadingView)
        catLoadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catLoadingView.topAnchor.constraint(equalTo: mainCommentLabel.bottomAnchor, constant: 20),
            catLoadingView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            catLoadingView.widthAnchor.constraint(equalToConstant: 300),
            catLoadingView.heightAnchor.constraint(equalToConstant: 300)
        ])
        bottomSheetView.bringSubviewToFront(catLoadingView)
        catLoadingView.isHidden = true
    }
    
    private func layoutSleepingCatView() {
        bottomSheetView.addSubview(sleepingCatView)
        sleepingCatView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sleepingCatView.topAnchor.constraint(equalTo: mainCommentLabel.bottomAnchor, constant: 20),
            sleepingCatView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            sleepingCatView.widthAnchor.constraint(equalToConstant: 300),
            sleepingCatView.heightAnchor.constraint(equalToConstant: 300)
        ])
        bottomSheetView.bringSubviewToFront(sleepingCatView)
        sleepingCatView.isHidden = true
    }
    
    private func layoutStartVoteButton() {
        bottomSheetView.addSubview(startVoteButton)
        startVoteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startVoteButton.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: 20),
            startVoteButton.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: -20),
            startVoteButton.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor, constant: -70),
            startVoteButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        bottomSheetView.bringSubviewToFront(startVoteButton)
        startVoteButton.roundCorners(cornerRadius: 20)
    }
    
    private func layoutAppearCatView() {
        bottomSheetView.addSubview(appearCatView)
        appearCatView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appearCatView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            appearCatView.bottomAnchor.constraint(equalTo: startVoteButton.topAnchor),
            appearCatView.widthAnchor.constraint(equalToConstant: 300),
            appearCatView.heightAnchor.constraint(equalToConstant: 300)
        ])
        appearCatView.isHidden = true
    }
    
    // MARK: - Configure
    private func configure() {
        configureBackground()
    }
    
    private func configureBackground() {
        view.backgroundColor = .petpionIndigo
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - Binding
    private func binding() {
        bindHeartSubject()
        bindRemainingTimeSubject()
        bindVoteMainStateSubject()
    }
    
    private func bindHeartSubject() {
        viewModel.heartSubject.sink { [weak self] heartTypeArr in
            guard let heartViews = self?.userHeartStackView.arrangedSubviews as? [UIImageView] else { return }
            for i in 0 ..< heartViews.count {
                heartTypeArr[i].configureHeartImage(to: heartViews[i])
            }
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
        viewModel.voteMainViewControllerStateSubject.sink { [weak self] viewControllerState in
            
            switch viewControllerState {
            case .preparing:
                self?.configurePreparing()
            case .ready:
                self?.configureReady()
            case .start:
                self?.configureStart()
            case .disable:
                self?.configureDisable()
            }
        }.store(in: &cancellables)
    }
    
    private func configurePreparing() {
        catLoadingView.isHidden = false
        catLoadingView.play()
        mainCommentLabel.text = "펫들을 부르는 중이에요!"
        startVoteButton.backgroundColor = .lightGray
        startVoteButton.stopAnimating()
        startVoteButton.isEnabled = false
        viewModel.startFetchingVotePareArray()
        appearCatView.stop()
        appearCatView.isHidden = true
        sleepingCatView.stop()
        sleepingCatView.isHidden = true
    }
    
    private func configureReady() {
        catLoadingView.stop()
        catLoadingView.isHidden = true
        mainCommentLabel.text = "투표가 준비됐어요!"
        startVoteButton.startAnimating()
        startVoteButton.isEnabled = true
        appearCatView.isHidden = false
        appearCatView.play()
    }
    
    private func configureStart() {
        appearCatView.stop()
        appearCatView.isHidden = true
        coordinator?.pushVotePetpion(with: viewModel.fetchedVotePare)
//        catLoadingView.isHidden = false
//        catLoadingView.play()
//        mainCommentLabel.text = "펫들을 부르는 중이에요!"
//        startVoteButton.backgroundColor = .lightGray
//        startVoteButton.isEnabled = false
    }
    
    private func configureDisable() {
        mainCommentLabel.text = "가능한 투표를 모두 마쳤어요!\n충전시간을 기다려주세요.."
        sleepingCatView.isHidden = false
        sleepingCatView.play()
        startVoteButton.stopAnimating()
        startVoteButton.backgroundColor = .lightGray
        startVoteButton.isEnabled = false
        catLoadingView.stop()
        catLoadingView.isHidden = true
        appearCatView.stop()
        appearCatView.isHidden = true
        
//        sleepingCatView.stop()
//        sleepingCatView.isHidden = true
    }
}

extension VoteMainViewController {
    
    func makeHeartView() -> UIImageView {
        let heartAnimatingView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = .init(systemName: "heart")
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
        
        return heartAnimatingView
    }

}

extension HeartType {
        
    func configureHeartImage(to view: UIImageView) {
        switch self {
        case .fill:
            view.tintColor = .red
            view.image = .init(systemName: "heart.fill")
        case .empty:
            view.tintColor = .lightGray
            view.image = .init(systemName: "heart")
        }
    }
}
