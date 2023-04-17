//
//  ProjectsFactory.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 27.03.2023.
//

import Foundation

final class ProjectsFactory: Factory {
    private let category: Category
    
    init(category: Category) {
        self.category = category
    }
    
    func build() -> ProjectsViewController {
        let persistenceService: PersistenceService = PersistenceServiceImpl.shared
        let viewModel: ProjectsViewModel = ProjectsViewModelImpl(category: self.category, persistenceService: persistenceService)
        let viewController = ProjectsViewController(viewModel: viewModel)
        return viewController
    }
    
}
