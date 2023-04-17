//
//  ProjectsDataSource.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 17.04.2023.
//

import UIKit

final class ProjectsDataSource: NSObject, UITableViewDataSource {
    
    //MARK: - Properties
    
    var tableView: UITableView
    
    var items: [Organizer] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Init
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    //MARK: - Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(TaskTableViewCell.self, for: indexPath)
        
        let task = items[indexPath.section].tasks[indexPath.row]
        let model = TaskViewModel(title: task.name, isCompleted: task.isCompleted)
        cell.configure(with: model)
        
        return cell
    }
    
}
