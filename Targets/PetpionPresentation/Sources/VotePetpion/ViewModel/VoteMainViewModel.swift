//
//  VoteMainViewModel.swift
//  PetpionDomain
//
//  Created by 김성원 on 2023/01/06.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation

import PetpionDomain

protocol VoteMainViewModelInput {
    func startFetchingVotePareArray()
    func startVoting()
    func synchronizeWithServer1()
}

protocol VoteMainViewModelOutput {
    var fetchedVotePare: [PetpionVotePare] { get }
}

protocol VoteMainViewModelProtocol: VoteMainViewModelInput, VoteMainViewModelOutput {
    var calculateVoteChanceUseCase: CalculateVoteChanceUseCase { get }
    var voteMainStateSubject: PassthroughSubject<VoteMainState, Never> { get }
    var heartSubject: PassthroughSubject<[HeartType], Never> { get }
    var remainingTimeSubject: PassthroughSubject<TimeInterval, Never> { get }
    var maxTimeInterval: TimeInterval { get }
    
}

enum HeartType: String {
    case fill = "heart.fill"
    case empty = "heart"
}

enum VoteMainState {
    case disable
    case preparing
    case ready
    case start
}

final class VoteMainViewModel: VoteMainViewModelProtocol {

    let calculateVoteChanceUseCase: CalculateVoteChanceUseCase
    let makeVoteListUseCase: MakeVoteListUseCase
    let fetchFeedUseCase: FetchFeedUseCase
    let uploadUserUseCase: UploadUserUseCase
    
    lazy var voteMainStateSubject: PassthroughSubject<VoteMainState, Never> = .init()
    lazy var heartSubject: PassthroughSubject<[HeartType], Never> = .init()
    lazy var remainingTimeSubject: PassthroughSubject<TimeInterval, Never> = .init()
    var currentHeart: Int?
    var maxTimeInterval: TimeInterval = .infinity
    private var isFirstFetching: Bool = true
    lazy var fetchedVotePare: [PetpionVotePare] = .init()
    
    // MARK: - Initialize
    init(calculateVoteChanceUseCase: CalculateVoteChanceUseCase,
         makeVoteListUseCase: MakeVoteListUseCase,
         fetchFeedUseCase: FetchFeedUseCase,
         uploadUserUseCase: UploadUserUseCase) {
        self.calculateVoteChanceUseCase = calculateVoteChanceUseCase
        self.makeVoteListUseCase = makeVoteListUseCase
        self.fetchFeedUseCase = fetchFeedUseCase
        self.uploadUserUseCase = uploadUserUseCase
        synchronizeWithServer()
    }
    
    private func synchronizeWithServer() {
        calculateVoteChanceUseCase.bindUser { voteChance, remainingTimeInterval in
            self.currentHeart = voteChance
            self.sendMainState(voteChance: voteChance)
            self.sendHeart(voteChance: voteChance)
            self.sendRemainingTime(voteChance: voteChance, timeInterval: remainingTimeInterval)
        }
    }
    
    // MARK: - Input
    public func synchronizeWithServer1() {
        calculateVoteChanceUseCase.bindUser { [weak self] voteChance, chanceRemainingTime in
            guard let strongSelf = self else { return }
            if strongSelf.isFirstFetching {
                self?.uploadUserUseCase.updateVoteChanceCount(voteChance)
                self?.isFirstFetching = false
            }
            self?.currentHeart = voteChance
            self?.sendMainState(voteChance: voteChance)
            self?.sendHeart(voteChance: voteChance)
            self?.sendRemainingTime(voteChance: voteChance, timeInterval: chanceRemainingTime)
        }
    }
    
    func startFetchingVotePareArray() {
        Task {
            let petpionVotePareArr = await makeVoteListUseCase.fetchVoteList(pare: 10)
            fetchedVotePare = await prefetchAllPareDetailImage(origin: petpionVotePareArr)
            
            if fetchedVotePare.isEmpty == false {
                await MainActor.run {
                    voteMainStateSubject.send(.ready)
                }
            }
            
        }
    }
    
    func startVoting() {
        guard let currentHeart = currentHeart else { return }
        if currentHeart - 1 == User.voteMaxCountPolicy - 1 {
            uploadUserUseCase.updateLatestVoteTime()
        }
        // 서버에 하트 -1, 시간 재등록 -> 하트 -1 후 push~
        uploadUserUseCase.minusUserVoteChance()
        voteMainStateSubject.send(.start)
    }
    // MARK: - Output
    
    // MARK: - Private
    private func sendMainState(voteChance: Int) {
        voteMainStateSubject.send(getCurrentState(with: voteChance))
    }
    
    private func sendHeart(voteChance: Int) {
        heartSubject.send(getUserVoteChance(with: voteChance))
    }
    
    private func sendRemainingTime(voteChance: Int, timeInterval: TimeInterval) {
        if voteChance == User.voteMaxCountPolicy {
            remainingTimeSubject.send(maxTimeInterval)
        } else {
            var restTimeInterval = timeInterval
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                restTimeInterval = restTimeInterval - 1
                if restTimeInterval < 1 {
                    restTimeInterval = 3600
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
    
    private func getCurrentState(with available: Int) -> VoteMainState {
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
}
