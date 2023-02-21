//
//  PersistenceServiceImpl.swift
//  ToDoCoreData
//
//  Created by Alex on 11/5/21.
//

import Foundation
import CoreData
import Combine


final class PersistenceServiceImpl: PersistenceService {
    
    static let shared = PersistenceServiceImpl()
    
    private init() {}
    
    // MARK: - Core Data stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoCoreData")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private(set) lazy var context = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    
     private func save() throws {
        if context.hasChanges {
            do {
                try context.save()
                print("Core Data: Changes saved")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Generic Combine Methods
    
    func fetch<T: NSManagedObject>(entity: T.Type) -> AnyPublisher<[T], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            let request = NSFetchRequest<T>(entityName: String(describing: T.self))
            do {
                let results = try self.context.fetch(request)
                promise(.success(results))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetch<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate) -> AnyPublisher<[T], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            let request = NSFetchRequest<T>(entityName: String(describing: T.self))
            request.predicate = predicate
            do {
                let results = try self.context.fetch(request)
                promise(.success(results))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete<T: NSManagedObject>(entity: T) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.context.delete(entity)
            do {
                try self.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete<T: NSManagedObject>(entities: [T]) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            entities.forEach { self.context.delete($0) }
            do {
                try self.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Generic Closure Methods
    
    func insert(object: NSManagedObject, completion: (Result<Void, Error>) -> Void) {
        context.insert(object)
        do {
            try self.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetch<T: NSManagedObject>(entity: T.Type, completion: (Result<[T], Error>) -> Void) {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        do {
            let results = try context.fetch(request)
            completion(.success(results))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetch<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate, completion: (Result<[T], Error>) -> Void) {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = predicate
        do {
            let results = try context.fetch(request)
            completion(.success(results))
        } catch {
            completion(.failure(error))
        }
    }
    
    func update(entity: NSManagedObject, completion: (Result<Void, Error>) -> Void) {
        do {
            try self.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func delete(entity: NSManagedObject, completion: (Result<Void, Error>) -> Void) {
        context.delete(entity)
        do {
            try self.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func delete<T: NSManagedObject>(entity: T, predicate: NSPredicate, completion: (Result<Void, Error>) -> Void) {}
    
}
