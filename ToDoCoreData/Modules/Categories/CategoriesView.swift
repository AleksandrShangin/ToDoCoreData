//
//  CategoriesView.swift
//  ToDoCoreData
//
//  Created by Alex on 18.11.2022.
//

import UIKit

final class CategoriesView: UIView {
    
    //MARK: - Properties
    
    var layout: UICollectionViewFlowLayout!
    var collectionView: UICollectionView!
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
 
    //MARK: - Setup
    
    private func setupSubviews() {
        layout = {
            let i = UICollectionViewFlowLayout()
            i.scrollDirection = .vertical
            return i
        }()
        
        collectionView = {
            let i = UICollectionView(
                frame: .zero,
                collectionViewLayout: layout
            )
            i.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
            i.showsVerticalScrollIndicator = false
            i.automaticallyAdjustsScrollIndicatorInsets = true
            i.contentInsetAdjustmentBehavior = .automatic
            return i
        }()
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        collectionView.frame = bounds
    }
    
}
