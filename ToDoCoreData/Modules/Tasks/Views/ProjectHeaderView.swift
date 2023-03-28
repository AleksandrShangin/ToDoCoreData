//
//  ProjectHeaderView.swift
//  ToDoCoreData
//
//  Created by Alex on 11/22/21.
//

import UIKit

protocol ProjectHeaderViewDelegate: AnyObject {
    func didTapMenuButton(_ view: ProjectHeaderView)
}

final class ProjectHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    private var titleLabel: UILabel!
    private var menuButton: UIButton!
    
    weak var delegate: ProjectHeaderViewDelegate?
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
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
        titleLabel = {
            let i = UILabel()
            i.font = .preferredFont(forTextStyle: .title2)
            return i
        }()
        contentView.addSubview(titleLabel)
        
        menuButton = {
            let i = UIButton()
            i.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            i.clipsToBounds = true
            i.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
            return i
        }()
        contentView.addSubview(menuButton)
    }
    
    private func setupConstraints() {
        let buttonSize: CGFloat = contentView.height
        
        titleLabel.frame = CGRect(
            x: Constants.mainInsets,
            y: 0,
            width: contentView.width - 16 - buttonSize - 16,
            height: contentView.height
        )
        menuButton.frame = CGRect(
            x: titleLabel.right + Constants.mainInsets,
            y: 0,
            width: buttonSize,
            height: buttonSize
        )
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapMenuButton() {
        delegate?.didTapMenuButton(self)
    }
    
    // MARK: - Configure
    
    public func configure(with title: String) {
        titleLabel.text = title
    }
    
}
