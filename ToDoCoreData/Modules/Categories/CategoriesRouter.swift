//
//  CategoriesRouter.swift
//  ToDoCoreData
//
//  Created by Alex on 18.11.2022.
//

import Foundation

class CategoriesRouter: BaseRouter {
    
    func showTasks(of category: Category) {
        let tasksViewModel = ProjectsViewModel(category: category)
        let projectsViewController = ProjectsViewController(viewModel: tasksViewModel)
        projectsViewController.title = category.name ?? "No Category"
        viewController.navigationController?.pushViewController(projectsViewController, animated: true)
    }
    
}
