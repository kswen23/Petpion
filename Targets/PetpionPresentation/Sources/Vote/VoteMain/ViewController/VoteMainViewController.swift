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
import AVFoundation

final class VoteMainViewController: HasCoordinatorViewController {
    
    lazy var voteMainCoordinator: VoteMainCoordinator? = {
        return coordinator as? VoteMainCoordinator
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: VoteMainViewModelProtocol
    
    private lazy var bottomSheetView: UIView = {
        let view = UIView()
        view.roundCorners(cornerRadius: xValueRatio(20))
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: xValueRatio(4))
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.3
        return view
    }()
    
    private lazy var backBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem()
        barButton.title = ""
        barButton.tintColor = .white
        barButton.image = UIImage(systemName: "chevron.backward")
        barButton.target = self
        barButton.action = #selector(popViewController)
        return barButton
    }()
    
    @objc private func popViewController() {
        voteMainCoordinator?.popViewController()
    }
    
    private lazy var trophyBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "trophy"), style: .done, target: self, action: #selector(trophyButtonDidTapped))
        barButton.tintColor = .white
        return barButton
    }()
    
    @objc private func trophyButtonDidTapped() {
        voteMainCoordinator?.pushPetpionHallViewController()
    }
    
    private lazy var userHeartStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = xValueRatio(5)
        stackView.alignment = .center
        stackView.layer.borderColor = UIColor.white.cgColor
        stackView.layer.borderWidth = 3
        stackView.roundCorners(cornerRadius: 15)
        stackView.layoutMargins = UIEdgeInsets(top: xValueRatio(10), left: xValueRatio(15), bottom: xValueRatio(10), right: xValueRatio(15))
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
    
    private lazy var remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: xValueRatio(18))
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
    
    private lazy var mainCommentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: xValueRatio(25))
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var startVoteButton: CustomShimmerButton = {
        let button = CustomShimmerButton(gradientColorOne: UIColor.petpionOrange.cgColor,
                                         gradientColorTwo: UIColor.petpionLightOrange.cgColor)
        button.setTitle("투표 시작", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: xValueRatio(30), weight: .bold)
        button.addTarget(self, action: #selector(startVoteButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func startVoteButtonDidTapped() {
        viewModel.startVoting()
    }
    
    private lazy var startVoteLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: xValueRatio(30), weight: .bold)
        label.text = "투표 시작"
        return label
    }()
    
    private lazy var tutorialButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("투표하는 방법", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: xValueRatio(-10), bottom: 0, right: xValueRatio(10))
        button.titleLabel?.font = .systemFont(ofSize: xValueRatio(20), weight: .bold)
        button.setImage(.init(named: "tipImage"), for: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.roundCorners(cornerRadius: 10)
        button.addTarget(self, action: #selector(presentTutorialView), for: .touchUpInside)
        return button
    }()
    
    private lazy var tutorialView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.systemGray.cgColor
        view.roundCorners(cornerRadius: 10)
        view.isHidden = true
        return view
    }()
    
    @objc private func presentTutorialView() {
        tutorialView.isHidden = false
        dismissButton.isHidden = false
        if let videoURL = Bundle.main.url(forResource: "tutorial", withExtension: "mp4") {
            let player = AVPlayer(url: videoURL)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = tutorialView.bounds
            tutorialView.layer.addSublayer(playerLayer)
            player.play()
        }
    }
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(dismissTutorialView), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.isHidden = true
        return button
    }()
    
    @objc private func dismissTutorialView() {
        tutorialView.isHidden = true
        dismissButton.isHidden = true
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .white
        self.view.backgroundColor = .petpionIndigo
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItems = [trophyBarButton]
        viewModel.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        binding()
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
        layoutStartVoteLabel()
        layoutAppearCatView()
        layoutTutorialButton()
        layoutTutorialView()
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
            userHeartStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: yValueRatio(80)),
            userHeartStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: xValueRatio(-20)),
        ])
    }
    
    private func layoutRemainingTimeLabel() {
        view.addSubview(remainingTimeLabel)
        remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            remainingTimeLabel.topAnchor.constraint(equalTo: userHeartStackView.bottomAnchor, constant: yValueRatio(5)),
            remainingTimeLabel.trailingAnchor.constraint(equalTo: userHeartStackView.trailingAnchor, constant: xValueRatio(-3)),
            remainingTimeLabel.widthAnchor.constraint(equalToConstant: xValueRatio(60))
        ])
    }
    
    private func layoutHeartChargingImageView() {
        view.addSubview(heartChargingImageView)
        heartChargingImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heartChargingImageView.centerYAnchor.constraint(equalTo: remainingTimeLabel.centerYAnchor),
            heartChargingImageView.trailingAnchor.constraint(equalTo: remainingTimeLabel.leadingAnchor, constant: xValueRatio(-3)),
            heartChargingImageView.widthAnchor.constraint(equalToConstant: xValueRatio(25)),
            heartChargingImageView.heightAnchor.constraint(equalToConstant: yValueRatio(25))
        ])
    }
    
    private func layoutMainCommentLabel() {
        bottomSheetView.addSubview(mainCommentLabel)
        mainCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainCommentLabel.topAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: yValueRatio(20)),
            mainCommentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: xValueRatio(20)),
            mainCommentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: xValueRatio(-20))
        ])
    }
    
    private func layoutCatLoadingView() {
        bottomSheetView.addSubview(catLoadingView)
        catLoadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            catLoadingView.topAnchor.constraint(equalTo: mainCommentLabel.bottomAnchor, constant: yValueRatio(20)),
            catLoadingView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            catLoadingView.widthAnchor.constraint(equalToConstant: xValueRatio(300)),
            catLoadingView.heightAnchor.constraint(equalToConstant: xValueRatio(300))
        ])
        bottomSheetView.bringSubviewToFront(catLoadingView)
        catLoadingView.isHidden = true
    }
    
    private func layoutSleepingCatView() {
        bottomSheetView.addSubview(sleepingCatView)
        sleepingCatView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sleepingCatView.topAnchor.constraint(equalTo: mainCommentLabel.bottomAnchor, constant: yValueRatio(20)),
            sleepingCatView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            sleepingCatView.widthAnchor.constraint(equalToConstant: xValueRatio(300)),
            sleepingCatView.heightAnchor.constraint(equalToConstant: xValueRatio(300))
        ])
        bottomSheetView.bringSubviewToFront(sleepingCatView)
        sleepingCatView.isHidden = true
    }
    
    private func layoutStartVoteButton() {
        bottomSheetView.addSubview(startVoteButton)
        startVoteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startVoteButton.leadingAnchor.constraint(equalTo: bottomSheetView.leadingAnchor, constant: xValueRatio(20)),
            startVoteButton.trailingAnchor.constraint(equalTo: bottomSheetView.trailingAnchor, constant: xValueRatio(-20)),
            startVoteButton.bottomAnchor.constraint(equalTo: bottomSheetView.bottomAnchor, constant: yValueRatio(-70)),
            startVoteButton.heightAnchor.constraint(equalToConstant: yValueRatio(80))
        ])
        bottomSheetView.bringSubviewToFront(startVoteButton)
        startVoteButton.roundCorners(cornerRadius: xValueRatio(20))
    }
    
    private func layoutStartVoteLabel() {
        startVoteButton.addSubview(startVoteLabel)
        startVoteLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startVoteLabel.centerXAnchor.constraint(equalTo: startVoteButton.centerXAnchor),
            startVoteLabel.centerYAnchor.constraint(equalTo: startVoteButton.centerYAnchor)
        ])
        startVoteLabel.isHidden = true
    }
    
    private func layoutAppearCatView() {
        bottomSheetView.addSubview(appearCatView)
        appearCatView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appearCatView.centerXAnchor.constraint(equalTo: bottomSheetView.centerXAnchor),
            appearCatView.bottomAnchor.constraint(equalTo: startVoteButton.topAnchor),
            appearCatView.widthAnchor.constraint(equalToConstant: xValueRatio(300)),
            appearCatView.heightAnchor.constraint(equalToConstant: xValueRatio(300))
        ])
        appearCatView.isHidden = true
    }
    
    
    private func layoutTutorialButton() {
        view.addSubview(tutorialButton)
        tutorialButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tutorialButton.bottomAnchor.constraint(equalTo: bottomSheetView.topAnchor, constant: yValueRatio(-5)),
            tutorialButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: xValueRatio(20)),
            tutorialButton.widthAnchor.constraint(equalToConstant: xValueRatio(180)),
            tutorialButton.heightAnchor.constraint(equalToConstant: yValueRatio(60))
        ])
    }
    
    private func layoutTutorialView() {
        view.addSubview(tutorialView)
        tutorialView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tutorialView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tutorialView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tutorialView.widthAnchor.constraint(equalToConstant: xValueRatio(300)),
            tutorialView.heightAnchor.constraint(equalToConstant: yValueRatio(450))
        ])
        tutorialView.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismissButton.trailingAnchor.constraint(equalTo: tutorialView.trailingAnchor, constant: xValueRatio(-10)),
            dismissButton.topAnchor.constraint(equalTo: tutorialView.topAnchor, constant: xValueRatio(10))
        ])
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
            case .noneVotePare:
                self?.configureNoneVotePare()
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
        startVoteLabel.isHidden = true
    }
    
    private func configureReady() {
        catLoadingView.stop()
        catLoadingView.isHidden = true
        mainCommentLabel.text = "투표가 준비됐어요!\n당신의 펫피언에 투표해주세요 😆"
        startVoteButton.startAnimating()
        startVoteButton.isEnabled = true
        appearCatView.isHidden = false
        appearCatView.play()
        startVoteButton.bringSubviewToFront(startVoteLabel)
        startVoteLabel.isHidden = false
    }
    
    private func configureStart() {
        voteMainCoordinator?.pushVotePetpionViewController(with: viewModel.fetchedVotePare)
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
    }
    
    private func configureNoneVotePare() {
        mainCommentLabel.text = "준비된 펫들이 없어요.. 😢"
        startVoteButton.backgroundColor = .lightGray
        startVoteButton.stopAnimating()
        startVoteButton.isEnabled = false
        appearCatView.isHidden = true
        sleepingCatView.isHidden = true
        startVoteLabel.isHidden = true
        catLoadingView.isHidden = true
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
            imageView.widthAnchor.constraint(equalToConstant: xValueRatio(30)).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: xValueRatio(30)).isActive = true
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
