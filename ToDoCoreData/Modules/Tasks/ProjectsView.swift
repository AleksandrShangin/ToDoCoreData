//
//  ProjectsView.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 19.11.2022.
//

import UIKit

final class ProjectsView: UIView {
    
    var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
 
    private func setupSubviews() {
        backgroundColor = .systemBackground
        
        tableView = {
            let i = UITableView()
            i.register(ProjectHeaderView.self, forHeaderFooterViewReuseIdentifier: ProjectHeaderView.identifier)
            i.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
            return i
        }()
        addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.frame = bounds
    }
    
}
