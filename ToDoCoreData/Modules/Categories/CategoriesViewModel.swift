//
//  CategoriesViewModel.swift
//  ToDoCoreData
//
//  Created by Alex on 11/24/21.
//

import Foundation
import Combine

protocol CategoriesViewModel {
    var categories: CurrentValueSubject<[Category], Never> { get }
    var onError: PassthroughSubject<Error, Never> { get }
    
    func fetchCategories()
    func createCategory(name: String)
    func delete(_ category: Category)
    func rename(_ category: Category, with newName: String)
}

final class CategoriesViewModelImpl: CategoriesViewModel {
    
    //MARK: - Public Properties
    
    var categories = CurrentValueSubject<[Category], Never>([Category]())
    var onError = PassthroughSubject<Error, Never>()
    
    //MARK: - Private Properties
    
    private let persistenceService: PersistenceService
    private var subscriptions = Set<AnyCancellable>()
    
    //MARK: - Init
    
    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }
    
    //MARK: - Public Methods
    
    func createCategory(name: String) {
        let newCategory = Category(context: persistenceService.context)
        newCategory.name = name
        
        persistenceService.insert(object: newCategory)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: { [weak self] in
                self?.fetchCategories()
            })
            .store(in: &subscriptions)
    }
    
    func fetchCategories() {
        self.persistenceService.fetch(entity: Category.self)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            } receiveValue: { [weak self] categories in
                self?.categories.send(categories)
            }
            .store(in: &subscriptions)
    }
    
    func rename(_ category: Category, with newName: String) {
        category.name = newName
        
        persistenceService.update(entity: category)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            }, receiveValue: { [weak self] in
                self?.fetchCategories()
            })
            .store(in: &subscriptions)
    }
    
    func delete(_ category: Category) {
        persistenceService.delete(entity: category)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.onError.send(error)
                }
            } receiveValue: { [weak self] in
                self?.fetchCategories()
            }
            .store(in: &subscriptions)
    }
    
}
