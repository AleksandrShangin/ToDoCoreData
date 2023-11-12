//
//  CategoriesView.swift
//  ToDoCoreData
//
//  Created by Alex on 18.11.2022.
//

import UIKit
import SnapKit

final class CategoriesView: UIView {
    
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
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    //MARK: - Setup
    
    private func setupSubviews() {
        backgroundColor = .systemBackground
        
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
