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
    
}

protocol VoteMainViewModelOutput {
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
    var voteMainStateSubject: CurrentValueSubject<VoteMainState, Never> = .init(.preparing)
    lazy var heartSubject: CurrentValueSubject<[HeartType], Never> = .init(fetchUserVoteChance())
    lazy var remainingTimeSubject: CurrentValueSubject<TimeInterval, Never> = .init(calculateVoteChanceUseCase.getChanceCreationTimeRemaining())
    var maxTimeInterval: TimeInterval = .infinity
    
    // MARK: - Initialize
    init(calculateVoteChanceUseCase: CalculateVoteChanceUseCase) {
        self.calculateVoteChanceUseCase = calculateVoteChanceUseCase
    }
    
    // MARK: - Input
    
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
}
