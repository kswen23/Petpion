//
//  File.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/24.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionDomain

final class InputProfileViewController: SettingCustomViewController {
    
    lazy var inputProfileCoordinator: NeedLoginCoordinator? = {
        return coordinator as? NeedLoginCoordinator
    }()
    
    private let viewModel: InputProfileViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let editProfileButton: EditProfileButton = {
        let profileButton = EditProfileButton(profileRadius: 60)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        return profileButton
    }()
    
    @objc private func editProfileButtonDidTapped() {
        inputProfileCoordinator?.presentProfileImagePickerViewController(parentableViewController: self)
    }
    
    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.text = "이메일"
        label.sizeToFit()
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.autocorrectionType = .no
        textField.backgroundColor = .petpionLightGray
        textField.layer.borderWidth = 0.3
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.roundCorners(cornerRadius: 15)
        textField.font = .systemFont(ofSize: 15)
        textField.placeholder = "이메일을 설정해 주세요."
        textField.textColor = .black
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.clearButtonMode = .always
        textField.addLeftPadding()
        return textField
    }()
    
    private let emailResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.text = "이메일은 한번 설정하면 변경할수 없으니 신중히 입력해주세요."
        label.textAlignment = .right
        label.sizeToFit()
        return label
    }()
    
    private lazy var emailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        [emailTitleLabel, emailTextField, emailResultLabel].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private let nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.text = "닉네임"
        label.sizeToFit()
        return label
    }()
    
    private lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.autocorrectionType = .no
        textField.backgroundColor = .petpionLightGray
        textField.layer.borderWidth = 0.3
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.roundCorners(cornerRadius: 15)
        textField.font = .systemFont(ofSize: 15)
        textField.placeholder = "닉네임을 설정해 주세요."
        textField.textColor = .black
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.clearButtonMode = .always
        textField.addLeftPadding()
        return textField
    }()
    
    private let nicknameResultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.text = "3~10자 사이의 영문, 한글, 숫자, _ 특수문자만 가능합니다."
        label.textAlignment = .right
        label.sizeToFit()
        return label
    }()
    
    private lazy var nicknameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        [nicknameTitleLabel, nicknameTextField, nicknameResultLabel].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private lazy var doneRightBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonDidTapped))
        barButton.tintColor = .lightGray
        barButton.isEnabled = false
        return barButton
    }()
    
    private lazy var indicatorBarButton: UIBarButtonItem = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
        return UIBarButtonItem(customView: indicatorView)
    }()
    
    @objc private func doneButtonDidTapped() {
        guard let email = emailTextField.text,
              let nickname = nicknameTextField.text else { return }
        viewModel.checkUserNicknameDuplication(email: email, nickname: nickname)
    }
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    let textFieldWidth: CGFloat = UIScreen.main.bounds.size.width * 0.9
    
    // MARK: - Initialize
    init(viewModel: InputProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "프로필 입력"
        self.navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = doneRightBarButton
        view.backgroundColor = .white
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(tapGesture)
        layout()
        binding()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutEditProfileButton()
        layoutEmailStackView()
        layoutNicknameStackView()
    }
    
    private func layoutEditProfileButton() {
        view.addSubview(editProfileButton)
        NSLayoutConstraint.activate([
            editProfileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editProfileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
        ])
        editProfileButton.addTarget(self, action: #selector(editProfileButtonDidTapped), for: .touchUpInside)
    }
    
    private func layoutEmailStackView() {
        view.addSubview(emailStackView)
        NSLayoutConstraint.activate([
            emailStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailStackView.topAnchor.constraint(equalTo: editProfileButton.bottomAnchor, constant: 70),
            emailStackView.widthAnchor.constraint(equalToConstant: textFieldWidth)
        ])
        emailTextField.delegate = self
    }
    
    private func layoutNicknameStackView() {
        view.addSubview(nicknameStackView)
        NSLayoutConstraint.activate([
            nicknameStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameStackView.topAnchor.constraint(equalTo: emailStackView.bottomAnchor, constant: 20),
            nicknameStackView.widthAnchor.constraint(equalToConstant: textFieldWidth)
        ])
        nicknameTextField.delegate = self
    }
    
    // MARK: - Binding
    private func binding() {
        bindEditProfileViewStateSubject()
    }
    
    private func bindEditProfileViewStateSubject() {
        viewModel.inputProfileViewStateSubject.sink { [weak self] viewState in
            guard let strongSelf = self else { return }
            switch viewState {
            case .startLoading:
                self?.navigationItem.rightBarButtonItem = strongSelf.indicatorBarButton
            case .duplicatedEmail:
                self?.navigationItem.rightBarButtonItem = strongSelf.doneRightBarButton
                self?.configureDuplicatedEmail()
            case .duplicatedNickname:
                self?.navigationItem.rightBarButtonItem = strongSelf.doneRightBarButton
                self?.configureDuplicatedNickName()
            case .duplicatedEmailNickname:
                self?.navigationItem.rightBarButtonItem = strongSelf.doneRightBarButton
                self?.configureDuplicatedEmail()
                self?.configureDuplicatedNickName()
            case .startUpdating:
                self?.viewModel.signIn()
            case .finishUpdating:
                self?.inputProfileCoordinator?.restart()
            case .error:
                self?.navigationItem.rightBarButtonItem = strongSelf.doneRightBarButton
                self?.configureUpdatingError()
            }
        }.store(in: &cancellables)
    }
    
    // MARK: - Configure
    private func configureEmailResultLabel() {
        guard let emailText = emailTextField.text else { return }
        if emailText.count == 0 {
            emailResultLabel.text = "이메일은 한번 설정하면 변경할수 없으니 신중히 입력해주세요."
        } else if viewModel.checkEmailValidate(email: emailText) == true {
            emailResultLabel.text = " "
        } else {
            nicknameResultLabel.textColor = .lightGray
            emailResultLabel.text = "유효하지 않은 이메일 주소입니다."
        }
    }
    
    private func configureDuplicatedEmail() {
        emailResultLabel.textColor = .systemRed
        emailResultLabel.text = "중복된 이메일입니다."
    }
    
    private func configureNicknameResultLabel() {
        guard let nicknameText = nicknameTextField.text else { return }
        if viewModel.checkNickNameValidate(nickname: nicknameText) == true {
            nicknameResultLabel.text = ""
        } else {
            nicknameResultLabel.textColor = .lightGray
            nicknameResultLabel.text = "3~10자 사이의 영문, 한글, 숫자, _ 특수문자만 가능합니다."
        }
    }
    
    private func configureDuplicatedNickName() {
        nicknameResultLabel.textColor = .systemRed
        nicknameResultLabel.text = "중복된 닉네임입니다."
    }
    
    private func configureUpdatingError() {
        emailResultLabel.textColor = .systemRed
        emailResultLabel.text = "업데이트 에러입니다."
        nicknameResultLabel.textColor = .systemRed
        nicknameResultLabel.text = "업데이트 에러입니다."
    }
    
    private func configureDoneBarButton(isEnabled: Bool) {
        if isEnabled {
            doneRightBarButton.tintColor = .systemBlue
            doneRightBarButton.isEnabled = true
        } else {
            doneRightBarButton.tintColor = .systemGray
            doneRightBarButton.isEnabled = false
        }
    }
}

extension InputProfileViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nicknameTextField {
            let maxLength = 11
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            let maxLength = 30
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            emailTitleLabel.textColor = .systemBlue
            nicknameTitleLabel.textColor = .lightGray
        } else if textField == nicknameTextField {
            emailTitleLabel.textColor = .lightGray
            nicknameTitleLabel.textColor = .systemBlue
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let emailText = emailTextField.text,
              let nicknameText = nicknameTextField.text
        else { return }
        if textField == emailTextField {
            configureEmailResultLabel()
        } else if textField == nicknameTextField {
            configureNicknameResultLabel()
        }
        
        let emailValidation =  viewModel.checkEmailValidate(email: emailText)
        let nicknameValidation = viewModel.checkNickNameValidate(nickname: nicknameText)
        
        if emailValidation && nicknameValidation == true {
            configureDoneBarButton(isEnabled: true)
        } else {
            configureDoneBarButton(isEnabled: false)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        nicknameTitleLabel.textColor = .lightGray
    }
}

extension InputProfileViewController: ProfileImagePickerViewControllerDelegate {
    
    func profileImageDidChanged(_ image: UIImage?) {
        configureDoneBarButton(isEnabled: true)
        guard let profileImage = image else { return }
        editProfileButton.configureProfileImage(with: profileImage)
        viewModel.changeCurrentProfileImage(profileImage)
    }
}
