//
//  CategoriesView.swift
//  ToDoCoreData
//
//  Created by Alex on 18.11.2022.
//

import UIKit
import SnapKit

final class CategoriesView: BaseView {
    
    //MARK: - Properties
    
    private let layout = setup(UICollectionViewFlowLayout()) {
        $0.scrollDirection = .vertical
    }
    
    lazy var collectionView = setup(UICollectionView(frame: .zero, collectionViewLayout: layout)) {
        $0.register(cell: CategoryCollectionViewCell.self)
        $0.showsVerticalScrollIndicator = false
        $0.automaticallyAdjustsScrollIndicatorInsets = true
        $0.contentInsetAdjustmentBehavior = .automatic
    }
    
    //MARK: - Setup
    
    override func setupSubviews() {
        backgroundColor = .systemBackground
        
        addSubview(collectionView)
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
