//
//  CategoriesRouter.swift
//  ToDoCoreData
//
//  Created by Alex on 18.11.2022.
//

import Foundation

class CategoriesRouter: BaseRouter {
    
    func showTasks(of category: Category) {
        let projectsViewController = ProjectsFactory(category: category).build()
        projectsViewController.title = category.name
        viewController?.navigationController?.pushViewController(projectsViewController, animated: true)
    }
    
}
