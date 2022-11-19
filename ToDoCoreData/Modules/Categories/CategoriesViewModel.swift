//
//  CategoriesViewModel.swift
//  ToDoCoreData
//
//  Created by Alex on 11/24/21.
//

import Foundation
import Combine

protocol CategoriesViewModelProtocol {
    var categories: CurrentValueSubject<[Category], Never> { get }
    var onError: PassthroughSubject<Error, Never> { get }
    
    func fetchCategories()
    func addNewCategory(name: String)
    func delete(_ category: Category)
    func update(_ category: Category, newName: String)
}

final class CategoriesViewModel: CategoriesViewModelProtocol {
    
    //MARK: - Public Properties
    
    var categories = CurrentValueSubject<[Category], Never>([Category]())
    var onError = PassthroughSubject<Error, Never>()
    
    //MARK: - Private Properties
    
    private let persistenceService: PersistenceService
    
    //MARK: - Init
    
    init(persistenceService: PersistenceService = PersistenceServiceImpl.shared) {
        self.persistenceService = persistenceService
    }
    
    //MARK: - Public Methods
    
    func fetchCategories() {
        persistenceService.fetchAllCategories { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let categories):
                self.categories.send(categories)
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func addNewCategory(name: String) {
        persistenceService.createCategory(name: name) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchCategories()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func delete(_ category: Category) {
        persistenceService.deleteEntity(entity: category) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchCategories()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func update(_ category: Category, newName: String) {
        category.name = newName
        persistenceService.updateEntity(entity: category) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchCategories()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
}
