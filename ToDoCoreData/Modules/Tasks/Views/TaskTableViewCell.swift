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

final class TaskTableViewCell: UITableViewCell {
    static let identifier = "TaskTableViewCell"
    
    // MARK: - Properties
    
    private var statusImageView: UIImageView!
    private var titleLabel: UILabel!
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    override func prepareForReuse() {
        statusImageView.image = nil
        titleLabel.text = nil
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        statusImageView = {
            let i = UIImageView()
            i.contentMode = .scaleAspectFit
            return i
        }()
        contentView.addSubview(statusImageView)
        
        titleLabel = {
            let i = UILabel()
            return i
        }()
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        statusImageView.frame = CGRect(
            x: Constants.mainInsets,
            y: Constants.mainInsets,
            width: contentView.height - (Constants.mainInsets * 2),
            height: contentView.height - (Constants.mainInsets * 2)
        )
        titleLabel.frame = CGRect(
            x: statusImageView.right + Constants.mainInsets,
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
