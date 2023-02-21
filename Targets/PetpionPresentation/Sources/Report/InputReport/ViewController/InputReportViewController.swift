//
//  InputReportViewController.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/20.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

final class InputReportViewController: HasCoordinatorViewController {
    
    lazy var reportCoordinator: ReportCoordinator? = {
        self.coordinator as? ReportCoordinator
    }()
    
    let viewModel: InputReportViewModelProtocol
    private var cancelables = Set<AnyCancellable>()
    
    private lazy var reportBarButton: UIBarButtonItem = {
        let reportButton = UIBarButtonItem(title: "신고", style: .plain, target: self, action: #selector(reportButtonDidTapped))
        reportButton.tintColor = .black
        reportButton.isEnabled = false
        return reportButton
    }()
    
    @objc private func reportButtonDidTapped() {
        guard let description = textView.text else { return }
        viewModel.report(description: description)
    }
    
    private lazy var indicatorBarButton: UIBarButtonItem = {
        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
        return UIBarButtonItem(customView: indicatorView)
    }()
    
    private let backgroundTextView: UIView = UIView()
    private let textView: UITextView = UITextView()
    
    // MARK: - Initialize
    init(viewModel: InputReportViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = reportBarButton
        self.navigationItem.title = "기타 (직접 입력)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutTextView()
        configureTextView()
        bindInputReportViewState()
    }
 
    private func layoutTextView() {
        view.addSubview(backgroundTextView)
        backgroundTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            backgroundTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            backgroundTextView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        backgroundTextView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: backgroundTextView.topAnchor, constant: 5),
            textView.leadingAnchor.constraint(equalTo: backgroundTextView.leadingAnchor, constant: 5),
            textView.trailingAnchor.constraint(equalTo: backgroundTextView.trailingAnchor, constant: -5),
            textView.bottomAnchor.constraint(equalTo: backgroundTextView.bottomAnchor, constant: -5)
        ])
    }
    
    private func configureTextView() {
        backgroundTextView.backgroundColor = .white
        backgroundTextView.layer.borderWidth = 1.0
        backgroundTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        backgroundTextView.roundCorners(cornerRadius: 15)
        textView.font = .systemFont(ofSize: 15)
        textView.text = viewModel.textViewPlaceHolder
        textView.textColor = .lightGray
        textView.delegate = self
    }
    
    private func bindInputReportViewState() {
        viewModel.inputReportViewStateSubject.sink { [weak self] viewState in
            guard let strongSelf = self else { return }
            switch viewState {
                
            case .startReporting:
                self?.navigationItem.rightBarButtonItem = strongSelf.indicatorBarButton
            case .done:
                self?.reportCoordinator?.pushReportCompletedView()
            case .error:
                return
            }
        }.store(in: &cancelables)
    }
}
extension InputReportViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == viewModel.textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = viewModel.textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            reportBarButton.tintColor = .lightGray
            reportBarButton.isEnabled = false
        } else {
            reportBarButton.tintColor = .black
            reportBarButton.isEnabled = true   
        }
    }
}
