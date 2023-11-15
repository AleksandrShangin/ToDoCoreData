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
    
    private let titleLabel = setup(UILabel()) {
        $0.font = .preferredFont(forTextStyle: .title2)
    }
    
    private let menuButton = setup(UIButton()) {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.clipsToBounds = true
    }
    
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
        backgroundColor = .systemBackground
        
        contentView.addSubview(titleLabel)
        
        menuButton.addTarget(
            self,
            action: #selector(menuButtonTapped),
            for: .touchUpInside
        )
        contentView.addSubview(menuButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(ViewConstants.mainInsets)
            $0.height.equalToSuperview()
        }
        
        menuButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.lessThanOrEqualTo(titleLabel.snp.right).offset(ViewConstants.mainInsets)
            $0.right.equalToSuperview().inset(ViewConstants.mainInsets * 2)
            $0.width.equalTo(44)
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func menuButtonTapped() {
        delegate?.didTapMenuButton(self)
    }
    
    // MARK: - Configure
    
    public func configure(with title: String) {
        titleLabel.text = title
    }
    
}
