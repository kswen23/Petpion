//
//  PetpionHallViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/27.
//  Copyright © 2023 Petpion. All rights reserved.
//

import Combine
import Foundation

import PetpionDomain

protocol PetpionHallViewModelInput {
    func fetchTopFeed()
    func scrollViewDidScrolled(section: Int, index: Int)
}

protocol PetpionHallViewModelOutput {
    var indexArray: [Int] { get }
}

protocol PetpionHallViewModelProtocol: PetpionHallViewModelInput, PetpionHallViewModelOutput {
    var fetchFeedUseCase: FetchFeedUseCase { get }
    var topPetpionFeedArraySubject: CurrentValueSubject<[TopPetpionFeed], Never> { get }
}

final class PetpionHallViewModel: PetpionHallViewModelProtocol {
    
    let fetchFeedUseCase: FetchFeedUseCase
    let topPetpionFeedArraySubject: CurrentValueSubject<[TopPetpionFeed], Never> = .init([])
    private var dateCursor: Date = .init()
    lazy var indexArray: [Int] = .init()
    
    // MARK: - Initialize
    init(fetchFeedUseCase: FetchFeedUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
        fetchTopFeed()
    }
    
    // MARK: - Input
    func fetchTopFeed() {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 2023
        dateComponents.month = 1
        dateComponents.day = 1
        guard let startingDate = calendar.date(from: dateComponents) else { return }
        guard dateCursor >= startingDate else { return }
        Task {
            let topFeeds = await fetchFeedUseCase.fetchTopPetpionFeedForLast3Months(since: dateCursor)
            
            guard let last = topFeeds.last else { return }
            dateCursor = last.date
            await MainActor.run {
                indexArray = indexArray + .init(repeating: 0, count: topFeeds.count)
                topPetpionFeedArraySubject.send(topPetpionFeedArraySubject.value + topFeeds)
            }
        }
    }
    
    func scrollViewDidScrolled(section: Int, index: Int) {
        indexArray[section] = index
    }
}
