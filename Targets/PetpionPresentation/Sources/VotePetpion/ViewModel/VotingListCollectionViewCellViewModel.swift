//
//  VotingListCollectionViewCellViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/01/02.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation
import UIKit

import PetpionDomain

protocol VotingListCollectionViewCellViewModelInput {
    
}

protocol VotingListCollectionViewCellViewModelOutput {
    
}

protocol VotingListCollectionViewCellViewModelProtocol: VotingListCollectionViewCellViewModelInput, VotingListCollectionViewCellViewModelOutput {
    var votePare: PetpionVotePare { get }
    var topImageIndex: CurrentValueSubject<Int, Never> { get }
    var bottomImageIndex: CurrentValueSubject<Int, Never> { get }
}

final class VotingListCollectionViewCellViewModel: VotingListCollectionViewCellViewModelProtocol {
    
    var topImageIndex: CurrentValueSubject<Int, Never> = .init(1)
    var bottomImageIndex: CurrentValueSubject<Int, Never> = .init(1)
    
    // MARK: - Initialize
    let votePare: PetpionVotePare
    
    init(votePare: PetpionVotePare) {
        self.votePare = votePare
    }
    
}
