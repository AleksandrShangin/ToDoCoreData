//
//  ProjectHeaderView.swift
//  ToDoCoreData
//
//  Created by Alex on 11/22/21.
//

import UIKit
import SnapKit

protocol ProjectHeaderViewDelegate: AnyObject {
    func didTapMenuButton(_ view: ProjectHeaderView)
}

final class ProjectHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    private let titleLabel = {
        let i = UILabel()
        i.font = .preferredFont(forTextStyle: .title2)
        return i
    }()
    
    private let menuButton = {
        let i = UIButton()
        i.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        i.clipsToBounds = true
        return i
    }()
    
    weak var delegate: ProjectHeaderViewDelegate?
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        contentView.addSubview(titleLabel)
        
        menuButton.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        contentView.addSubview(menuButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(Constants.mainInsets)
            $0.height.equalToSuperview()
        }
        
        menuButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(titleLabel.snp.right).offset(Constants.mainInsets)
            $0.right.equalToSuperview().inset(Constants.mainInsets * 2)
            $0.width.equalTo(44)
        }
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
