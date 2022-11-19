//
//  CategoriesView.swift
//  ToDoCoreData
//
//  Created by Alex on 18.11.2022.
//

import UIKit

final class CategoriesView: UIView {
    
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
        tableView = {
            let i = UITableView()
            i.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
            i.showsVerticalScrollIndicator = false
            return i
        }()
        addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.frame = bounds
    }
    
}
