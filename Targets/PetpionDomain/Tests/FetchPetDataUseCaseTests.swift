//
//  FetchPetDataUseCaseTests.swift
//  PetpionDataTests
//
//  Created by 김성원 on 2022/11/14.
//  Copyright © 2022 Petpion. All rights reserved.
//

import XCTest

@testable import PetpionDomain

final class FetchPetDataUseCaseTests: XCTestCase {

    var sut: DefaultFetchPetDataUseCase!
    var mockPetpionRepository: PetpionRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPetpionRepository = MockPetpionRepository()
        sut = DefaultFetchPetDataUseCase(petpionRepository: mockPetpionRepository)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

}
