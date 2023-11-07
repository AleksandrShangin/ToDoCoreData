//
//  TaskTableViewCell.swift
//  ToDoCoreData
//
//  Created by Alex on 3/8/22.
//

import UIKit
import SnapKit

struct TaskViewModel {
    let title: String
    let isCompleted: Bool
}

final class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let statusImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        return i
    }()
    
    private let titleLabel = {
        let i = UILabel()
        return i
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        statusImageView.image = nil
        titleLabel.text = nil
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {        
        contentView.addSubview(statusImageView)
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        statusImageView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(Constants.mainInsets)
            $0.size.equalTo(44 - 16)
            $0.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(statusImageView.snp.right).offset(Constants.mainInsets)
            $0.right.equalToSuperview().inset(Constants.mainInsets)
            $0.height.equalTo(44 - 16)
            $0.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    
    func configure(with model: TaskViewModel) {
        titleLabel.text = model.title
        if model.isCompleted {
            statusImageView.image = UIImage(systemName: "checkmark")
            titleLabel.alpha = 0.2
        } else {
            statusImageView.image = UIImage(systemName: "circle")
            titleLabel.alpha = 1.0
        }
    }
    
}
