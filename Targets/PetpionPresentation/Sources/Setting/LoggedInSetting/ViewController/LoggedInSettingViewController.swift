//
//  LoggedInSettingViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/30.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import MessageUI
import UIKit

import PetpionCore
import PetpionDomain

final class LoggedInSettingViewController: SettingCustomViewController {
    
    lazy var loggedInSettingCoordinator: SettingCoordinator? = {
        return coordinator as? SettingCoordinator
    }()
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: LoggedInSettingViewModelProtocol
    
    private lazy var logOutAlertController: UIAlertController = {
        let alert = UIAlertController(title: "정말 로그아웃하시겠습니까?", message: nil, preferredStyle: .alert)
        return alert
    }()
    
    private lazy var baseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var baseContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var settingCategoryStackViewArray: [SettingCategoryStackView] = SettingModel.SettingCategory.allCases.map { SettingCategoryStackView(category: $0) }
    
    private lazy var profileSettingView: SettingProfileView = .init()
    
    private lazy var settingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        settingCategoryStackViewArray.forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private lazy var appVersionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        label.text = "앱 버전: 1.0.0"
        label.sizeToFit()
        return label
    }()
    
    // MARK: - Initialize
    init(viewModel: LoggedInSettingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "설정"
        configureProfileSettingView(with: viewModel.user)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configureLogoutAlertController()
        settingCategoryStackViewArray.forEach { $0.settingCategoryStackViewListener = self }
        bindLogoutResult()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutBaseScrollView()
        layoutProfileSettingView()
        layoutStackview()
        layoutAppVersionLabel()
    }
    
    private func layoutBaseScrollView() {
        view.addSubview(baseScrollView)
        baseScrollView.addSubview(baseContentView)
        baseScrollView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        baseScrollView.contentInsetAdjustmentBehavior = .never
        NSLayoutConstraint.activate([
            baseScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            baseScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            baseContentView.topAnchor.constraint(equalTo: baseScrollView.topAnchor),
            baseContentView.bottomAnchor.constraint(equalTo: baseScrollView.bottomAnchor),
            baseContentView.leadingAnchor.constraint(equalTo: baseScrollView.leadingAnchor),
            baseContentView.trailingAnchor.constraint(equalTo: baseScrollView.trailingAnchor),
            baseContentView.widthAnchor.constraint(equalTo: baseScrollView.widthAnchor),
            baseContentView.heightAnchor.constraint(equalTo: baseScrollView.heightAnchor)
        ])
    }
    
    private func layoutProfileSettingView() {
        baseContentView.addSubview(profileSettingView)
        profileSettingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileSettingView.leadingAnchor.constraint(equalTo: baseContentView.leadingAnchor),
            profileSettingView.trailingAnchor.constraint(equalTo: baseContentView.trailingAnchor),
            profileSettingView.topAnchor.constraint(equalTo: baseContentView.topAnchor),
            profileSettingView.heightAnchor.constraint(equalToConstant: 100)
        ])
        profileSettingView.settingProfileViewListener = self
    }
    
    private func layoutStackview() {
        baseContentView.addSubview(settingStackView)
        settingStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingStackView.leadingAnchor.constraint(equalTo: baseContentView.leadingAnchor),
            settingStackView.trailingAnchor.constraint(equalTo: baseContentView.trailingAnchor),
            settingStackView.topAnchor.constraint(equalTo: profileSettingView.bottomAnchor, constant: 10)
        ])
    }
    
    private func layoutAppVersionLabel() {
        baseContentView.addSubview(appVersionLabel)
        appVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appVersionLabel.bottomAnchor.constraint(equalTo: baseContentView.bottomAnchor, constant: yValueRatio(-30)),
            appVersionLabel.centerXAnchor.constraint(equalTo: baseContentView.centerXAnchor)
        ])
    }
    
    // MARK: - Configure
    private func configureProfileSettingView(with user: User) {
        profileSettingView.configureSettingProfileView(with: user)
    }
    
    private func configureLogoutAlertController() {
        let yes = UIAlertAction(title: "네", style: .default) { [weak self] _ in
            self?.viewModel.logoutDidTapped()
        }
        let no = UIAlertAction(title: "아니오", style: .default)
        [yes, no].forEach { logOutAlertController.addAction($0) }
    }
    
    private func bindLogoutResult() {
        viewModel.logoutResultSubject.sink { [weak self] isLogout in
            if isLogout {
                self?.dismiss(animated: true)
                self?.loggedInSettingCoordinator?.restart()
            } else {
                self?.dismiss(animated: true)
            }
        }.store(in: &cancellables)
    }
}

extension LoggedInSettingViewController: SettingCategoryStackViewDelegate, SettingProfileViewDelegate, MFMailComposeViewControllerDelegate {
    
    // SettingCategoryDelegate
    func settingActionViewDidTapped(action: SettingModel.SettingAction) {
        if action == .logout {
            self.present(logOutAlertController, animated: true)
        } else if action == .inquire {
            self.presentEmailViewController()
        } else {
            loggedInSettingCoordinator?.startSettingActionScene(with: action)
        }
    }
    
    private func presentEmailViewController() {
        if MFMailComposeViewController.canSendMail() {
               let composeViewController = MFMailComposeViewController()
               composeViewController.mailComposeDelegate = self
               
               let bodyString = """
                
                
                -------------------
                Device Model : \(self.getDeviceIdentifier())
                Device OS : \(UIDevice.current.systemVersion)
                App Version : \(self.getCurrentVersion())
                """
               
               composeViewController.setToRecipients(["kswen0203@icloud.com"])
               composeViewController.setSubject("Petpion에 문의하기")
               composeViewController.setMessageBody(bodyString, isHTML: false)
               
               self.present(composeViewController, animated: true, completion: nil)
           } else {
               print("메일 보내기 실패")
               let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "메일을 보내려면 'Mail' 앱이 필요합니다. App Store에서 해당 앱을 복원하거나 이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
               let goAppStoreAction = UIAlertAction(title: "App Store로 이동하기", style: .default) { _ in
                   // 앱스토어로 이동하기(Mail)
//                   if let url = URL(string: "https://apps.apple.com/kr/app/mail/id1108187098"), UIApplication.shared.canOpenURL(url) {
//                       if #available(iOS 10.0, *) {
//                           UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                       } else {
//                           UIApplication.shared.openURL(url)
//                       }
//                   }
               }
               
               let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
               
               sendMailErrorAlert.addAction(goAppStoreAction)
               sendMailErrorAlert.addAction(cancelAction)
               self.present(sendMailErrorAlert, animated: true, completion: nil)
           }
    }
    
    func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }

    // 현재 버전 가져오기
    func getCurrentVersion() -> String {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else { return "" }
        return version
    }
    
    // SettingProfileDelegate
    func profileViewDidTapped() {
        loggedInSettingCoordinator?.startSettingActionScene(with: .profile)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension LoggedInSettingViewController: NotificationObservable {
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserProfileDidChange), name: Notification.Name(NotificationName.profileUpdated), object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName.profileUpdated), object: nil)
    }
    
    @objc func handleUserProfileDidChange(notification: Notification) {
        guard let updatedUserProfile = notification.userInfo?["profile"] as? User else { return }
        viewModel.userDidUpdated(to: updatedUserProfile)
        configureProfileSettingView(with: updatedUserProfile)
    }
    
}
