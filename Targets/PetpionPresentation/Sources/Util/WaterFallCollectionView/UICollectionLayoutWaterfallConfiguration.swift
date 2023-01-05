//
//  UICollectionLayoutWaterfallConfiguration.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/11/10.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

public struct UICollectionLayoutWaterfallConfiguration {
    
    public var columnCount: Int
    
    public var spacing: CGFloat
    
    public var contentInsetsReference: UIContentInsetsReference
    
    public var itemSizeProvider: UICollectionViewWaterfallLayoutItemSizeProvider
        
    public init(
        columnCount: Int = 2,
        spacing: CGFloat = 8,
        contentInsetsReference: UIContentInsetsReference = .automatic,
        itemSizeProvider: @escaping UICollectionViewWaterfallLayoutItemSizeProvider
    ) {
        self.columnCount = columnCount
        self.spacing = spacing
        self.contentInsetsReference = contentInsetsReference
        self.itemSizeProvider = itemSizeProvider
    }
}
