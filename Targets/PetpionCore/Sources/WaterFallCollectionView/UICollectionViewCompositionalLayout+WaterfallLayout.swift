//
//  UICollectionViewCompositionalLayoutExtension.swift
//  PetpionCore
//
//  Created by 김성원 on 2022/11/10.
//  Copyright © 2022 Petpion. All rights reserved.
//

import UIKit

extension UICollectionViewCompositionalLayout {
    
    static public func makeWaterfallLayout(configuration: UICollectionLayoutWaterfallConfiguration) -> UICollectionViewCompositionalLayout {
        
        var numberOfItems: (Int) -> Int = { _ in 0 }
        
        let layout = UICollectionViewCompositionalLayout { section, environment in
            
            let groupLayoutSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(environment.container.effectiveContentSize.height)
            )
            
            let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { environment in
                let itemProvider = LayoutItemProvider(configuration: configuration, environment: environment)
                var items = [NSCollectionLayoutGroupCustomItem]()
                for i in 0..<numberOfItems(section) {
                    let indexPath = IndexPath(item: i, section: section)
                    let item = itemProvider.item(for: indexPath)
                    items.append(item)
                }
                return items
            }
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsetsReference = configuration.contentInsetsReference
            return section
        }
        
        numberOfItems = { [weak layout] in
            layout?.collectionView?.numberOfItems(inSection: $0) ?? 0
        }
        
        return layout
    }

}
