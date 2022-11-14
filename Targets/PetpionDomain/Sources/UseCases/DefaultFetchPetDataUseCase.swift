//
//  DefaultPetpionUseCase.swift
//  PetpionDomain
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import Foundation
import UIKit

public final class DefaultFetchPetDataUseCase: FetchPetDataUseCase {
    
    public var petpionRepository: PetpionRepository
    
    // MARK: - Initialize
    init(petpionRepository: PetpionRepository) {
        self.petpionRepository = petpionRepository
    }
    
    public func fetchPetData(sortBy option: SortingOption) -> [Pet] {
        let defaultPetData = fetchDefaultPetData()
        
        return sortPetData(defaultPetData, by: option)
    }
    
    // MARK: - Private Methods
    
    private func fetchDefaultPetData() -> [Pet] {
        
        // 단발성 호출로 받는것이 좋아보임 (Async await)
        petpionRepository.fetchSomething()
        
        return [Pet.init(ID: "", owner: User.init(nickName: "", profileImage: UIImage()), uploadDate: Date(), likeCount: 0, image: UIImage())]
    }
    
    private func sortPetData(_ data: [Pet], by option: SortingOption) -> [Pet] {
        var defaultData = data
        
        switch option {
        case .favorite:
            defaultData.sort { $0.likeCount < $1.likeCount }
        case .latest:
            defaultData.sort { $0.uploadDate > $1.uploadDate }
        case .random:
            defaultData.shuffle()
        }
        
        return defaultData
    }
}
