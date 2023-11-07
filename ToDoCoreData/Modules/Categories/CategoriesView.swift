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
    
    let collectionView = {
        let layout = {
            let i = UICollectionViewFlowLayout()
            i.scrollDirection = .vertical
            return i
        }()
        
        let i = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        i.register(cell: CategoryCollectionViewCell.self)
        i.showsVerticalScrollIndicator = false
        i.automaticallyAdjustsScrollIndicatorInsets = true
        i.contentInsetAdjustmentBehavior = .automatic
        return i
    }()
    
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
