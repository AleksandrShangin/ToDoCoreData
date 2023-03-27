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
    func createCategory(name: String)
    func delete(_ category: Category)
    func rename(_ category: Category, with newName: String)
}

final class CategoriesViewModel: CategoriesViewModelProtocol {
    
    //MARK: - Public Properties
    
    var categories = CurrentValueSubject<[Category], Never>([Category]())
    var onError = PassthroughSubject<Error, Never>()
    
    //MARK: - Private Properties
    
    private let persistenceService: PersistenceService
    private var subscriptions = Set<AnyCancellable>()
    
    //MARK: - Init
    
    init(persistenceService: PersistenceService = PersistenceServiceImpl.shared) {
        self.persistenceService = persistenceService
    }
    
    //MARK: - Public Methods
    
    func createCategory(name: String) {
        let newCategory = Category(context: persistenceService.context)
        newCategory.name = name
        
        persistenceService.insert(object: newCategory) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchCategories()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func fetchCategories() {
        self.persistenceService.fetch(entity: Category.self)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    print("Done fetching categories")
                case .failure(let error):
                    self.onError.send(error)
                }
            } receiveValue: { [weak self] categories in
                guard let self = self else { return }
                self.categories.send(categories)
            }
            .store(in: &self.subscriptions)
    }
    
    func delete(_ category: Category) {
        persistenceService.delete(entity: category) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchCategories()
            case .failure(let error):
                self.onError.send(error)
            }
        }
    }
    
    func rename(_ category: Category, with newName: String) {
        category.name = newName
        persistenceService.update(entity: category) { [weak self] result in
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
