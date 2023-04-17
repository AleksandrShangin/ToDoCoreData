//
//  CategoriesDataSource.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 17.04.2023.
//

import UIKit

final class CategoriesDataSource: NSObject, UICollectionViewDataSource, CategoryCollectionViewCellDelegate {
    
    //MARK: - Properties
    
    var collectionView: UICollectionView
    
    var items: [Category] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var menuButtonTapped: ((Category) -> Void)?
    
    //MARK: - Init
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    //MARK: - Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(CategoryCollectionViewCell.self, for: indexPath)
        
        let category = items[indexPath.row]
        cell.delegate = self
        cell.configure(with: category.name)
        let colors = [UIColor.darkGray, UIColor.gray, UIColor.lightGray]
        cell.contentView.backgroundColor = colors[indexPath.row % colors.count]
        
        return cell
    }
    
    func didTapMenuButton(_ cell: CategoryCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else {
            assertionFailure("Index must be set")
            return
        }
        let selectedCategory = items[index.item]
        
        self.menuButtonTapped?(selectedCategory)
    }
    
}
