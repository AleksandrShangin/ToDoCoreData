//
//  TaskTableViewCell.swift
//  ToDoCoreData
//
//  Created by Alex on 3/8/22.
//

import UIKit

struct TaskViewModel {
    let title: String
    let isCompleted: Bool
}

class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "TaskTableViewCell"
    
    // MARK: - UI Elements
    
    private let statusImageView = setup(UIImageView()) {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(statusImageView)
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        statusImageView.image = nil
        titleLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statusImageView.frame = CGRect(
            x: 8,
            y: 8,
            width: contentView.height-16,
            height: contentView.height-16
        )
        titleLabel.frame = CGRect(
            x: statusImageView.right + 8,
            y: 0,
            width: contentView.width - statusImageView.width - 24,
            height: contentView.height
        )
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
