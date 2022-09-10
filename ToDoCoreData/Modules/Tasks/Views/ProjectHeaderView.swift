//
//  ProjectHeaderView.swift
//  ToDoCoreData
//
//  Created by Alex on 11/22/21.
//

import UIKit

protocol ProjectHeaderViewDelegate: AnyObject {
    func didTapAddTask(_ view: ProjectHeaderView)
}

class ProjectHeaderView: UITableViewHeaderFooterView {

    // MARK: - Properties
    
    static let identifier = "ProjectHeaderView"
    
    weak var delegate: ProjectHeaderViewDelegate?
    
    // MARK: - UI
    
    private let titleLabel = setup(UILabel()) {
        $0.font = .preferredFont(forTextStyle: .title2)
    }
    
    private let menuButton = setup(UIButton()) {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(didTapAddTask), for: .touchUpInside)
    }
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
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
            y: 0,
            width: contentView.width - contentView.height - 24 - 16,
            height: contentView.height
        )
        menuButton.frame = CGRect(
            x: contentView.width - contentView.height - 24,
            y: 0,
            width: contentView.height,
            height: contentView.height
        )
    }
    
    // MARK: - Actions
    
    @objc private func didTapAddTask() {
        delegate?.didTapAddTask(self)
    }
    
    // MARK: - Public Methods
    
    public func configure(with title: String) {
        titleLabel.text = title
    }
    
}
