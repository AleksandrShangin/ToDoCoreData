//
//  ProjectsView.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 19.11.2022.
//

import UIKit
import SnapKit

final class ProjectsView: UIView {
    
    //MARK: - Properties
    
    let tableView = {
        let i = UITableView(
            frame: .zero,
            style: .grouped
        )
        i.register(view: ProjectHeaderView.self)
        i.register(cell: TaskTableViewCell.self)
        i.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        return i
    }()
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    //MARK: - Setup
    
    private func setupSubviews() {
        backgroundColor = .systemBackground
        
        addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
