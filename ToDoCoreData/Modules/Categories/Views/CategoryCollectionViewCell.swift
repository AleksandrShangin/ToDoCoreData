//
//  CategoryCollectionViewCell.swift
//  ToDoCoreData
//
//  Created by Alex on 20.11.2022.
//

import UIKit

protocol CategoryCollectionViewCellDelegate: AnyObject {
    func didTapMenuButton(_ cell: CategoryCollectionViewCell)
}

final class CategoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var titleLabel: UILabel!
    var menuButton: UIButton!
    
    weak var delegate: CategoryCollectionViewCellDelegate?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        
        titleLabel = {
            let i = UILabel()
            i.font = .preferredFont(forTextStyle: .title1)
            return i
        }()
        contentView.addSubview(titleLabel)
        
        menuButton = {
            let i = UIButton()
            i.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            i.clipsToBounds = true
            i.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
            return i
        }()
        contentView.addSubview(menuButton)
    }
    
    private func setupConstraints() {
        let imageSize: CGFloat = 40
        
        titleLabel.frame = CGRect(
            x: Constants.mainInsets,
            y: Constants.mainInsets,
            width: contentView.width - 56 - 16,
            height: (contentView.height-16)/2
        )
        
        menuButton.frame = CGRect(
            x: contentView.width-56,
            y: Constants.mainInsets,
            width: imageSize,
            height: imageSize
        )
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
