//
//  VoteMainViewModel.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/06.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation

import PetpionCore
import PetpionDomain

protocol VoteMainViewModelInput {
    func startVoting()
    func viewWillAppear()
    func viewWillDisappear()
}

protocol VoteMainViewModelOutput {
    func synchronizeWithServer()
    func startFetchingVotePareArray()
    var fetchedVotePare: [PetpionVotePare] { get }
}

protocol VoteMainViewModelProtocol: VoteMainViewModelInput, VoteMainViewModelOutput {
    var calculateVoteChanceUseCase: CalculateVoteChanceUseCase { get }
    var makeVoteListUseCase: MakeVoteListUseCase { get }
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var fetchUserUseCase: FetchUserUseCase { get }
    var uploadUserUseCase: UploadUserUseCase { get }
    var makeNotificationUseCase: MakeNotificationUseCase { get }
    var user: User { get }
    var voteMainViewControllerStateSubject: PassthroughSubject<VoteMainViewControllerState, Never> { get }
    var heartSubject: CurrentValueSubject<[HeartType], Never> { get }
    var remainingTimeSubject: CurrentValueSubject<TimeInterval, Never> { get }
    var maxTimeInterval: TimeInterval { get }
    
}

enum HeartType: String {
    case fill = "heart.fill"
    case empty = "heart"
}

enum VoteMainViewControllerState {
    case disable
    case preparing
    case ready
    case start
    case noneVotePare
}

final class VoteMainViewModel: VoteMainViewModelProtocol {
    
    let calculateVoteChanceUseCase: CalculateVoteChanceUseCase
    let makeVoteListUseCase: MakeVoteListUseCase
    let fetchFeedUseCase: FetchFeedUseCase
    let fetchUserUseCase: FetchUserUseCase
    let uploadUserUseCase: UploadUserUseCase
    let makeNotificationUseCase: MakeNotificationUseCase
    var user: User
    
    var voteMainViewControllerStateSubject: PassthroughSubject<VoteMainViewControllerState, Never> = .init()
    lazy var heartSubject: CurrentValueSubject<[HeartType], Never> = .init(getUserVoteChance(with: user.voteChanceCount))
    lazy var remainingTimeSubject: CurrentValueSubject<TimeInterval, Never> = .init(calculateVoteChanceUseCase.getRemainingTimeIntervalToCreateVoteChance(latestVoteTime: user.latestVoteTime))
    var maxTimeInterval: TimeInterval = .infinity
    private var isFirstFetching: Bool = true
    lazy var fetchedVotePare: [PetpionVotePare] = .init()
    private var currentTimer: Timer?
    private var viewWillDisappeared: Bool = false
    
    private var fetchingVotePareTask: Task<Void, Never>?
    
    // MARK: - Initialize
    init(calculateVoteChanceUseCase: CalculateVoteChanceUseCase,
         makeVoteListUseCase: MakeVoteListUseCase,
         fetchFeedUseCase: FetchFeedUseCase,
         fetchUserUseCase: FetchUserUseCase,
         uploadUserUseCase: UploadUserUseCase,
         makeNotificationUseCase: MakeNotificationUseCase,
         user: User) {
        self.calculateVoteChanceUseCase = calculateVoteChanceUseCase
        self.makeVoteListUseCase = makeVoteListUseCase
        self.fetchFeedUseCase = fetchFeedUseCase
        self.fetchUserUseCase = fetchUserUseCase
        self.uploadUserUseCase = uploadUserUseCase
        self.makeNotificationUseCase = makeNotificationUseCase
        self.user = user
        requestNotification()
        synchronizeWithServer()
    }
    
    deinit {
        invalidateCurrentTimer()
    }
    
    private func requestNotification() {
        if UserDefaults.standard.bool(forKey: UserInfoKey.userNotificationsPermission.rawValue) == false {
            makeNotificationUseCase.requestAuthorization()
        }
    }
    
    // MARK: - Input
    func startVoting() {
        viewWillDisappeared = true
        if user.voteChanceCount - 1 == User.voteMaxCountPolicy - 1 {
            uploadUserUseCase.updateLatestVoteTime()
            makeNotificationUseCase.createPetpionVoteNotification(heart: user.voteChanceCount-1,
                                                                  latestVoteTime: .init())
        } else {
            makeNotificationUseCase.createPetpionVoteNotification(heart: user.voteChanceCount-1,
                                                                  latestVoteTime: user.latestVoteTime)
        }
        uploadUserUseCase.minusUserVoteChance()
        voteMainViewControllerStateSubject.send(.start)
    }
    
    func viewWillAppear() {
        viewWillDisappeared = false
        voteMainViewControllerStateSubject.send(getCurrentState(with: user.voteChanceCount))
    }
    
    func viewWillDisappear() {
        fetchingVotePareTask?.cancel()
    }
    
    // MARK: - Output
    public func synchronizeWithServer() {
        fetchUserUseCase.bindUser { [weak self] user in
            guard let chanceRemainingTime = self?.calculateVoteChanceUseCase.getRemainingTimeIntervalToCreateVoteChance(latestVoteTime: user.latestVoteTime) else { return }
            self?.user = user
            self?.sendHeart(voteChance: user.voteChanceCount)
            self?.sendRemainingTime(voteChance: user.voteChanceCount,
                                    timeInterval: chanceRemainingTime)
        }
    }
    
    func startFetchingVotePareArray() {
        fetchingVotePareTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            
            let petpionVotePareArr = await makeVoteListUseCase.fetchVoteList(pare: 10, parentsTask: fetchingVotePareTask!)
            
            fetchedVotePare = await prefetchAllPareDetailImage(origin: petpionVotePareArr)
            
            await MainActor.run { [fetchedVotePare] in
                if fetchedVotePare.isEmpty {
                    self.voteMainViewControllerStateSubject.send(.noneVotePare)
                } else {
                    self.voteMainViewControllerStateSubject.send(.ready)
                }
            }
        }
    }
    
    // MARK: - Private
    private func sendMainState(voteChance: Int) {
        voteMainViewControllerStateSubject.send(getCurrentState(with: voteChance))
    }
    
    private func sendHeart(voteChance: Int) {
        heartSubject.send(getUserVoteChance(with: voteChance))
    }
    
    private func sendRemainingTime(voteChance: Int, timeInterval: TimeInterval) {
        invalidateCurrentTimer()
        
        if voteChance == User.voteMaxCountPolicy {
            remainingTimeSubject.send(maxTimeInterval)
        } else {
            var restTimeInterval = timeInterval
            currentTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                restTimeInterval = restTimeInterval - 1
                if restTimeInterval < 1 {
                    restTimeInterval = 3600
                    self?.uploadUserUseCase.plusUserVoteChance()
                    self?.voteMainViewControllerStateSubject.send(.preparing)
                    timer.invalidate()
                }
                self?.remainingTimeSubject.send(restTimeInterval)
            }
        }
    }
    
    private func getUserVoteChance(with available: Int) -> [HeartType] {
        var resultHeartArr = [HeartType].init(repeating: .fill, count: User.voteMaxCountPolicy)
        let emptyCount = User.voteMaxCountPolicy - available
        for i in 0 ..< emptyCount {
            resultHeartArr[i] = .empty
        }
        return resultHeartArr
    }
    
    private func getCurrentState(with available: Int) -> VoteMainViewControllerState {
        if available == 0 {
            return .disable
        } else {
            return .preparing
        }
    }
    
    private func prefetchAllPareDetailImage(origin: [PetpionVotePare]) async -> [PetpionVotePare] {
        var resultArr = [PetpionVotePare]()
        for pare in origin {
            resultArr.append(await fetchFeedUseCase.fetchVotePareDetailImages(pare: pare))
        }
        return resultArr
    }
    
    private func invalidateCurrentTimer() {
        if let currentTimer = currentTimer {
            currentTimer.invalidate()
        }
    }
}
