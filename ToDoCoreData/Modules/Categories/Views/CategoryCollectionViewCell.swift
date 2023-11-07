//
//  CategoryCollectionViewCell.swift
//  ToDoCoreData
//
//  Created by Alex on 20.11.2022.
//

import UIKit
import SnapKit

protocol CategoryCollectionViewCellDelegate: AnyObject {
    func didTapMenuButton(_ cell: CategoryCollectionViewCell)
}

final class CategoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    let titleLabel = {
        let i = UILabel()
        i.font = .preferredFont(forTextStyle: .title1)
        return i
    }()
    
    let menuButton = {
        let i = UIButton()
        i.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        i.clipsToBounds = true
        return i
    }()
    
    weak var delegate: CategoryCollectionViewCellDelegate?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        contentView.addSubview(titleLabel)
        
        menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
        contentView.addSubview(menuButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(Constants.mainInsets)
            $0.left.equalTo(Constants.mainInsets)
            $0.right.equalTo(menuButton.snp.left).offset(-Constants.mainInsets)
            $0.height.equalTo((120 - 16) / 2)
        }
        
        menuButton.snp.makeConstraints {
            $0.top.equalTo(Constants.mainInsets)
            $0.right.equalTo(-Constants.mainInsets * 2)
            $0.size.equalTo(40)
        }
    }
    
    
    // MARK: - Actions
    
    @objc private func didTapMenu() {
        delegate?.didTapMenuButton(self)
    }
    
    // MARK: - Configure
    
    public func configure(with title: String) {
        titleLabel.text = title
    }
    
}
