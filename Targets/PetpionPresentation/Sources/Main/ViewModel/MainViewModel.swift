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
    
}

public protocol MainViewModelProtocol: MainViewModelInputProtocol, MainViewModelOutputProtocol {
    var petpionUseCase: PetpionUseCase { get }
}

final class MainViewModel: MainViewModelProtocol {
    
    let petpionUseCase: PetpionUseCase
    
    init(petpionUseCase: PetpionUseCase) {
        self.petpionUseCase = petpionUseCase
    }
    
    func vmStart() {
        print("mainViewModel start")
        petpionUseCase.doSomething()
    }
}
