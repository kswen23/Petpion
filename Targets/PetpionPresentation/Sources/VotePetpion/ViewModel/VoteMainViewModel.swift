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
}

protocol VoteMainViewModelOutput {
    var fetchedVotePare: [PetpionVotePare] { get }
    func fetchChanceCreationRemainingTime()
}

protocol VoteMainViewModelProtocol: VoteMainViewModelInput, VoteMainViewModelOutput {
    var calculateVoteChanceUseCase: CalculateVoteChanceUseCase { get }
    var voteMainStateSubject: CurrentValueSubject<VoteMainState, Never> { get }
    var heartSubject: CurrentValueSubject<[HeartType], Never> { get }
    var remainingTimeSubject: CurrentValueSubject<TimeInterval, Never> { get }
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
    
    lazy var voteMainStateSubject: CurrentValueSubject<VoteMainState, Never> = .init(getCurrentState())
    lazy var heartSubject: CurrentValueSubject<[HeartType], Never> = .init(fetchUserVoteChance())
    lazy var remainingTimeSubject: CurrentValueSubject<TimeInterval, Never> = .init(calculateVoteChanceUseCase.getChanceCreationTimeRemaining())
    var maxTimeInterval: TimeInterval = .infinity
    
    lazy var fetchedVotePare: [PetpionVotePare] = .init()
    // MARK: - Initialize
    init(calculateVoteChanceUseCase: CalculateVoteChanceUseCase,
         makeVoteListUseCase: MakeVoteListUseCase,
         fetchFeedUseCase: FetchFeedUseCase) {
        self.calculateVoteChanceUseCase = calculateVoteChanceUseCase
        self.makeVoteListUseCase = makeVoteListUseCase
        self.fetchFeedUseCase = fetchFeedUseCase
    }
    
    // MARK: - Input
    func startFetchingVotePareArray() {
        Task {
            let petpionVotePareArr = await makeVoteListUseCase.fetchVoteList(pare: 10)
            fetchedVotePare = await prefetchAllPareDetailImage(origin: petpionVotePareArr)
            print(fetchedVotePare)
            if fetchedVotePare.isEmpty == false {
                await MainActor.run {
                    voteMainStateSubject.send(.ready)
                }
            }
            
        }
    }
    
    func startVoting() {
        // 서버에 하트 -1, 시간 재등록 -> 하트 -1 후 push~
        voteMainStateSubject.send(.start)
    }
    // MARK: - Output
    func fetchChanceCreationRemainingTime() {
        if calculateVoteChanceUseCase.getVoteChance() == User.voteMaxCountPolicy {
            self.remainingTimeSubject.send(maxTimeInterval)
        } else {
            var restTimeInterval = calculateVoteChanceUseCase.getChanceCreationTimeRemaining()
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                restTimeInterval = restTimeInterval - 1
                if restTimeInterval < 1 {
                    restTimeInterval = 3600
                }
                self?.remainingTimeSubject.send(restTimeInterval)
            }
        }
    }
    // MARK: - Private
    private func fetchUserVoteChance() -> [HeartType] {
        var resultHeartArr = [HeartType].init(repeating: .fill, count: User.voteMaxCountPolicy)
        let emptyCount = User.voteMaxCountPolicy - calculateVoteChanceUseCase.getVoteChance()
        for i in 0 ..< emptyCount {
            resultHeartArr[i] = .empty
        }
        return resultHeartArr
    }
    
    private func getCurrentState() -> VoteMainState {
        let availableChance = calculateVoteChanceUseCase.getVoteChance()
        if availableChance == 0 {
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
