//
//  PetpionHallTableViewCell.swift
//  PetpionPresentation
//
//  Created by 김성원 on 2023/02/28.
//  Copyright © 2023 Petpion. All rights reserved.
//

import UIKit

import Lottie
import PetpionDomain

protocol PetpionHallTableViewCellListener: NSObject {
    
    func collectionViewDidScrolled(cell: UITableViewCell, index: Int)
    func collectionViewItemDidSelected(cell: UITableViewCell, index: Int)
    func profileStackViewDidTapped(cell: UITableViewCell, itemIndex: Int)
}

final class PetpionHallTableViewCell: UITableViewCell {
    
    static let identifier = "PetpionHallTableViewCell"
    
    weak var petpionHallTableViewCellListener: PetpionHallTableViewCellListener?
    
    lazy var topFeedCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureTopFeedCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, PetpionFeed>!
    
    private lazy var lazyCatAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: LottieJson.lazyCat)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.play()
        animationView.isHidden = true
        return animationView
    }()
    
    private lazy var emptyFeedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "등록된 펫피언이 없어요.. 🐣"
        label.sizeToFit()
        label.isHidden = true
        return label
    }()

    var currentIndex: Int = 0
    
    // MARK: - Initialize
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        layout()
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        [lazyCatAnimationView, emptyFeedLabel].forEach { $0.isHidden = true }
        self.currentIndex = 0
        dataSource = nil
        topFeedCollectionView.reloadData()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutTopFeedCollectionView()
        layoutEmptyView()
    }
    
    private func layoutTopFeedCollectionView() {
        contentView.addSubview(topFeedCollectionView)
        NSLayoutConstraint.activate([
            topFeedCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
            topFeedCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topFeedCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topFeedCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        topFeedCollectionView.delegate = self
    }
    
    private func layoutEmptyView() {
        [lazyCatAnimationView, emptyFeedLabel].forEach { self.addSubview($0) }
        NSLayoutConstraint.activate([
            lazyCatAnimationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            lazyCatAnimationView.topAnchor.constraint(equalTo: self.topAnchor, constant: xValueRatio(40)),
            lazyCatAnimationView.heightAnchor.constraint(equalToConstant: xValueRatio(250)),
            lazyCatAnimationView.widthAnchor.constraint(equalToConstant: xValueRatio(250)),
            emptyFeedLabel.topAnchor.constraint(equalTo: lazyCatAnimationView.bottomAnchor),
            emptyFeedLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    // MARK: - Configure
    private func configureTopFeedCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85),
                                               heightDimension: .fractionalWidth(1.1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 10
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
            guard let strongSelf = self else { return }
            let index = Int(max(0, round(point.x / environment.container.contentSize.width)))
            guard strongSelf.currentIndex != index else { return }
            self?.petpionHallTableViewCellListener?.collectionViewDidScrolled(cell: strongSelf, index: index)
            strongSelf.currentIndex = index
        }

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func configureTopFeedCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Int, PetpionFeed> {
        let cellRegistration = makeCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: topFeedCollectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                         for: indexPath,
                                                         item: itemIdentifier)
        }
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<TopFeedCollectionViewCell, PetpionFeed> {
        UICollectionView.CellRegistration { cell, indexPath, item in
            cell.configureCollectionViewCell(item)
            cell.topFeedCollectionViewCellListener = self
            cell.roundCorners(cornerRadius: 15)
        }
    }
    
    // MARK: - Configure
    func configureCollectionView(items: [PetpionFeed]) {
        dataSource = configureTopFeedCollectionViewDataSource()
        var snapshot = NSDiffableDataSourceSnapshot<Int, PetpionFeed>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        if items.count == 1 {
            [lazyCatAnimationView, emptyFeedLabel].forEach { $0.isHidden = false }
        } else {
            [lazyCatAnimationView, emptyFeedLabel].forEach { $0.isHidden = true }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    func configureCollectionViewIndex(_ index: Int) {
        currentIndex = index
        topFeedCollectionView.scrollToItem(at: .init(item: index, section: 0), at: .centeredHorizontally, animated: false)
    }
}

extension PetpionHallTableViewCell: UICollectionViewDelegate, TopFeedCollectionViewCellListener {
    
    func profileStackViewDidTapped(with cell: UICollectionViewCell) {
        guard let cellIndexPath = topFeedCollectionView.indexPath(for: cell) else { return }
        petpionHallTableViewCellListener?.profileStackViewDidTapped(cell: self, itemIndex: cellIndexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        petpionHallTableViewCellListener?.collectionViewItemDidSelected(cell: self, index: indexPath.item)
    }
}
