//
//  MainViewModel.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2022/11/09.
//  Copyright © 2022 Petpion. All rights reserved.
//

import PetpionDomain

public protocol MainViewModelInputProtocol {
    func vmStart()
}

public protocol MainViewModelOutputProtocol {
//    func makeViewModel(for: WaterfallItem) -> PetCollectionViewCell.ViewModel
}

public protocol MainViewModelProtocol: MainViewModelInputProtocol, MainViewModelOutputProtocol {
    var fetchPetDataUseCase: FetchPetDataUseCase { get }
}

final class MainViewModel: MainViewModelProtocol {
    
    let fetchPetDataUseCase: FetchPetDataUseCase
    var sortingOption: SortingOption = .favorite
    
    init(fetchPetDataUseCase: FetchPetDataUseCase) {
        self.fetchPetDataUseCase = fetchPetDataUseCase
    }
    
    func vmStart() {
        print("mainViewModel start")
    }
    
    func makeViewModel(for item: WaterfallItem) -> PetCollectionViewCell.ViewModel {
        return PetCollectionViewCell.ViewModel(item: item)
    }
}

