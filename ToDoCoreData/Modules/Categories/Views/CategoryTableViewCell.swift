//
//  CategoryTableViewCell.swift
//  ToDoCoreData
//
//  Created by Alex on 11/21/21.
//

import UIKit

protocol CategoryTableViewCellDelegate: AnyObject {
    func didTapMenu(_ cell: CategoryTableViewCell)
}

final class CategoryTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let identifier = "CategoryTableViewCell"
    
    weak var delegate: CategoryTableViewCellDelegate?
    
    // MARK: - UI
    
    private let titleLabel = setup(UILabel()) {
        $0.font = .preferredFont(forTextStyle: .largeTitle)
    }
    
    private let menuButton = setup(UIButton()) {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        contentView.addSubview(titleLabel)
        contentView.addSubview(menuButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(
            x: 8,
            y: 8,
            width: contentView.width - 56 - 16,
            height: (contentView.height-16)/2
        )
        menuButton.frame = CGRect(x: contentView.width-56, y: 8, width: 40, height: 40)
    }
    
    // MARK: - Actions
    
    @objc private func didTapMenu() {
        delegate?.didTapMenu(self)
    }
    
    // MARK: - Configure
    
    public func configure(with title: String) {
        titleLabel.text = title
    }
    
}
