//
//  CategoriesFactory.swift
//  ToDoCoreData
//
//  Created by Alexander Shangin on 27.03.2023.
//

import Foundation

final class CategoriesFactory: ModuleFactory {
    func build() -> CategoriesViewController {
        let persistenceService: PersistenceService = PersistenceServiceImpl.shared
        let viewModel: CategoriesViewModel = CategoriesViewModelImpl(persistenceService: persistenceService)
        let viewController = CategoriesViewController(viewModel: viewModel)
        return viewController
    }
}
