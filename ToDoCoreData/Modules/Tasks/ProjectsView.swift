//
//  ProjectsView.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 19.11.2022.
//

import UIKit
import SnapKit

final class ProjectsView: BaseView {
    
    //MARK: - Properties
    
    let tableView = setup(UITableView(frame: .zero, style: .grouped)) {
        $0.register(view: ProjectHeaderView.self)
        $0.register(cell: TaskTableViewCell.self)
        $0.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: - Setup
    
    override func setupSubviews() {
        addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
