//
//  CategoriesViewModel.swift
//  ToDoCoreData
//
//  Created by Alex on 11/24/21.
//

import Foundation
import Combine

final class CategoriesViewModel {
    
    private(set) var title = "Organizer"
    
    var categories = CurrentValueSubject<[Category], Never>([Category]())
    
    func fetchCategories() {
        PersistenceServiceImpl.shared.fetchAllCategories { [weak self] result in
            switch result {
            case .success(let categories):
                self?.categories.send(categories)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addNewCategory(name: String) {
        PersistenceServiceImpl.shared.createCategory(name: name) { [weak self] success in
            if success {
                self?.fetchCategories()
            } else {
                print("Error Adding new category")
            }
        }
    }
    
    func delete(_ category: Category) {
        PersistenceServiceImpl.shared.deleteCategory(category: category) { [weak self] success in
            if success {
                self?.fetchCategories()
            } else {
                print("Error Deleting new category")
            }
        }
    }
    
    func update(_ category: Category, name: String) {
        PersistenceServiceImpl.shared.updateCategory(category: category, newName: name) { [weak self] success in
            if success {
                self?.fetchCategories()
            } else {
                 print("Error Updating category")
            }
            
        }
    }
    
}
