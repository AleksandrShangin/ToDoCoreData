//
//  PersistenceServiceImpl.swift
//  ToDoCoreData
//
//  Created by Alex on 11/5/21.
//

import Foundation
import CoreData
import Combine

protocol PersistenceService {
    // Generic Combine Methods
    func fetch<T: NSManagedObject>(entity: T.Type) -> AnyPublisher<[T], Error>
    func fetch<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate) -> AnyPublisher<[T], Error>
    func delete<T: NSManagedObject>(entity: T) -> AnyPublisher<Void, Error>
    func delete<T: NSManagedObject>(entities: [T]) -> AnyPublisher<Void, Error>
    // Generic Closure Methods
    func fetch<T: NSManagedObject>(entity: T.Type, completion: (Result<[T], Error>) -> Void)
    func fetch<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate, completion: (Result<[T], Error>) -> Void)
    func deleteEntity<T: NSManagedObject>(entity: T, completion: (Result<Void, Error>) -> Void)
    func delete<T: NSManagedObject>(entity: T, predicate: NSPredicate, completion: (Result<Void, Error>) -> Void)
    
    func updateEntity<T: NSManagedObject>(entity: T, completion: (Result<Void, Error>) -> Void)
    
    // Categories
    func createCategory(name: String, completion: (Result<Void, Error>) -> Void)
    // Projects
    func createNewProject(category: Category, name: String, completion: (Result<Void, Error>) -> Void)
    // Tasks
    func createNewTask(category: Category, project: Project, name: String, completion: (Bool) -> Void)
}

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
    
    lazy var context = persistentContainer.viewContext

    // MARK: - Core Data Saving support

    func saveContext () {
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
    
    // MARK: - Generic Methods
    
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
    
    func deleteEntity<T: NSManagedObject>(entity: T, completion: (Result<Void, Error>) -> Void) {
        context.delete(entity)
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func delete<T: NSManagedObject>(entity: T, predicate: NSPredicate, completion: (Result<Void, Error>) -> Void) {
        
    }
    
    func delete<T: NSManagedObject>(entity: T) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.context.delete(entity)
            do {
                try self.context.save()
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
                try self.context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateEntity<T: NSManagedObject>(entity: T, completion: (Result<Void, Error>) -> Void) {
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func createEntity(type: NSManagedObject, completion: (Result<Void, Error>) -> Void) {
        
    }
    
    // MARK: - Category Methods
    
    func createCategory(name: String, completion: (Result<Void, Error>) -> Void) {
        let category = Category(context: context)
        category.name = name
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Projects Methods
    
    func createNewProject(category: Category, name: String, completion: (Result<Void, Error>) -> Void) {
        let newProject = Project(context: context)
        newProject.name = name
        newProject.category = category
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Task Methods
    
    func createNewTask(category: Category, project: Project, name: String, completion: (Bool) -> Void) {
        let newTask = Task(context: context)
        newTask.name = name
        newTask.isCompleted = false
        newTask.category = category
        newTask.project = project
        do {
            let tasks = try context.fetch(Task.fetchRequest())
            newTask.index = Int64(tasks.count-1)
        } catch {
            print("Could not fetch Core Data entities: \(error)")
        }
        do {
            try context.save()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
}
